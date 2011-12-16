#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-sendcmd.pl -  The Home Automation Project Send-Command Script

=cut

use warnings;
use strict;
use Getopt::Long;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use IO::Socket::INET;

use HAP::Init;
use HAP::ConfigBuilder;

my $command;
my $retransmits = 5;
GetOptions( "command|c=s" => \$command ) or die;
die "Missing Command-Parameter [--command|-c]\n" unless $command;

my $c = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );
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
else {
	print $sock $command . "\n";
	my $res = <$sock>;
	my $i = 0;
	while ($res =~ /.*\[ERR\].*/ && $i < $retransmits ) {
	  print $sock $command . "\n";
	  my $res = <$sock>;
	  $i++;
	}
	print "[100%] $res";
	$sock->close();
}
exit 0;    
