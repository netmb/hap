package hapConfig::Controller::ManageMakroByDatagram;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

hapConfig::Controller::ManageMakroByDatagram - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::ManageMakroByDatagram in ManageMakroByDatagram.');
}

sub get : Local {
  my ( $self, $c, $id ) = @_;
  if ( $id != 0 ) {
    my $rc = $c->model('hapModel::MakroByDatagram')->search( id => $id )->first;
    $c->stash->{success} = 'true';
    $c->stash->{data}    = {
      id          => $rc->id,
      active      => $rc->active,
      description => $rc->description,
      source      => $rc->source,
      destination => $rc->destination,
      mtype       => $rc->mtype,
      address     => $rc->address,
      v0          => $rc->v0,
      v1          => $rc->v1,
      v2          => $rc->v2,
      makro       => $rc->makro,
      config      => $c->session->{config}
    };
  }
  
  if ( $id == 0 ) {
    $c->stash->{data}    = {};       # required for extjs
    $c->stash->{success} = 'true';
  }
  $c->forward('View::JSON');
}

sub delete : Local {
  my ( $self, $c ) = @_;
  my $id = 0;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  my $rc = 1;
  foreach (@$jsonData) {
    $rc = $c->model('hapModel::MakroByDatagram')->search( id => $_->{id} )->delete_all;
    if ($rc != 1) {
      $id = $_->id;
      last;
    }
  }
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
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
    my $row  = $_;
    my $rs   = $c->model('hapModel::MakroByDatagram')->search( id => $row->{id} )->first;
    my $data = {
      active      => $row->{active},
      description => $row->{description},
      source      => $row->{source},
      destination => $row->{destination},
      mtype       => $row->{mtype},
      address     => $row->{address},
      v0          => $row->{v0},
      v1          => $row->{v1},
      v2          => $row->{v2},
      makro       => $row->{makro},
      config      => $c->session->{config}
    };
    if ( $row->{id} == 0 ) {
      $rs = $c->model('hapModel::MakroByDatagram')->create($data);
    }
    else {
      $rs = $c->model('hapModel::MakroByDatagram')->search( id => $row->{id} )->first;
      $rs->update($data);
    }
  }
  $c->stash->{success} = \1;
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

