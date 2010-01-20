#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-lcdguibuilder.pl -  The Home Automation Project LCD-GUI-Builder-Wrapper-Script

=cut

use warnings;
use strict;
use Getopt::Long;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use IO::Socket;

use HAP::Init;
use HAP::LcdGuiBuilder;

my $modules = 0;
my $flash;
GetOptions( "modules|m=s" => \$modules, "flash|transmit|f|t" => \$flash ) or die;
die "Missing Module-Parameter [--modules|m]\n" unless $modules;

my $c       = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );
my $builder = new HAP::LcdGuiBuilder($c);

my @m          = split( /,/, $modules );
my $batchCount = scalar(@m);

my $host = $c->{MessageProcessor}->{Host};
my $port = $c->{MessageProcessor}->{Port};
my $sock = new IO::Socket::INET( PeerAddr => $host, PeerPort => $port, Proto => 'tcp' );
$sock or die "Can\'t connect to Message-Processor:$!";
eval {
	local $SIG{ALRM} = sub { die 'Alarm'; };
	alarm 1;
	my $object = <$sock>;
	alarm 0;
};
if ($@) {
	print "Can\'t connect to Message-Processor\n";
	exit 1;
}

my $errorCount = 0;

my $batch = 0;
foreach (@m) {
	$builder->buildLcdGui($_);
	my ( $commands, $cmdCount ) = $builder->prepareTransfer();
	my $counter = 1;
	foreach (@$commands) {
		&transmit( $batch, $counter++, $cmdCount, $_ );
	}
	while ( my $commands = $builder->getFirmwarePage() ) {
		my $i = 0;
		foreach (@$commands) {
			$counter++;
			select( undef, undef, undef, 0.010 ) if ($flash);
			if ( $i == 9 ) {
				if ( !&transmit( $batch, $counter, $cmdCount, $_ ) ) {
					$counter -= 10;
					$errorCount++;
					die "Destination does not answer for the last 20 tries. Exit" if ( $errorCount > 20 );
					$builder->previousPage();
				}
			}
			else {
				if ($flash) {
					print $sock "$_\n";
				}
				else {
					print "$_\n";
				}
			}
			$i++;
		}
	}
	$commands = $builder->finishTransfer();
	foreach (@$commands) {
		&transmit( $batch, $counter++, $cmdCount, $_ );
	}
	$batch++;
}

$sock->close();
exit 0;

sub transmit {
	my ( $batch, $counter, $cmdCount, $cmd ) = @_;
	my $percentPerBatch = int( 100 / $batchCount );
	my $basePercent     = $percentPerBatch * $batch;
	my $current         = int( ( $counter * $percentPerBatch ) / $cmdCount + $basePercent );
	print "$cmd\n";
	if ($flash) {
		print $sock "$cmd\n";
		my $res = <$sock>;
		print "[$current%] $res";

		if ( $res =~ /.*\[ACK\].*/ ) {
			return 1;
		}
		else {
			return 0;
		}
	}
	else {
		return 1;
	}
}
