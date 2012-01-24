package hapConfig::Controller::ManageModules;

use strict;
use warnings;
use base 'Catalyst::Controller';

#use HAP::Log;
use IO::Socket::INET;

=head1 NAME

  hapConfig::Controller::ManageModules - Catalyst Controller

=head1 DESCRIPTION

  Catalyst Controller .

=head1 METHODS

=cut

=head2 index 

=cut

#my $log = new HAP::Log( $c );

sub index : Private {
  my ( $self, $c ) = @_;
  $c->response->body('Matched hapConfig::Controller::ManageModules in ManageModules.');
}

sub getModules : Local {
  my ( $self, $c ) = @_;
  $c->stash->{modules} = [
    map {
      {
        'id'          => $_->id,
        'name'        => $_->name,
        'firmwareid'  => $_->firmwareid,
        'devoption/1' => ( $_->devoption & 1 ),
        'devoption/2' => ( $_->devoption & 2 ),
        'devoption/4' => ( $_->devoption & 4 )
      }
      } $c->model('hapModel::Module')->search( { config => $c->session->{config}, isccu => { '!=', 1 } } )->all
  ];
  $c->forward('View::JSON');
}

sub setModules : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my @mUrls;
  foreach (@$jsonData) {
    my $row  = $_;
    my $rs   = $c->model('hapModel::Module')->search( id => $row->{id} )->first;
    my $data = {
      name       => $row->{name},
      firmwareid => $row->{firmwareid}
    };
    my $devOpt = $row->{'devoption/1'} * 1;
    $devOpt |= $row->{'devoption/2'} * 2;
    $devOpt |= $row->{'devoption/4'} * 4;
    $data->{devoption} = $devOpt;
    $rs->update($data);
    push @mUrls, { url => "module/$row->{id}", name => $row->{name} };    # required only for updating tree-nodes

  }
  $c->stash->{data}    = \@mUrls;
  $c->stash->{success} = \1;
  $c->stash->{info}    = "Done.";
  $c->forward('View::JSON');
}

sub pushConfig : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my $config   = $c->session->{config};
  my $data;
  my $sock = new IO::Socket::INET( PeerAddr => $c->config->{Scheduler}->{Host}, PeerPort => $c->config->{Scheduler}->{Port}, Proto => 'tcp' );
  if ( !$sock ) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Cant connect to Scheduler";
  }
  else {
    eval {
      local $SIG{ALRM} = sub { die 'Alarm'; };
      alarm 1;
      $data = <$sock>;    # Welcome ?
      alarm 0;
    };
    if ($@) {
      $c->stash->{success} = \0;
      $c->stash->{info}    = "Cant connect to Scheduler.";
    }
    else {
      foreach (@$jsonData) {
        my $row = $_;
        #$devOpt = 0;
        #$devOpt |= 1 if ( $row->{'devoption/1'} );
        #$devOpt |= 2 if ( $row->{'devoption/2'} );
        #$devOpt |= 4 if ( $row->{'devoption/4'} );
        if ( $row->{'devoption/1'} ) {
          print $sock "add * * * * * hap-lcdguibuilder -m $row->{id} -f\n";
        }
        elsif ( $row->{'devoption/4'} ) {
          print $sock "add * * * * * hap-configbuilder -m $row->{id} -f\n";
        }

        #$data = <$sock>;
        $sock->autoflush(1);
      }
      $c->stash->{success} = \1;
    }
  }
  $sock->close();
  $c->forward('View::JSON');
}

sub flashFirmware : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my $config   = $c->session->{config};
  my $data;
  my $sock = new IO::Socket::INET( PeerAddr => $c->config->{Scheduler}->{Host}, PeerPort => $c->config->{Scheduler}->{Port}, Proto => 'tcp' );
  if ( !$sock ) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Cant connect to Scheduler";
  }
  else {
    eval {
      local $SIG{ALRM} = sub { die 'Alarm'; };
      alarm 2;
      $data = <$sock>;    # Welcome ?
      alarm 0;
    };
    if ($@) {
      $c->stash->{success} = \0;
      $c->stash->{info}    = "Cant connect to Scheduler.";
    }
    else {
      my $modules = "";
      foreach (@$jsonData) {
        if ( $modules eq "" ) {
          $modules .= $_->{id};
        }
        else {
          $modules .= "," . $_->{id};
        }
      }
      print $sock "add * * * * * hap-firmwarebuilder -m $modules -f\n";

      #$data = <$sock>;
      $sock->autoflush(1);
      $c->stash->{success} = \1;
    }
  }
  $sock->close();
  $c->forward('View::JSON');
}

sub resetModules : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my $config   = $c->session->{config};
  my $data;
  my $sock = new IO::Socket::INET( PeerAddr => $c->config->{Scheduler}->{Host}, PeerPort => $c->config->{Scheduler}->{Port}, Proto => 'tcp' );
  if ( !$sock ) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Cant connect to Scheduler";
  }
  else {
    eval {
      local $SIG{ALRM} = sub { die 'Alarm'; };
      alarm 2;
      $data = <$sock>;    # Welcome ?
      alarm 0;
    };
    if ($@) {
      $c->stash->{success} = \0;
      $c->stash->{info}    = "Cant connect to Scheduler.";
    }
    else {
      foreach (@$jsonData) {
        my $mAddr = $c->config->{hap}->getModuleAddress( $_->{id} );    
        print $sock "add * * * * * hap-sendcmd -c \"destination $mAddr config-reset\"\n";
        $data = <$sock>;
        $sock->autoflush(1);
      }
      $c->stash->{success} = \1;
    }
  }
  $sock->close();
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
