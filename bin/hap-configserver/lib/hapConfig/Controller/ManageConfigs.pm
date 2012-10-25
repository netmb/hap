package hapConfig::Controller::ManageConfigs;

use strict;
use warnings;
use base 'Catalyst::Controller';

use IO::Socket::INET;

=head1 NAME

hapConfig::Controller::ManageConfigs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body(
    'Matched hapConfig::Controller::ManageConfigs in ManageConfigs.');
}

sub getCurrentConfig : Local {
  my ( $self, $c ) = @_;
  my $rc =
    $c->model('hapModel::Config')->search( id => $c->session->{config} )->first;
  if ( defined($rc) ) {
    $c->stash->{id}   = $rc->id;
    $c->stash->{name} = $rc->name;
  }
  else {
    $c->stash->{id}   = 0;
    $c->stash->{name} = 'undefined';
  }
  $c->forward('View::JSON');
}

sub getConfigs : Local {
  my ( $self, $c ) = @_;
  my @configs =
    map { { id => $_->id, name => $_->name, isdefault => $_->isdefault + 0 } }
    $c->model('hapModel::Config')->all;
  $c->stash->{results}       = \@configs;
  $c->stash->{currentConfig} = $c->session->{config};
  $c->forward('View::JSON');
}

sub setConfigs : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my $error    = undef;
  my $defaultConfig = 0;
  foreach (@$jsonData) {
    my $row = $_;
    $c->log->debug("##".$row->{isdefault}."##");
    if ( $row->{isdefault} ) {
      $defaultConfig = 1;
      $c->config->{DefaultConfig} = $row->{id};
      my $sock = new IO::Socket::INET(
        PeerAddr => $c->config->{MessageProcessor}->{Host},
        PeerPort => $c->config->{MessageProcessor}->{Port},
        Proto    => 'tcp'
      );
      my $tmp;
      if ( !$sock ) {
        $error = "Can\'t connect to the Message-Processor!";
        last;
      }
      else {
        eval {
          local $SIG{ALRM} = sub { die 'Alarm'; };
          alarm 1;
          my $data = <$sock>;
          alarm 0;
        };
        if ($@) {
          $error = "Can\'t connect to the Message-Processor!";
          last;
        }
        else {
          print $sock '{"DefaultConfig": ' . $row->{id} . "}\n";

          #my $response = <$sock>;
        }
        $sock->close();
      }
    }
    else {
      $row->{isdefault} = 0;
    }
    my $data = { name => $row->{name}, isdefault => $row->{isdefault} };
    my $rs;
    if ( $row->{id} == 0 ) {
      eval { $rs = $c->model('hapModel::Config')->create($data); };
      if ($@) {
        $error = $@;
        #last;
      }
    }
    else {
      $rs = $c->model('hapModel::Config')->search( id => $row->{id} )->first;
      eval { $rs->update($data) };
      if ($@) {
        $error = $@;
        #last;
      }
    }
  }
  if ( !$defaultConfig ) {
    $error = "Please set a default-config!";
  }
  if ($error) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "$error";
  }
  else {
    $c->stash->{success} = \1;
  }

#my @rs = $c->model('hapModel::Module')->search( config => $c->config->{DefaultConfig} )->all;
#foreach (@rs) {
#	$c->config->{hap}->getModuleAddress($_->id ) = $_->address;
#}
  $c->forward('View::JSON');
}

sub selectConfig : Local {
  my ( $self, $c, $id ) = @_;
  $c->session->{config} = $id;
  $c->stash->{success}  = \1;
  $c->forward('View::JSON');
}

sub delConfigs : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my @tables   = hapConfig::hapSchema->sources;
  foreach (@$jsonData) {
    my $config = $_->{id};
    foreach (@tables) {
      if ( $c->model("hapModel::$_")->result_source->has_column('config') ) {
        $c->log->debug("$_");
        $c->model("hapModel::$_")->search( config => $config )->delete_all;
      }
    }
    $c->model("hapModel::Config")->search( id => $config )->delete_all;
  }

  $c->stash->{success} = \1;
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
