package hapConfig::Controller::LcdGui;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Encode;

=head1 NAME

hapConfig::Controller::LcdGui - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::LcdGui in LcdGui.');
}

sub getAllObjects : Local {
  my ( $self, $c ) = @_;
  my @lcdObjs =
    map {
    {
      id        => $_->id,
      shortName => $_->shortname,
      type      => $_->type + 0,
      inPorts   => $_->inports + 0,
      outPorts  => $_->outports + 0,
      display   => JSON::XS->new->utf8(0)->decode( $_->display )
    }
    } $c->model('hapModel::LcdTypes')->search( {} )->all;
  $c->stash->{success} = 'true';
  $c->stash->{data}    = \@lcdObjs;
  $c->forward('View::JSON');
}

sub get : Local {
  my ( $self, $c, $id ) = @_;
  if ( $id != 0 ) {
    my $rc = $c->model('hapModel::Abstractdevice')->search( id => $id )->first;
    $c->stash->{success} = 'true';
    $c->stash->{data}    = {
      id        => $rc->id,
      name      => $rc->name,
      room      => $rc->room,
      module    => $rc->module,
      address   => $rc->address,
      notify    => $rc->notify,
      isDefault => $rc->attrib0,
      timeout   => $rc->attrib1 || 10,
      config    => $c->session->{config}
    };

    my @objects;
    my @rc = $c->model('hapModel::LcdObjects')->search( abstractdevid => $id )->all;
    foreach (@rc) {
      push @objects, JSON::XS->new->utf8(0)->decode( $_->configobject );
    }
    $c->stash->{data}->{objects} = \@objects;
  }

  if ( $id == 0 ) {
    $c->stash->{data} = {};    # required for extjs
    if ( $c->request->params->{module} ne 'undefined' ) {
      $c->stash->{data} = { module => $c->request->params->{module} };
    }
    elsif ( $c->request->params->{room} ne 'undefined' ) {
      $c->stash->{data} = { room => $c->request->params->{room} };
    }
    $c->stash->{success} = 'true';
  }
  $c->forward('View::JSON');

}

sub delete : Local {
  my ( $self, $c, $id ) = @_;
  my $rc = $c->model('hapModel::Abstractdevice')->search( id => $id )->delete_all;
  $rc = $c->model('hapModel::LcdObjects')->search( abstractdevid => $id )->delete_all;
  if ( $rc == 1 ) {
    $c->stash->{success} = \1;
    $c->stash->{info}    = "Deleted: DB-ID : $id";
  }
  else {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Failed!: DB-ID : $id";
  }
  $c->forward('View::JSON');
}

sub submit : Local {
  my ( $self, $c, $id ) = @_;
  my $data = {
    name    => $c->request->params->{name},
    room    => $c->request->params->{room},
    type    => 96,
    subtype => 240,
    module  => $c->request->params->{module},
    address => $c->request->params->{address},
    notify  => $c->request->params->{notify},
    attrib0 => $c->request->params->{isDefault},
    attrib1 => $c->request->params->{timeout} || 10,
    config  => $c->session->{config}
  };
  my $rs;
  if ( $id == 0 ) {
    $rs = $c->model('hapModel::Abstractdevice')->create($data);
    $id = $rs->id;
  }
  else {
    $rs = $c->model('hapModel::Abstractdevice')->search( id => $id )->first;
    $rs->update($data);
  }
  if ( $c->request->params->{isDefault} ) {
    my @rs = $c->model('hapModel::Abstractdevice')->search( id => { '!=', $id }, subtype => 240, module => $c->request->params->{module} )->all;
    foreach (@rs) {
      $_->update( { attrib0 => 0 } );
    }
  }
  $rs = $c->model('hapModel::LcdObjects')->search( abstractdevid => $id )->delete_all;

  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );

  # Offset Calculation
  my $offset = 5;
  my %uidMap;
  foreach (@$jsonData) {
    $_->{offset} = $offset;
    if ( $_->{type} == 1 ) {    # Menu
      my $len    = 2;              # Typ1 + ItemCount
      my $mItems = $_->{mItems};
      foreach my $item (@$mItems) {
        $len += length( &eString( $item->{display}->{'Label (14 max.)'} ) ) + 2;    # estring with dst
      }
      $offset += $len;
    }
    elsif ( $_->{type} == 16 ) {                                                    # Device
      my $len = 3;                                                                  # Typ16 + Module + Address
      $len    += length( &eString( $_->{display}->{'Label (16 max.)'} ) );          # estring
      $offset += $len;
    }
    elsif ( $_->{type} == 32 ) {                                                    # Thermostat
      my $len = 4;                                                                  # Typ32 + Module + Address + Refresh
      $len    += length( &eString( $_->{display}->{'Label (16 max.)'} ) );          # estring
      $offset += $len;
    }
    $uidMap{ $_->{uid} } = $_->{offset};
  }

  # Getting Defaults (root, defaults)
  my $countRoot    = 0;
  my $countDefault = 0;
  my $root         = 0;
  my $default      = 0;
  my $timeout      = $c->request->params->{timeout} || 0;
  foreach (@$jsonData) {
    if ( $_->{display}->{'Is Root'} == 1 ) {
      $root = $_->{offset};
      $countRoot++;
    }
    if ( $_->{display}->{'Is Default'} == 1 ) {
      $default = $_->{offset};
      $countDefault++;
    }
  }
  if ( $countRoot != 1 || $countDefault != 1 ) {
    $c->stash->{success} = \0;
    $c->stash->{data}    = "Found $countRoot Root-Flags and $countDefault Default-Flags";
    $c->forward('View::JSON');
    return;
  }
  my $defaultString = chr( ( $root >> 8 ) ) . chr( ( $root & 0xFF ) ) . chr( ( $default >> 8 ) ) . chr( ( $default & 0xFF ) ) . chr($timeout);

  # Build EEProm-Strings
  $rs = $c->model('hapModel::LcdObjects')->search( abstractdevid => $id )->delete_all;
  my $count = 0;
  foreach (@$jsonData) {
    my $dbData;
    my $lcdObj = $_;

    $dbData->{abstractdevid} = $id;
    $dbData->{type}          = $lcdObj->{type};
    $dbData->{configobject}  = JSON::XS->new->utf8(0)->encode($lcdObj);
    $dbData->{config}        = $c->session->{config};

    if ( $lcdObj->{type} == 1 ) {    #Menu
      my $mItems = $lcdObj->{mItems};
      my @mItems = sort { $a->{y} <=> $b->{y} } @$mItems;
      $lcdObj->{string} = chr(1) . chr( scalar(@mItems) );
      foreach my $item (@mItems) {
        $lcdObj->{string} .=
          &eString( $item->{display}->{'Label (14 max.)'} ) . chr( $uidMap{ $item->{outPort1} } >> 8 ) . chr( $uidMap{ $item->{outPort1} } & 0xFF );
      }
    }
    elsif ( $lcdObj->{type} == 16 ) {    #Device
      $lcdObj->{string} = chr(16) . chr( $c->config->{hap}->getModuleAddress( $lcdObj->{display}->{'HAP-Module'} ) )    
        . chr( $lcdObj->{display}->{'HAP-Device'} ) . &eString( $lcdObj->{display}->{'Label (16 max.)'} );
    }
    elsif ( $lcdObj->{type} == 32 ) {                                                                                   #Thermostat
      $lcdObj->{string} =
          chr(32)
        . chr( $c->config->{hap}->getModuleAddress( $lcdObj->{display}->{'HAP-Module'} ) )
        . chr( $lcdObj->{display}->{'HAP-Device'} )
        . chr( $lcdObj->{display}->{"Refresh (s)"} )
        . &eString( $lcdObj->{display}->{'Label (16 max.)'} );
    }
    $dbData->{offset} = $lcdObj->{offset};

    if ( $count == 0 ) {                                                                                                # add default string to first object
      $dbData->{string} = $defaultString . $lcdObj->{string};
    }
    else {
      $dbData->{string} = $lcdObj->{string};
    }
    utf8::encode( $dbData->{string} );
    $rs = $c->model('hapModel::LcdObjects')->create($dbData);
    $count++;
  }
  $c->stash->{success} = 'true';
  $data->{id}          = $id;
  $c->stash->{data}    = $data;
  $c->forward('View::JSON');
}

sub eString {
  my $str = "@_";
  $str = Encode::encode( "cp437", $str );
  return chr( length($str) ) . $str;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
