package hapConfig::Controller::AnalogInput;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::AnalogInput - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body(
		'Matched hapConfig::Controller::AnalogInput in AnalogInput.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc = $c->model('hapModel::Analoginput')->search( id => $id )->first;
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
			correction         => $rc->correction,
			unit               => $rc->unit,
			measure            => $rc->measure,
			trigger0           => $rc->trigger0,
			trigger0hyst       => $rc->trigger0hyst,
			trigger1           => $rc->trigger1,
			trigger1hyst       => $rc->trigger1hyst,
			samplerate         => $rc->samplerate,
			config             => $c->session->{config}
		};
		my $trigger0notify = $rc->trigger0notify;
		my $trigger1notify = $rc->trigger1notify;
		for ( my $i = 2 ; $i < 4 ; $i++ ) {
			if ( $trigger0notify & ( 2**$i ) ) {
				$c->stash->{data}->{ "trigger0notify/" . ( 2**$i ) } = 1;
			}
			if ( $trigger1notify & ( 2**$i ) ) {
				$c->stash->{data}->{ "trigger1notify/" . ( 2**$i ) } = 1;
			}
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
	my $rc =
	  $c->model('hapModel::Analoginput')->search( id => $id )->delete_all;
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
		name               => $c->request->params->{name},
		room               => $c->request->params->{room},
		module             => $c->request->params->{module},
		address            => $c->request->params->{address},
		port               => $portPin[0],
		pin                => $portPin[1],
		notify             => $c->request->params->{notify},
		formula            => $c->request->params->{formula},
		formuladescription => $c->request->params->{formuladescription},
		correction         => $c->request->params->{correction},
		unit               => $c->request->params->{unit},
		measure            => $c->request->params->{measure},
		trigger0           => $c->request->params->{trigger0},
		trigger0hyst       => $c->request->params->{trigger0hyst},
		trigger1           => $c->request->params->{trigger1},
		trigger1hyst       => $c->request->params->{trigger1hyst},
		samplerate         => $c->request->params->{samplerate},
		config             => $c->session->{config}
	};
	my $trigger0notify = 0;
	my $trigger1notify = 0;
	my $paramRef       = $c->request->params;
	foreach my $key (%$paramRef) {
		$trigger0notify |= $1 if ( $key =~ /trigger0notify\/(.*)/ );
		$trigger1notify |= $1 if ( $key =~ /trigger1notify\/(.*)/ );
	}
	$data->{trigger0notify} = $trigger0notify;
	$data->{trigger1notify} = $trigger1notify;

	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Analoginput')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Analoginput')->search( id => $id )->first;
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
