package hapConfig::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;
  $c->stash->{template} = 'main/login.tt2';
}

sub status : Local {
  my ( $self, $c ) = @_;
  if ( $c->user_exists() ) {
    $c->stash->{status} = \1;
    my @roles = $c->user->roles();
    my %roleObj;
    foreach (@roles) {
      $roleObj{$_} = \1;
    }
    $c->stash->{user}  = $c->user->username;
    $c->stash->{roles} = \%roleObj;
  }
  else {
    $c->stash->{status} = \0;
  }
  $c->forward('View::JSON');
}

sub check : Local {
  my ( $self, $c ) = @_;
  my $user = $c->request->params->{user};
  my $pass = $c->request->params->{pass};
  if ( $user && $pass ) {
    if ( $c->login( $user, $pass ) ) {
      $c->stash->{success} = \1;
      my @roles = $c->user->roles();
      my %roleObj;
      foreach (@roles) {
        $roleObj{$_} = \1;
      }
      $c->stash->{roles} = \%roleObj;
      $c->forward('View::JSON');
    }
    else {
      $c->stash->{success} = \0;
      $c->forward('View::JSON');
    }
  }
}

sub checkGui : Local {
  my ( $self, $c ) = @_;
  my $user = $c->request->params->{user};
  my $pass = $c->request->params->{pass};
  if ( $user && $pass ) {
    if ( $c->login( $user, $pass ) ) {
      $c->stash->{success} = \1;
      my @roles = $c->user->roles();
      my %roleObj;
      foreach (@roles) {
        $roleObj{$_} = \1;
      }
      $c->stash->{roles} = \%roleObj;
      $c->forward('/gui/index');
      #$c->response->redirect('/gui');
    }
    else {
      $c->stash->{success} = \0;
      $c->forward('/login/index');
    }
  }
  else {
    $c->forward('/login/index');
  }
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
