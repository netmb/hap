package hapConfig::Controller::RotaryEncoder;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::RotaryEncoder - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body(
		'Matched hapConfig::Controller::RotaryEncoder in RotaryEncoder.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc =
		  $c->model('hapModel::Abstractdevice')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id           => $rc->id,
			name         => $rc->name,
			room         => $rc->room,
			module       => $rc->module,
			address      => $rc->address,
			childdevice0 => $rc->childdevice0,
			childdevice1 => $rc->childdevice1,
			childdevice2 => $rc->childdevice2,
			childdevice3 => $rc->childdevice3,
			attrib2      => $rc->attrib2,
			notify       => $rc->notify,
			config       => $c->session->{config}
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
	if ( $id == 0 ) {
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
	  $c->model('hapModel::Abstracdevice')->search( id => $id )->delete_all;
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
	my @portPin = split( /-/, $c->request->params->{portPin} );
	my $data = {
		name         => $c->request->params->{name},
		room         => $c->request->params->{room},
		module       => $c->request->params->{module},
		address      => $c->request->params->{address},
		type         => 96,
		subtype      => 224,
		childdevice0 => $c->request->params->{childdevice0},
		childdevice1 => $c->request->params->{childdevice1},
		childdevice2 => $c->request->params->{childdevice2},
		childdevice3 => $c->request->params->{childdevice3},
		attrib2      => $c->request->params->{attrib2},
		notify       => $c->request->params->{notify},
		config       => $c->session->{config}
	};
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Abstractdevice')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Abstractdevice')->search( id => $id )->first;
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
