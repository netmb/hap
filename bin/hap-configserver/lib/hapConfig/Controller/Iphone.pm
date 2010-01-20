package hapConfig::Controller::Iphone;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Iphone - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;
  my @rooms =
    map { { 'id' => $_->id, 'name' => $_->name, } }
    $c->model('hapModel::Room')
    ->search( { config => $c->session->{config} }, { order_by => "Name ASC" } )
    ->all;
  foreach my $room (@rooms) {
    my @devices =
      map {
      {
        'id'      => $_->id,
        'name'    => $_->name,
        'module'  => $_->module,
        'address' => $_->address,
        'type'    => $_->type
      }
      } $c->model('hapModel::Device')->search( room => $room->{id} )->all;
    foreach (@devices) {
      my $devTmp = $_;
      my $rs     = $c->model('hapModel::Status')->search(
        {
          module  => $devTmp->{module},
          address => $devTmp->{address},
          config  => $c->session->{config}
        },
        { order_by => "TS DESC", rows => 1 }
      )->first;
      if ($rs) {
        $devTmp->{status} = $rs->status;
      }
      else {
        $devTmp->{status} = 0;
      }
      $c->log->debug(
        $_->{module} . "," . $_->{address} . "," . $devTmp->{status} );
    }
    $room->{devices} = \@devices;
  }

  $c->stash->{rooms}    = \@rooms;
  $c->stash->{template} = 'iphone/index.html';
}

sub refresh : Local {
  my ( $self, $c ) = @_;
  my @rooms =
    map { { 'id' => $_->id, 'name' => $_->name, } }
    $c->model('hapModel::Room')
    ->search( { config => $c->session->{config} }, { order_by => "Name ASC" } )
    ->all;
  my @data;
  foreach my $room (@rooms) {
    my @devices =
      map {
      {
        'id'      => $_->id,
        'name'    => $_->name,
        'module'  => $_->module,
        'address' => $_->address,
        'type'    => $_->type
      }
      } $c->model('hapModel::Device')->search( room => $room->{id} )->all;
    foreach (@devices) {
      my $devTmp = $_;
      my $rs     = $c->model('hapModel::Status')->search(
        {
          module  => $devTmp->{module},
          address => $devTmp->{address},
          config  => $c->session->{config}
        },
        { order_by => "TS DESC", rows => 1 }
      )->first;
      my $status = 0;
      if ($rs) {
        $status = $rs->status;
      }
      my $tmp = {};
      if ( $devTmp->{type} > 63 && $devTmp->{type} < 68 ) {
        $tmp->{id} = 'device_' . $_->{module} . "_"
          . $_->{address} . "_" . ( sprintf( "%.0f", $status / 10 ) * 10 );
        $tmp->{status} = $status;
      }
      else {
        $tmp->{id}     = 'device_' . $_->{module} . "_" . $_->{address};
        $tmp->{status} = $status;
      }
      push @data, $tmp;
    }
  }
  $c->stash->{data} = \@data;
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
