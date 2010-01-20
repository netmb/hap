package hapConfig::Controller::Gui;

use strict;
use warnings;
use base 'Catalyst::Controller';
use IO::Socket;

=head1 NAME

hapConfig::Controller::Gui - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;
  $c->forward( '/gui/setConfig/' . $c->config->{DefaultConfig} );
}

sub getAllObjects : Local {
  my ( $self, $c ) = @_;
  my @guiObjs =
    map { { id => $_->id, name => $_->name, type => $_->type, display => JSON::XS->new->utf8(0)->decode( $_->display ) } }
    $c->model('hapModel::GuiTypes')->search( {} )->all;

  $c->stash->{success} = 'true';
  $c->stash->{data}    = \@guiObjs;
  $c->forward('View::JSON');
}

sub getConfigs : Local {
  my ( $self, $c ) = @_;
  $c->stash->{configs}  = [ $c->model('hapModel::Config')->search()->all ];
  $c->stash->{template} = 'gui/config.tt2';
}

sub setConfig : Local {
  my ( $self, $c, $elementnfId ) = @_;
  $c->stash->{sceneId}  = 0;
  $c->session->{config} = $elementnfId;
  my $rc = $c->model('hapModel::GuiView')->search( { config => $elementnfId, isdefault => 1 } )->first;
  if ( !$rc ) {
    $rc = $c->model('hapModel::GuiView')->search( { config => $elementnfId } )->first;
  }
  if ($rc) {
    my $rcScene = $c->model('hapModel::GuiScene')->search( { viewid => $rc->id, isdefault => 1, config => $elementnfId } )->first;
    if ( !$rcScene ) {
      $rcScene = $c->model('hapModel::GuiScene')->search( { viewid => $rc->id, config => $elementnfId } )->first;
    }
    if ($rcScene) {
      $c->stash->{sceneId} = $rcScene->id;
    }
  }
  if ( $c->stash->{sceneId} == 0 ) {
    $c->forward("getConfigs");
  }
  else {
    $c->stash->{template} = 'gui/scene.tt2';
  }
}

sub setDevice : Local {
  my ( $self, $c, $module, $device, $value ) = @_;
  my $data;
  my $sock = new IO::Socket::INET( PeerAddr => $c->config->{MessageProcessor}->{Host}, PeerPort => $c->config->{MessageProcessor}->{Port}, Proto => 'tcp' );
  eval {
    local $SIG{ALRM} = sub { die 'Alarm'; };
    alarm 2;
    $data = <$sock>;    # Welcome ?
    alarm 0;
  };
  if ($@) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Cant connect to the MessageProcessor.";
  }
  else {
    print $sock "destination " . $c->config->{hap}->getModuleAddress($module) . " set device $device value $value\n";
    #print $sock "destination " . $c->config->{'mAddress'}->{$module} . " set device $device value $value\n";
    $data = <$sock>;
    $c->log->debug("$data");
    $sock->autoflush(1);

    $sock->close();
    if ( $data =~ /.*value\s*(\d+).*/ ) {
      $c->stash->{success} = \1;
      $c->stash->{data} = { value => $1 };
    }
    else {
      $c->stash->{success} = \0;
    }
  }
  $c->forward('View::JSON');
}

sub queryDevice : Local {
  my ( $self, $c, $module, $device ) = @_;
  my ( $data, $sData );
  my $sock = new IO::Socket::INET( PeerAddr => $c->config->{MessageProcessor}->{Host}, PeerPort => $c->config->{MessageProcessor}->{Port}, Proto => 'tcp' );
  eval {
    local $SIG{ALRM} = sub { die 'Alarm'; };
    alarm 2;
    $sData = <$sock>;    # Welcome ?
    alarm 0;
  };
  if ($@) {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Cant connect to the MessageProcessor.";
  }
  else {
    print $sock "destination " . $c->config->{hap}->getModuleAddress($module) . " query device $device\n";
    $sData = <$sock>;
    $sock->autoflush(1);
    $sock->close();

    my $rc =
      $c->model('hapModel::Status')->search( { module => $module, address => $device, config => $c->session->{config} }, { order_by => "TS DESC", rows => 1 } )
      ->first;

    if ($rc) {
      $data = { value => $rc->status };
      $c->stash->{success} = \1;
    }
    else {
      $c->stash->{success} = \0;
    }
  }
  $c->stash->{data} = $data;
  $c->forward('View::JSON');
}

sub getScene : Local {
  my ( $self, $c, $id ) = @_;
  $c->forward("/guiscene/get");
}

sub getView : Local {
  my ( $self, $c, $id ) = @_;
  my $rcScene = $c->model('hapModel::GuiScene')->search( { viewid => $id, isdefault => 1, config => $c->session->{config} } )->first;
  if ( !$rcScene ) {
    $rcScene = $c->model('hapModel::GuiScene')->search( { viewid => $id, config => $c->session->{config} } )->first;
  }
  if ($rcScene) {
    $id = $rcScene->id;
    $c->forward( "/guiscene/get", [$id] );
  }
  else {
    $c->forward("/gui/getConfigs");
  }
}

sub refresh : Local {
  my ( $self, $c ) = @_;
  my @data;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
    my $o = $_;
    if ( $o->{type} eq "HAP.Chart" ) {
      my $rc            = $c->model('hapModel::GuiObjects')->search( { id => $o->{id} } )->first;
      my $displayObject = JSON::XS->new->utf8(0)->decode( $rc->configobject );
      my $chartObj      = $displayObject->{'chart'};
      foreach ( @{ $chartObj->{'elements'} } ) {
        my $element = $_;
        my @rcdata  =
          $c->model('hapModel::Status')
          ->search( { ts => { '>', ( time() - $o->{startOffset} * 60 ) }, module => $element->{'HAP-Module'}, address => $element->{'HAP-Device'} },
          { order_by => 'TS ASC' } )->all;
        my ( @labels, @values );
        foreach (@rcdata) {
          my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( $_->ts );
          $hour = sprintf( "%02d", $hour );
          $min  = sprintf( "%02d", $min );
          if ( $chartObj->{'x_axis_labels'}->{'show_date'} ) {
            $mday = sprintf( "%02d", $mday );
            $mon  = sprintf( "%02d", $mon );
            $year = $year + 1900;
            push @labels, "$mday.$mon.$year $hour:$min";
          }
          else {
            push @labels, "$hour:$min";
          }    
          $element->{'Scale'} = 1 if ( !$element->{'Scale'} );
          push @values, $_->status * $element->{'Scale'};
        }
        $chartObj->{'x_axis_labels'}->{'labels'} = \@labels;
        $chartObj->{'x_axis'}->{'labels'}        = $chartObj->{'x_axis_labels'};
        $chartObj->{'x_axis_labels'}             = undef;
        $element->{values}                       = \@values;
      }
      push @data,
        {
        id    => $o->{id},
        value => $chartObj
        };
    }
    else {
      my $rc =
        $c->model('hapModel::Status')
        ->search( { module => $_->{module}, address => $_->{address}, config => $c->session->{config} }, { order_by => "TS DESC", rows => 1 } )->first;
      if ($rc) {
        push @data,
          {
          id    => $_->{id},
          value => $rc->status
          };
      }
    }
  }
  $c->stash->{success} = \1;
  $c->stash->{data}    = \@data;
  $c->forward('View::JSON');
}

sub access_denied : Private {
  my ( $self, $c ) = @_;
  $c->response->redirect( $c->uri_for('/login') );
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
