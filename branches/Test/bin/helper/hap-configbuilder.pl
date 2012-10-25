#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-configbuilder.pl -  The Home Automation Project Config-Builder-Wrapper-Script

=cut

use warnings;
use strict;
use Getopt::Long;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use IO::Socket::INET;

use HAP::Init;
use HAP::ConfigBuilder;

my $modules = 0;
my $flash;
GetOptions( "module|module|m=s" => \$modules, "flash|transmit|f|t" => \$flash ) or die;
die "Missing Module-Parameter [--module|m]\n" unless $modules;

my $c       = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );
my $builder = new HAP::ConfigBuilder($c);

if ($flash) {
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

	my @m = split( /,/, $modules );
	foreach (@m) {
		my $commands = $builder->create($_);
		my $lines    = scalar(@$commands);
		my $i        = 0;
		foreach (@$commands) {
			$i++;
			print $_ . "\n";
			print $sock $_ . "\n";
			my $res = <$sock>;
			print "[" . sprintf( "%.0f", ( $i * 100 / $lines ) ) . "%] $res";
		}
	}
	$sock->close();
}
else {    # dump it out
	my @m = split( /,/, $modules );
	foreach (@m) {
		my $commands = $builder->create($_);
		my $lines    = scalar(@$commands);
		foreach (@$commands) {
			print $_. "\n";
		}
	}
}
exit 0;

