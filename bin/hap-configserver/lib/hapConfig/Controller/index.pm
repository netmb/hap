package hapConfig::Controller::index;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::index - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;
  $c->stash->{configs} = [ $c->model('hapModel::Config')->all ];
  $c->stash->{devices} =
    [ $c->model('hapModel::Device')->search( config => $c->session->{config} )->all ];    
  $c->stash->{selectedConfig} = $c->session->{config};
  $c->stash->{template}       = 'index.html.tt2';
}

sub selectedConfig : Local {
  my ( $self, $c, $config ) = @_;
  $c->session->{config} = $config;
  $c->forward('index');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
