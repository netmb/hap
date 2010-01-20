#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-sendcmd2.pl -  The Home Automation Project Send-Command Script (small version)

=cut

use IO::Socket::INET;
my $host = "localhost";
my $port = "7891";
my $sock = new IO::Socket::INET( PeerAddr => $host, PeerPort => $port, Proto => 'tcp' );
$sock or die "No socket :$!";
my $obj = <$sock>;
print $sock $ARGV[0]."\n";
print <$sock>."\n";
close $sock;
exit;
