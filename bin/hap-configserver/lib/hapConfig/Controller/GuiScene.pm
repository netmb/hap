package hapConfig::Controller::GuiScene;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::GuiScene - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::GuiScene in GuiScene.');
}

sub get : Local {
  my ( $self, $c, $id ) = @_;
  if ( $id != 0 ) {
    my $rc = $c->model('hapModel::GuiScene')->search( id => $id )->first;
    $c->stash->{success} = 'true';

    $c->stash->{data} = {
      id        => $rc->id,
      name      => $rc->name,
      isDefault => $rc->isdefault,
      centerX   => $rc->centerx,            
      centerY   => $rc->centery,
      viewId    => $rc->viewid,
      config    => $c->session->{config},
    };
    my @objects;
    my @rc = $c->model('hapModel::GuiObjects')->search( sceneid => $id )->all;
    foreach (@rc) {
      my $tmp = JSON::XS->new->utf8(0)->decode( $_->configobject );
      push @objects,
        {
        type    => $_->type,
        id      => $_->id,
        display => $tmp
        };
    }
    $c->stash->{data}->{objects} = \@objects;
  }
  if ( $id == 0 ) {
    $c->stash->{data} = {};    # required for extjs
    if ( $c->request->params->{viewId} ne 'undefined' ) {
      $c->stash->{data} = { viewId => $c->request->params->{viewId} };
    }
    $c->stash->{success} = 'true';
  }
  $c->forward('View::JSON');
}

sub delete : Local {
  my ( $self, $c, $id ) = @_;
  my $rc = $c->model('hapModel::GuiScene')->search( id => $id )->delete_all;
  $rc = $c->model('hapModel::GuiObjects')->search( sceneid => $id )->delete_all;
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
    name      => $c->request->params->{name},
    isdefault => $c->request->params->{isDefault},
    centerx   => $c->request->params->{centerX},
    centery   => $c->request->params->{centerY},
    viewid    => $c->request->params->{viewId},
    config    => $c->session->{config}
  };
  my $rs;
  if ( $id == 0 ) {
    $rs = $c->model('hapModel::GuiScene')->create($data);
    $id = $rs->id;
  }
  else {
    $rs = $c->model('hapModel::GuiScene')->search( id => $id )->first;
    $rs->update($data);
    my $rc = $c->model('hapModel::GuiObjects')->search( sceneid => $id )->delete_all;
  }
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
    my $obj = undef;
    $obj->{sceneid} = $id;
    $obj->{type}    = $_->{type};
    $c->log->debug($_->{type});
    $obj->{configobject} = JSON::XS->new->utf8(0)->encode( $_->{display} );
    $obj->{config}       = $c->session->{config};
    $c->model('hapModel::GuiObjects')->create($obj);

  }
  $data->{id}          = $id;
  $c->stash->{success} = \1;
  $c->stash->{info}    = "Done.";
  $c->stash->{data}    = $data;     # push back to form via json
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
