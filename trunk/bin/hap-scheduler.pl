#!/usr/bin/perl

=head1 NAME

hap-scheduler.pl - The Home Automation Project Cron-like Scheduler-Daemon

=cut

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";

use POE;
use POE::Component::Server::TCP;
use POE::Component::EasyDBI;
use Time::Local;
use Schedule::Cron::Events;
use HAP::Init;

my %mapping;
my %wheelToDb;
my $c      = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml", SKIP_DB => 1 );
my $regex  = "hap-sendcmd|hap-configbuilder|hap-firmwarebuilder|hap-lcdguibuilder|hap-dbcleanup";
my %action = (
	'hap-sendcmd'         => $c->{BasePath} . "/bin/helper/hap-sendcmd.pl",
	'hap-configbuilder'   => $c->{BasePath} . "/bin/helper/hap-configbuilder.pl",
	'hap-firmwarebuilder' => $c->{BasePath} . "/bin/helper/hap-firmwarebuilder.pl",
	'hap-lcdguibuilder'   => $c->{BasePath} . "/bin/helper/hap-lcdguibuilder.pl",
	'hap-dbcleanup'       => $c->{BasePath} . "/bin/helper/hap-dbcleanup.pl"
);

POE::Session->create(
	inline_states => {
		_start => sub {
			$_[KERNEL]->alias_set('main');
			$_[KERNEL]->yield('dbGetSchedules');
			$_[KERNEL]->yield( 'dbAddLogEntry', $$, 'hap-scheduler', 'Info', 'Startup complete.' );
		},
		dbAddLogEntry          => \&dbAddLogEntry,
		dbAddSchedule          => \&dbAddSchedule,
		dbDelSchedule          => \&dbDelSchedule,
		dbGetSchedules         => \&dbGetSchedules,
		dbUpdateScheduleStatus => \&dbUpdateScheduleStatus,
		listSchedules          => \&listSchedules,
		addSchedule            => \&addSchedule,
		addAllSchedules        => \&addAllSchedules,
		reloadSchedules        => \&reloadSchedules,
		stopSchedule           => \&stopSchedule,
		deleteSchedule         => \&deleteSchedule,
		runCmd                 => \&runCmd,
		wheelOut               => \&wheelOut,
		wheelClose             => \&wheelClose
	},
);

POE::Component::EasyDBI->new(
	alias    => 'database',
	dsn      => $c->{'Model::hapModel'}->{'connect_info'}[0],
	username => $c->{'Model::hapModel'}->{'connect_info'}[1],
	password => $c->{'Model::hapModel'}->{'connect_info'}[2],
	options  => { autocommit => 1, },
);

POE::Component::Server::TCP->new(
	Alias              => 'tcpServer',
	Port               => $c->{Scheduler}->{Port},
	ClientConnected    => \&tcpClientConnect,
	ClientDisconnected => \&tcpClientDisconnect,
	ClientError        => \&tcpClientDisconnect,
	ClientInput        => \&tcpClientInput,
	InlineStates       => { ClientOutput => \&tcpClientOutput },
);

$poe_kernel->run();

################################################################################
# TCP-Server
################################################################################

sub tcpClientConnect {
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
	print "Session:" . $session->ID . "\n";
	$heap->{client}->put("Home Automation Scheduler 2.0");
}

sub tcpClientDisconnect {
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
}

sub tcpClientInput {
	my ( $kernel, $session, $heap, $data ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
	my $schedule = {};
	if ( $data =~ /add\s+(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)/ ) {
		$schedule = {
			cron       => "$1 $2 $3 $4 $5",
			scriptId   => $6,
			arguments  => $8,
			makro      => $9
		};
		if ($9 == 1) {
		  $schedule->{makroScriptName} = $7;
		}
		else {
		  $schedule->{schedulerScriptName} = $7
		}
		$kernel->post( 'main' => 'dbAddSchedule' => { client => $session->ID, schedule => $schedule } );
	}
	elsif ( $data =~ /delete\s+(.*)/ ) {
		$kernel->post( 'main' => 'dbDelSchedule' => { client => $session->ID, dbId => $1 } );
		$kernel->post( 'main' => 'deleteSchedule' => { client => $session->ID, dbId => $1 } );

	}
	elsif ( $data =~ /list.*/ ) {
		$kernel->post( 'main' => 'dbGetSchedules' => { client => $session->ID } );
	}
	elsif ( $data =~ /stop\s+(.*)/ ) {
		$kernel->post( 'main' => 'stopSchedule' => { client => $session->ID, dbId => $1 } );
	}
	elsif ( $data =~ /reload.*/ ) {
		$kernel->post( 'main' => 'reloadSchedules' => { client => $session->ID } );
		$kernel->post( 'main' => 'dbGetSchedules' => { client => $session->ID } );
	}
	elsif ( $data =~ /help.*/ ) {
		$heap->{client}->put( &getHelp() );
	}
	elsif ( $data =~ /.*quit|exit.*/i ) {
		$kernel->yield('shutdown');
	}
	else {
		$heap->{client}->put("%Unknown command\n");
	}
}

sub tcpClientOutput {
	my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
	$heap->{client}->put($data);
}

################################################################################
# Database
################################################################################

sub dbGetSchedules {
	my ( $kernel, $heap, $session, $stash ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
	my $event = 'listSchedules';
	if ( !$stash->{client} ) {
		$event = 'addAllSchedules';
	}
	$kernel->post(
		'database',
		'arrayhash' => {
			sql   => "SELECT scheduler.ID, Cron, Cmd, makro.name as MakroScriptName, static_schedulercommands.name as SchedulerScriptName, Args, Description,STATUS , Makro, scheduler.Config FROM scheduler LEFT JOIN makro ON makro.ID = scheduler.cmd left join static_schedulercommands on static_schedulercommands.id = scheduler.cmd",
			stash => $stash,
			event => $event,
		},
	);
}

sub dbAddSchedule {
	my ( $kernel, $heap, $session, $stash ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
	$kernel->post(
		'database',
		insert => {
			sql            => 'INSERT INTO scheduler (Cron, Cmd, Args, Config, Makro) VALUES (?,?,?,?,?)',
			placeholders   => [ $stash->{schedule}->{cron}, $stash->{schedule}->{scriptId}, $stash->{schedule}->{arguments}, $stash->{schedule}->{config}, $stash->{schedule}->{makro} ],
			stash          => $stash,
			last_insert_id => 'SELECT LAST_INSERT_ID()',
			event          => 'addSchedule',
		}
	);
}

sub dbDelSchedule {
	my ( $kernel, $heap, $session, $stash ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
	$kernel->post(
		'database',
		do => {
			sql          => 'DELETE FROM scheduler WHERE ID = ?',
			placeholders => [ $stash->{dbId} ],
			stash        => $stash,
			event        => '',
		}
	);
}

sub dbUpdateScheduleStatus {
	my ( $kernel, $heap, $session, $stash ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
	$kernel->post(
		'database',
		do => {
			sql          => 'UPDATE scheduler SET Status=? WHERE ID=?',
			placeholders => [ $stash->{status}, $stash->{dbId} ],
			stash        => $stash,
			event        => '',
		}
	);
}

sub dbAddLogEntry {
	my ( $kernel, $heap, $session, $pid, $source, $type, $message ) = @_[ KERNEL, HEAP, SESSION, ARG0, ARG1, ARG2, ARG3 ];
	my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
	my $time = sprintf( "%4d-%02d-%02d %02d:%02d:%02d ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec );
	$kernel->post(
		'database',
		insert => {
			sql          => 'INSERT INTO log (Time, PID, Source, Type, Message) VALUES (?,?,?,?,?)',
			placeholders => [ $time, $pid, $source, $type, $message ],
			event        => '',
		}
	);
}

################################################################################
# Common
################################################################################

sub listSchedules {
	my ( $kernel, $session, $heap, $dbData ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];    #print $data->{sql} . "\n";
	my $stash = $dbData->{stash};
	my $tmp;
	foreach ( @{ $dbData->{result} } ) {
		$tmp .= "$_->{ID}, $_->{Cron}, $_->{Cmd}, $_->{Args} [$_->{Description}]\n";
	}
	if ($tmp) {
		$kernel->post( $stash->{client} => ClientOutput => "[ACK] Active schedules: \n$tmp" );
	}
	else {
		$kernel->post( $stash->{client} => ClientOutput => "[ACK] No active Schedules. \n" );
	}
}

sub addSchedule {
	my ( $kernel, $session, $heap, $dbData ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
	my $stash = $dbData->{stash};
	$stash->{dbId} = $dbData->{insert_id};
	if ( $stash->{schedule}->{cron} eq "* * * * *" ) {
		$mapping{ $stash->{dbId} }->{oneShot} = 1;
		$mapping{ $stash->{dbId} }->{cronjob} = $kernel->alarm_set( 'runCmd', time(), $stash );
	}
	else {
		my $job = undef;
		eval { $job = new Schedule::Cron::Events( $stash->{schedule}->{cron}, Seconds => time() ) };
		if ($job) {
			$mapping{ $stash->{dbId} }->{cronjob} = $kernel->alarm_set( 'runCmd', timelocal( $job->nextEvent ), $stash );
			$kernel->post( $stash->{client} => ClientOutput => "[ACK] Loaded schedule: $stash->{dbId} \n" );
		}
		else {
			$kernel->post( $stash->{client} => ClientOutput => "[ERR] No valid Cron-String supplied: \n" );
			$kernel->post( 'main' => 'dbDelSchedule' => $stash );
		}
	}
}

sub addAllSchedules {
	my ( $kernel, $session, $heap, $dbData ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
	foreach ( @{ $dbData->{result} } ) {
		my $tmp   = $dbData->{stash};
		my $stash = {%$tmp};
		$stash->{schedule} = {
			cron      => $_->{Cron},
			scriptId   => $_->{Cmd},
			schedulerScriptName => $_->{SchedulerScriptName},
			makroScriptName => $_->{MakroScriptName},
			arguments => $_->{Args},
			makro     => $_->{Makro}
		};
		$stash->{dbId} = $_->{ID};
		if ( $stash->{schedule}->{cron} eq "* * * * *" ) {
			$mapping{ $stash->{dbId} }->{oneShot} = 1;
			$mapping{ $stash->{dbId} }->{cronjob} = $kernel->alarm_set( 'runCmd', time(), $stash );
		}
		else {
			my $job = undef;
			eval { $job = new Schedule::Cron::Events( $stash->{schedule}->{cron}, Seconds => time() ) };
			if ($job) {
				$mapping{ $stash->{dbId} }->{cronjob} = $kernel->alarm_set( 'runCmd', timelocal( $job->nextEvent ), $stash );
				print "Loaded Schedule: $stash->{dbId}, $stash->{schedule}->{cron}, ". ($stash->{schedule}->{schedulerScriptName}||$stash->{schedule}->{makroScriptName}). ", $stash->{schedule}->{arguments} [". ( $_->{Description} || '' ) . "]\n";
			}
		}    
	}
}

sub reloadSchedules {
	my ( $kernel, $session, $heap ) = @_[ KERNEL, SESSION, HEAP ];
	foreach my $id ( keys %mapping ) {
		if ( $mapping{$id}->{cronjob} ) {
			$kernel->alarm_remove( $mapping{$id}->{cronjob} );
			delete $mapping{id};
		}
	}
	$kernel->yield('dbGetSchedules');
}

sub stopSchedule {
	my ( $kernel, $session, $heap, $stash ) = @_[ KERNEL, SESSION, HEAP, ARG0, ARG1 ];
	if ( $mapping{ $stash->{dbId} } && $mapping{ $stash->{dbId} }->{wheel} ) {
		if ( $wheelToDb{ $mapping{ $stash->{dbId} }->{wheel}->ID } ) {
			delete $wheelToDb{ $mapping{ $stash->{dbId} }->{wheel}->ID };
		}
		$mapping{ $stash->{dbId} }->{wheel}->kill(9);
		$kernel->post( $stash->{client} => ClientOutput => "[ACK] Stopped schedule $stash->{dbId}\n" );
	}
	else {
		$kernel->post( $stash->{client} => ClientOutput => "[ERR] Not found or not running $stash->{dbId}\n" );
	}
}

sub deleteSchedule {
	my ( $kernel, $session, $heap, $stash ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
	if ( $mapping{ $stash->{dbId} } && $mapping{ $stash->{dbId} }->{wheel} ) {
		if ( $wheelToDb{ $mapping{ $stash->{dbId} }->{wheel}->ID } ) {
			delete $wheelToDb{ $mapping{ $stash->{dbId} }->{wheel}->ID };
		}
		$mapping{ $stash->{dbId} }->{wheel}->kill(9);
	}
	if ( $mapping{ $stash->{dbId} } && $mapping{ $stash->{dbId} }->{cronjob} ) {
		$kernel->alarm_remove( $mapping{ $stash->{dbId} }->{cronjob} );
	}
	delete $mapping{ $stash->{dbId} };
	if ( !$mapping{ $stash->{dbId} } ) {
		print("Deleted schedule $stash->{dbId}\n");
		$kernel->post( $stash->{client} => ClientOutput => "[ACK] Deleted schedule $stash->{dbId}\n" );
	}
	else {
		print("Schedule $stash->{dbId} not found/loaded\n");
		$kernel->post( $stash->{client} => ClientOutput => "[ERR] Schedule $stash->{dbId} not found/loaded\n" );
	}
}

sub runCmd {
	my ( $kernel, $session, $heap, $stash ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
		my @arguments = split( / /, $stash->{schedule}->{arguments} );
		my $prg;
		if ( $stash->{schedule}->{makro} == 1 ) {
		  $prg = $c->{MacroPath} . '/' . $stash->{schedule}->{scriptId}.".".$stash->{schedule}->{makroScriptName};
		}
		else {
		  $prg = $c->{BasePath} . "/bin/helper/" . $stash->{schedule}->{schedulerScriptName};
		}
		$mapping{ $stash->{dbId} }->{wheel} = POE::Wheel::Run->new(
			Program     => $prg,
			ProgramArgs => \@arguments,
			StdoutEvent => 'wheelOut',
			CloseEvent  => 'wheelClose'
		);
		$wheelToDb{ $mapping{ $stash->{dbId} }->{wheel}->ID } = $stash->{dbId};

		$kernel->alarm_remove( $mapping{ $stash->{dbId} }->{cronjob} );
		if ( !( $stash->{schedule}->{cron} eq "* * * * *" ) ) {
			print "Starting Schedule: $stash->{dbId}, $stash->{schedule}->{cron}, $prg $stash->{schedule}->{arguments}\n";
			my $job = new Schedule::Cron::Events( $stash->{schedule}->{cron}, Seconds => time() );
			$mapping{ $stash->{dbId} }->{cronjob} = $kernel->alarm_set( 'runCmd', timelocal( $job->nextEvent ), $stash );
		}
}

sub wheelOut {
	my ( $kernel, $heap, $input, $wheelId ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
	print "$input\n";
	$kernel->yield( 'dbAddLogEntry', $$, 'hap-scheduler', 'Info', $input );
	if ( $input =~ /^\[(\d+)\%\].*/ ) {
		$kernel->yield( 'dbUpdateScheduleStatus', { dbId => $wheelToDb{$wheelId}, status => $1 } );
	}
}

sub wheelClose {
	my ( $kernel, $heap, $wheelId ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
	print "Child process in wheel $wheelId finished\n";
	my $dbId = $wheelToDb{$wheelId};
	if ( $mapping{$dbId}->{wheel} && $mapping{$dbId}->{wheel}->ID == $wheelId && $mapping{$dbId}->{oneShot} ) { # its an * * * * * -> one shot -> delete from db
		$kernel->yield( 'dbDelSchedule' => { dbId => $dbId } );
		delete $wheelToDb{$wheelId};
	}
}

sub getHelp {
	return "Add a job:    add * * * * * DBId Scriptname Arguments Makro  where (DBId = Database-ID, Makro = 0 or 1) 
Delete a job: delete x
List:         list
Reload:       reload
Quit:         quit|exit\n";
}
