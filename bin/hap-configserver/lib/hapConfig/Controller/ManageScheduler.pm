package hapConfig::Controller::ManageScheduler;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Schedule::Cron::Events;
use IO::Socket;

=head1 NAME

hapConfig::Controller::ManageScheduler - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::ManageScheduler in ManageScheduler.');
}

sub getSchedules : Local {
	my ( $self, $c ) = @_;
	my $filter = $c->request->params->{filter};
	$c->stash->{schedules} =
	  [ map { { 'id' => $_->id, 'cron' => $_->cron, 'cmd' => $_->cmd, 'args' => $_->args, 'description' => $_->description, 'status' => $_->status . "%" } }
		  $c->model('hapModel::Scheduler')->search( { cron => { 'like', ( $filter || '%' ) } } )->all ];
	$c->forward('View::JSON');
}

sub setSchedules : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
	my $validCron;
	foreach (@$jsonData) {
		my $row = $_;
		eval { $validCron = new Schedule::Cron::Events( $row->{cron}, Seconds => time() ); };
		if ( !$validCron ) {
			$c->stash->{success} = \0;
			$c->stash->{info}    = "Invalid Cron-String supplied: $_->{id}: $_->{cron}";
			last;
		}
	}
	if ($validCron) {
		foreach (@$jsonData) {
			my $row  = $_;
			my $rs = $c->model('hapModel::StaticSchedulercommands')->search( {id => $row->{cmd}, name => {like => 'hap_%'}} )->first;
			my $isMacro = 0;
			if (!defined($rs)) { # not a native scheduler command -> must be a macro
			  $isMacro = 1;
			}  
			my $data = {
				cron        => $row->{cron},
				cmd         => $row->{cmd},
				args        => $row->{args},
				description => $row->{description},
				makro       => $isMacro,
				config      => $c->session->{config}
			};
			#my $rs;
			if ( $row->{id} == 0 ) {
				$rs = $c->model('hapModel::Scheduler')->create($data);
			}
			else {
				$rs = $c->model('hapModel::Scheduler')->search( id => $row->{id} )->first;
				$rs->update($data);
			}
		}

		my $data;
		my $sock = new IO::Socket::INET( PeerAddr => $c->config->{Scheduler}->{Host}, PeerPort => $c->config->{Scheduler}->{Port}, Proto => 'tcp' );
		if ( !$sock ) {
			$c->stash->{success} = \0;
			$c->stash->{info}    = "Cant connect to Scheduler";
		}
		else {
			eval {
				local $SIG{ALRM} = sub { die 'Alarm'; };
				alarm 1;
				$data = <$sock>;    # Welcome ?
				alarm 0;
			};
			if ($@) {
				$c->stash->{success} = \0;
				$c->stash->{info}    = "Cant connect to Scheduler";
			}
			else {
				print $sock "reload\n";
				$data = <$sock>;
				$sock->autoflush(1);
				$c->stash->{success} = \1;
			}
		}
	}
	$c->forward('View::JSON');
}

sub delSchedules : Local {
	my ( $self, $c ) = @_;
	my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );

	my $data;
	my $sock = new IO::Socket::INET( PeerAddr => $c->config->{Scheduler}->{Host}, PeerPort => $c->config->{Scheduler}->{Port}, Proto => 'tcp' );
	if ( !$sock ) {
		$c->stash->{success} = \0;
		$c->stash->{info}    = "Cant connect to Scheduler";
	}
	else {
		eval {
			local $SIG{ALRM} = sub { die 'Alarm'; };
			alarm 2;
			$data = <$sock>;    # Welcome ?
			alarm 0;
		};
		if ($@) {
			$c->stash->{success} = \0;
			$c->stash->{info}    = "Cant connect to Scheduler";
		}
		else {
			foreach (@$jsonData) {
				print $sock "delete $_->{id}\n";
				$data = <$sock>;
				$sock->autoflush(1);
			}
			$c->stash->{success} = \1;
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
