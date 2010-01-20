package hapConfig::Controller::LogicalInput;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::LogicalInput - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::LogicalInput in LogicalInput.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc = $c->model('hapModel::Logicalinput')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id                 => $rc->id,
			name               => $rc->name,
			room               => $rc->room,
			module             => $rc->module,
			address            => $rc->address,
			portPin            => $rc->port . "-" . $rc->pin,
			notify             => $rc->notify,
			formula            => $rc->formula,
			formuladescription => $rc->formuladescription,
			config             => $c->session->{config}
		};
		my $type = $rc->type;

		#if ( ( $type & 12 ) == 12 ) {
		#	$c->stash->{data}->{"type/12"} = 1;
		#}
		for ( my $i = 0 ; $i < 6 ; $i++ ) {
			if ( $type & ( 2**$i ) ) {
				if ( 2**$i == 0 || 2**$i == 4 || 2**$i == 8 ) {
					$c->stash->{data}->{"type/x"} = ( 2**$i );
				}
				else {
					$c->stash->{data}->{ "type/" . ( 2**$i ) } = 1;
				}
			}
		}
		if ( ($type & 12) == 12 ) {
			$c->stash->{data}->{"type/x"} = 12;
		}
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
	my $rc = $c->model('hapModel::Logicalinput')->search( id => $id )->delete_all;
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
		name    => $c->request->params->{name},
		room    => $c->request->params->{room},
		module  => $c->request->params->{module},
		address => $c->request->params->{address},
		port    => $portPin[0],
		pin     => $portPin[1],

		#type               => $c->request->params->{type},
		notify             => $c->request->params->{notify},
		formula            => $c->request->params->{formula},
		formuladescription => $c->request->params->{formuladescription},
		config             => $c->session->{config}
	};
	my $type     = 128;
	my $paramRef = $c->request->params;
	foreach my $key (%$paramRef) {
		$type |= $1 if ( $key =~ /type\/(\d+)/ );    # check-boxes
	}
	$type |= $c->request->params->{'type/x'};        # radio-group
	$data->{type} = $type;
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Logicalinput')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Logicalinput')->search( id => $id )->first;
		$rs->update($data);
	}
	$data->{id}          = $rs->id;
	$c->stash->{success} = \1;
	$c->stash->{info}    = "Done.";
	$c->stash->{data}    = $data;     # push back to form via json
	$c->forward('View::JSON');
}

sub getCheckedCheckboxes : Local {
	my ( $self, $c, $id ) = @_;
	$c->stash->{success} = \1;
	$c->stash->{info}    = "Done.";
	my $type = $c->model('hapModel::StaticLogicalinputtemplates')->search( id => $id )->first->type;

	#if ( ( $type & 12 ) == 12 ) {
	#	$c->stash->{data}->{"type/12"} = 1;
	#}
	#else {
	#  $c->stash->{data}->{"type/12"} = 0;
	#}
	for ( my $i = 0 ; $i < 6 ; $i++ ) {
		if ( $type & ( 2**$i ) ) {
			if ( 2**$i == 0 || 2**$i == 4 || 2**$i == 8 ) {
				$c->stash->{data}->{"type/x"} = ( 2**$i );
			}
			else {
				$c->stash->{data}->{ "type/" . ( 2**$i ) } = 1;
			}
		}
		else {
			$c->stash->{data}->{ "type/" . ( 2**$i ) } = 0;
		}
	}
	if ( $type & 12 == 12 ) {
		$c->stash->{data}->{"type/x"} = 12;
	}
	$c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
