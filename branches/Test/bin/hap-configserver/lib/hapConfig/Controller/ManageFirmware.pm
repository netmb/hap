package hapConfig::Controller::ManageFirmware;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::ManageFirmware - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::ManageFirmware in ManageFirmware.');
}

sub getFirmware : Local {
	my ( $self, $c ) = @_;
	$c->stash->{firmware} = [
		map {
			{
				'id'             => $_->id,
				'precompiled'    => ($_->precompiled || 0) + 0,
				'compileoptions' => ($_->compileoptions || 0) + 0,
				'name'           => $_->name,
				'version'        => $_->vmajor . "." . $_->vminor . "." . $_->vphase,
				'filename'       => $_->filename,
				'date'           => $_->date
			}
		  } $c->model('hapModel::Firmware')->all
	];
	$c->forward('View::JSON');
}

sub setFirmware : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
	foreach (@$jsonData) {
		my $row = $_;
		my $data = { name => $row->{name} };
		my $rs;
		if ( $row->{id} == 0 ) {
			$rs = $c->model('hapModel::Firmware')->create($data);
		}
		else {
			$rs = $c->model('hapModel::Firmware')->search( id => $row->{id} )->first;
			$rs->update($data);
		}
	}
	$c->stash->{success} = \1;
	$c->forward('View::JSON');
}

sub delFirmware : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
	my $error    = undef;
	foreach (@$jsonData) {
		my $m = $c->model('hapModel::Module')->search( firmwareid => $_->{id} )->first;
		if ($m) {
			$error = "Module \'".$m->name."\' in Config \'".$m->config."\' is associated with that firmware. Change this first !";
		}
		else {
			my $rc = $c->model('hapModel::Firmware')->search( id => $_->{id} )->delete_all;
		}
	}
	if ($error) {
		$c->stash->{success} = \0;
		$c->stash->{info}    = $error;    
	}
	else {
		$c->stash->{success} = \1;
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
