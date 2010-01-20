package hapConfig::Controller::RemoteControl;

use strict;
use warnings;
use base 'Catalyst::Controller';

#use HAP::Log;

=head1 NAME

hapConfig::Controller::RemoteControl - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

#my $log = new HAP::Log( \%c );

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::RemoteControl in RemoteControl.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc = $c->model('hapModel::Remotecontrol')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id     => $rc->id,
			name   => $rc->name,
			room   => $rc->room,
			module => $rc->module,
			config => $c->session->{config}
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
	my $rc = $c->model('hapModel::RemotecontrolLearned')->search( remotecontrol => $id )->delete_all;
	$rc = $c->model('hapModel::Remotecontrol')->search( id => $id )->delete_all;
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
		config => $c->session->{config}
	};
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Remotecontrol')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Remotecontrol')->search( id => $id )->first;
		$rs->update($data);
	}
	$data->{id}          = $rs->id;
	$c->stash->{success} = \1;
	$c->stash->{info}    = "Done.";
	$c->stash->{data}    = $data;     # push back to form via json
	$c->forward('View::JSON');
}

sub learn : Local {
	my ( $self, $c, $key ) = @_;
	my $rc   = $c->model('hapModel::Module')->search( id => $c->request->params->{module} )->first;
	my $cfg  = $c->session->{config};
	my $addr = $rc->address;
	my $sock = new IO::Socket::INET( PeerAddr => $c->config->{MessageProcessor}->{Host}, PeerPort => $c->config->{MessageProcessor}->{Port}, Proto => 'tcp' );
	if ( !$sock ) {
		$c->stash->{success} = \0;
		$c->stash->{info}    = "Cant connect to Message Processor";
	}
	else {
		eval {
			local $SIG{ALRM} = sub { die 'Alarm'; };
			alarm 2;
			my $data = <$sock>;    # Welcome ?
			alarm 0;
		};
		if ($@) {
			$c->stash->{success} = \0;
			$c->stash->{info}    = "Cant connect to Message Processor.";
		}
		else {
			$c->log->debug("destination $addr ir-learn-command $key");
			print $sock "destination $addr ir-learn-command $key\n";
			my $return = <$sock>;

			#my $client = $c->config->{BasePath}."/bin/helper/HAPSendCommand.pl";
			#my $return = `$client -c \"config $cfg destination $addr ir-learn-command $key\"`;

			my $data = {
				code    => 0,
				action  => 0,
				address => 0,
			};
			$c->log->debug($return);
			if ( $return =~ /.*DEV:\s*(\d+).*V1:\s*(\d+).*V2:\s*(\d+)/ ) {
				$data->{code}          = $1;
				$data->{action}        = $2;
				$data->{address}       = $3;
				$data->{name}          = $key;
				$data->{remotecontrol} = $c->request->params->{rcId};
				$data->{module}        = $c->request->params->{module};
				$data->{room}          = $c->request->params->{room};
				$data->{config}        = $c->session->{config};

				my $rs = $c->model('hapModel::RemotecontrolLearned')->search( code => $data->{code}, remotecontrol => $c->request->params->{rcId} )->first;
				if ( !defined($rs) ) {
					$rs = $c->model('hapModel::RemotecontrolLearned')->create($data);
				}
				else {
					$rs->update($data);
				}
				$data                = undef;
				$data->{id}          = $rs->id;
				$data->{code}        = $1;
				$data->{action}      = $2;
				$data->{address}     = $3;
				$data->{keyName}     = $key;
				$c->stash->{success} = \1;

			}
			else {
				$c->stash->{success} = \0;
				$c->stash->{info}    = "Key learning failed.";
			}
			$c->stash->{data} = $data;
		}    
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
