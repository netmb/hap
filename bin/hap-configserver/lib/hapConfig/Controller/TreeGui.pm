package hapConfig::Controller::TreeGui;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::TreeGui - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched hapConfig::Controller::TreeGui in TreeGui.');
}
sub getTreeNodes : Local {
  my ( $self, $c ) = @_;
  my $config = $c->session->{config};
  my @views = $c->model('hapModel::GuiView')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @tree;
  foreach (@views) {
    my $viewName = $_->name;
    my $viewId   = $_->id;

    my @childs = $c->model('hapModel::GuiScene')->search( { config => $config, viewid => $viewId }, { order_by => 'Name ASC' } );
    my @childrenObjects = map { { id => "guiscene/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    unshift(@childrenObjects, {id => "guiscene/0/$viewId", text => "New Scene", viewId => $viewId, leaf=>\1});
    push @tree, { id => "guiview/" . $viewId, text => $viewName, children => \@childrenObjects };
  }

  $c->response->body( JSON::XS->new->utf8(0)->encode (\@tree) );
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
