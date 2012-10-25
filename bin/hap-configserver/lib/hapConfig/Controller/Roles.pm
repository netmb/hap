package hapConfig::Controller::Roles;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Roles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched hapConfig::Controller::Roles in Roles.');
}

sub get : Local {
	my ( $self, $c ) = @_;
	$c->stash->{roles} =
	  [ map { { 'id' => $_->id, 'role' => $_->role } }
		  $c->model('hapModel::Roles')->all ];
	$c->forward('View::JSON');
}

sub set : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8->decode( $c->request->params->{data} );
	foreach (@$jsonData) {
		my $row  = $_;
		my $data = {
			'id'   => $row->{id},
			'role' => $row->{role},
		};
		my $rs;
		if ( $row->{id} == 0 ) {
			$rs = $c->model('hapModel::Roles')->create($data);
		}
		else {
			$rs =
			  $c->model('hapModel::Roles')->search( id => $row->{id} )
			  ->first;
			$rs->update($data);
		}
	}
	$c->stash->{success} = "true";
	$c->forward('View::JSON');
}

sub delete : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8->decode( $c->request->params->{data} );
	foreach (@$jsonData) {
		my $row = $_;
		my $rs  =
		  $c->model('hapModel::Roles')
		  ->search( id => $row->{id} )    
		  ->delete;
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
