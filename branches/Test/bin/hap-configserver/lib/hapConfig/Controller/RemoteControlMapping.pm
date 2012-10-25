package hapConfig::Controller::RemoteControlMapping;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::RemoteControlMapping - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body(
		'Matched hapConfig::Controller::RemoteControlMapping in RemoteControl.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc =
		  $c->model('hapModel::RemotecontrolMapping')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id             => $rc->id,
			name           => $rc->name,
			room           => $rc->room,
			module         => $rc->module,
			irkey          => $rc->irkey,
			destdevice     => $rc->destdevice,
			destvirtmodule => $rc->destvirtmodule,
			destmakronr    => $rc->destmakronr,
			config         => $c->session->{config}
		};
	}
	if ( $id == 0 ) {
		$c->stash->{data} = {};    # required for extjs
		if ( $c->request->params->{module} ne 'undefined' ) {
			$c->stash->{data} = { module => $c->request->params->{module} };
		}
		elsif ( $c->request->params->{room} ne 'undefined' ) {
			$c->stash->{data} = { room => $c->request->params->{room} };
		}
		$c->stash->{success} = 'true';
	}
	$c->forward('View::JSON');
}

sub delete : Local {
	my ( $self, $c, $id ) = @_;
	my $rc =
	  $c->model('hapModel::RemotecontrolMapping')->search( id => $id )->delete_all;
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
		name   => $c->request->params->{name},
		room   => $c->request->params->{room},
		module => $c->request->params->{module},
		irkey  => $c->request->params->{irkey},
		config => $c->session->{config}
	};
	$data->{destdevice}     = 0;
	$data->{destvirtmodule} = 0;
	$data->{destmakronr}    = 0;
	if ( $c->request->params->{type} eq "standardOutputs" ) {
		$data->{destdevice} = $c->request->params->{destdevice};
	}
	if ( $c->request->params->{type} eq "makro" ) {
		$data->{destmakronr} = $c->request->params->{destmakronr};
	}
	if ( $c->request->params->{type} eq "shutter" ) {
		$data->{destvirtmodule} = $c->request->params->{destvirtmodule};
	}
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::RemotecontrolMapping')->create($data);
	}
	else {
		$rs = $c->model('hapModel::RemotecontrolMapping')->search( id => $id )->first;
		$rs->update($data);
	}
	$data->{id}          = $rs->id;
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
