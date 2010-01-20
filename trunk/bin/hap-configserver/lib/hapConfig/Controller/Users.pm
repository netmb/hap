package hapConfig::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Digest::SHA;

=head1 NAME

hapConfig::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched hapConfig::Controller::Users in Users.');
}

sub get : Local {
  my ( $self, $c ) = @_;
  $c->stash->{users} = [
    map {
      {
        'id'        => $_->id,
        'username'  => $_->username,
        'password'  => $_->password,
        'prename'   => $_->prename,
        'surname'   => $_->surname,
        'email'     => $_->email,
        'password1' => 'XXXXXXXX',
        'password2' => 'XXXXXXXX'
      }
      } $c->model('hapModel::Users')->all
  ];
  $c->forward('View::JSON');
}

sub getUserRoles : Local {
  my ( $self, $c ) = @_;
  my $roles = [ map { { 'id' => $_->id, 'role' => $_->role, 'status' => \0 } } $c->model('hapModel::Roles')->all ];
  my $userRoles = [ map { { 'roleId' => $_->role } } $c->model('hapModel::UsersRoles')->search( user => $c->request->params->{id} ) ];
  foreach (@$roles) {
    my $rolesObj = $_;
    foreach (@$userRoles) {
      my $userRoleObj = $_;
      if ( $rolesObj->{id} == $userRoleObj->{roleId} ) {
        $rolesObj->{status} = \1;
      }
    }
  }
  $c->stash->{userRoles} = $roles;
  $c->forward('View::JSON');
}

sub submit : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
    my $row  = $_;  
    my $data = {
      'username' => $row->{username},
      'password' => $row->{password},
      'prename'  => $row->{prename},
      'surname'  => $row->{surname},
      'email'    => $row->{email},
    };
    if ( $row->{password1} ne 'XXXXXXXX' && $row->{password2} ne 'XXXXXXXX' ) {
      $data->{password} = Digest::SHA::sha1_hex( $row->{password1} );
    }
    if ($row->{id} != 0) {
     $data->{id} = $row->{id};
    }
    my $rs = $c->model('hapModel::Users')->update_or_create($data);
    $row->{id} = $rs->id;

    my $r = $row->{roles};
    foreach (@$r) {
      my $rowRoles = $_;
      if ( $rowRoles->{status}  == 1 ) {
        my $rs = $c->model('hapModel::UsersRoles')->create( { user => $row->{id}, role => $rowRoles->{id} } );
      }
      else {
        my $rs = $c->model('hapModel::UsersRoles')->search( { user => $row->{id}, role => $rowRoles->{id} } )->delete;
      }
    }
  }    
  $c->stash->{success} = "true";
  $c->forward('View::JSON');
}

sub setUserPassword : Local {
  my ( $self, $c ) = @_;
  my $rs = $c->model('hapModel::Users')->search( username => $c->user->id )->first;
  $rs->update( { password => Digest::SHA::sha1_hex( $c->request->params->{password} ) } );
  $c->stash->{success} = "true";
  $c->forward('View::JSON');
}

sub delete : Local {
  my ( $self, $c ) = @_;
  my $jsonData = JSON::XS->new->utf8->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
    my $row         = $_;
    my $rs          = $c->model('hapModel::Users')->search( id => $row->{id} )->delete;
    my $rsUserRoles = $c->model('hapModel::UsersRoles')->search( user => $row->{id} )->delete;
  }
  $c->stash->{success} = "true";
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
