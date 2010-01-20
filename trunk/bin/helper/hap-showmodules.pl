#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-showmodules.pl -  The Home Automation Project Show-Modules-Script

=cut

use warnings;
use strict;
use FindBin ();
use Getopt::Long; 
use lib "$FindBin::Bin/../../lib";
use HAP::Init;
my $c = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );

my $config = undef;
GetOptions( "config|c=i" => \$config ) or die ;

if (!$config) {
 $config = $c->{DefaultConfig};
}
my $sth = $c->{dbh}->prepare("Select ID, Address from module WHERE Config=$config order by Address ASC");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
 print "Address: $ref->{Address}\t => ID: $ref->{ID}\n";
}

exit 0;
