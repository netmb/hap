package hapConfig::Controller::TreeMacro;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::TreeMacro - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::TreeMacro in TreeMacro.');
}

sub getTreeNodes : Local {
  my ( $self, $c ) = @_;    
  my $config = $c->session->{config};
  my @macros;
  @macros =
    map { { id => "macro/" . $_->id, text => $_->name . " [" . $_->id . "]", leaf => 'true', scriptName => $_->id . "." . $_->name } } $c->model('hapModel::Makro')->search( { config => $config }, { order_by => 'Name ASC' } );
  $c->response->body( JSON::XS->new->utf8(0)->encode( \@macros ) );
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
