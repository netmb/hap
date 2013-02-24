package hapConfig::Controller::Homematic;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

hapConfig::Controller::Homematic - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index : Private {    # parse index.html
	my ( $self, $c ) = @_;

}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc = $c->model('hapModel::Homematic')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id                 => $rc->id,
			name               => $rc->name,
			room               => $rc->room,
			module             => $rc->module,
			address            => $rc->address,
			homematicaddress   => $rc->homematicaddress,
			homematicdevicetype => $rc->homematicdevicetype,
			notify             => $rc->notify,
			channel            => $rc->channel,
			formula            => $rc->formula,
			formuladescription => $rc->formuladescription,
			config             => $c->session->{config}
		};
	}
	if ( $id == 0 ) {
		$c->stash->{data} = {}; # required for extjs
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
	my $rc = $c->model('hapModel::Homematic')->search( id => $id )->delete_all;
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
		name               => $c->request->params->{name},
		room               => $c->request->params->{room},
		module             => $c->request->params->{module},
		address            => $c->request->params->{address},
		homematicaddress   => $c->request->params->{homematicaddress},
		homematicdevicetype => $c->request->params->{homematicdevicetype},
		notify             => $c->request->params->{notify},
		channel            => $c->request->params->{channel},
		formula            => $c->request->params->{formula},
		formuladescription => $c->request->params->{formuladescription},
		config             => $c->session->{config}
	};

	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Homematic')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Homematic')->search( id => $id )->first;
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

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

