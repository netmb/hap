package hapConfig::Controller::Macro;

use strict;
use warnings;
use File::Glob qw(:glob);
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Macro - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::Macro in Macro.');
}

sub get : Local {
  my ( $self, $c, $id ) = @_;
  if ( $id != 0 ) {
    my $rc = $c->model('hapModel::Makro')->search( id => $id )->first;
    $c->stash->{success} = 'true';
    $c->stash->{data}    = {
      id      => $rc->id,
      name    => $rc->name,
      macronr => $rc->makronr,
      config  => $c->session->{config}
    };
  }
  local ( $/, *MF );
  open( MF, "<" . $c->config->{MacroPath} . "/" . $c->stash->{data}->{id} . "." . $c->stash->{data}->{name} );
  my $slurp = <MF>;
  close MF;
  $c->stash->{data}->{script} = $slurp;
  $c->forward('View::JSON');
}

sub delete : Local {
  my ( $self, $c, $id ) = @_;
  my $rc = $c->model('hapModel::Makro')->search( id => $id )->delete_all;
  if ( $rc == 1 ) {
    $c->stash->{success} = \1;
    $c->stash->{info}    = "Deleted: DB-ID : $id";
  }
  else {
    $c->stash->{success} = \0;
    $c->stash->{info}    = "Failed!: DB-ID : $id";
  }
  my $old = $c->config->{MacroPath} . "/$id.*";
  unlink( glob($old) );
  $c->forward('View::JSON');
}

sub submit : Local {
  my ( $self, $c, $id ) = @_;
  my $data = {
    name    => $c->request->params->{name},
    makronr => $c->request->params->{macronr},
    config  => $c->session->{config}
  };

  my $rs;
  if ( $id == 0 ) {
    $rs = $c->model('hapModel::Makro')->create($data);
  }
  else {
    $rs = $c->model('hapModel::Makro')->search( id => $id )->first;
    $rs->update($data);
  }
  $data->{id} = $rs->id;
  my $old = $c->config->{MacroPath} . "/$rs->id.*";
  unlink( glob($old) );
  open( MF, ">" . $c->config->{MacroPath} . "/" . $rs->id . "." . $c->request->params->{name} );
  print MF $c->request->params->{script};    
  close MF;
  chmod 0744, $c->config->{MacroPath} . "/" . $rs->id . "." . $c->request->params->{name} ;
  $c->stash->{success} = \1;
  $c->stash->{info}    = "Done.";
  $c->stash->{data}    = $data;              # push back to form via json
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
