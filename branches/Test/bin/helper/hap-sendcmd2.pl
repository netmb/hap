#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-sendcmd2.pl -  The Home Automation Project Send-Command Script (small version)

=cut

use IO::Socket::INET;
my $retransmits = 5;
my $host = "localhost";
my $port = "7891";
my $sock = new IO::Socket::INET( PeerAddr => $host, PeerPort => $port, Proto => 'tcp' );
$sock or die "No socket :$!";
my $obj = <$sock>;
print $sock $ARGV[0]."\n";
my $res = <$sock>;
my $i = 0;
while ($res =~ /.*\[ERR\].*/ && $i < $retransmits ) {
  print $sock $ARGV[0]."\n";
  my $res = <$sock>;
  $i++;
}
print $res."\n";
close $sock;
exit;
