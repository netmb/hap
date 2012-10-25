package hapConfig::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

hapConfig::Controller::Root - Root Controller for hapConfig

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'main/index.tt2';
}

sub access_denied : Private {
  my ( $self, $c ) = @_;
  $c->stash->{success} = \0;
  $c->stash->{permissiondenied} = \1;
  if ($c->session_expires == 0) {
  	$c->stash->{sessionexpired} = \1;
  }
  $c->forward('View::JSON');
}   

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
