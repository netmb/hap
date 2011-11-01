#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-dbcleanup.pl -  The Home Automation Project DB-Cleanup-Script

=cut

use warnings;
use strict;
use FindBin ();
use Getopt::Long; 
use lib "$FindBin::Bin/../../lib";
use HAP::Init;

my $logDays;
my $statusDays;
GetOptions( "logdays|ld=s" => \$logDays, "statusdays|sd=s" => \$statusDays ) or die;

die "Missing logdays [--logdays|ld] or statusdays [--statusdays|sd] Parameter\n" if (!$logDays && !$statusDays);

my $c = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );

if ($logDays) {
  my $lTime = time - $logDays*86400;
  my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime($lTime);
  $lTime = sprintf(
      "%4d-%02d-%02d %02d:%02d:%02d ",
      $year + 1900,
      $mon + 1, $mday, $hour, $min, $sec
  );
  my $sth = $c->{dbh}->prepare("Delete from log where Time < \"$lTime\"");
  $sth->execute();
}
if ($statusDays) {
  my $sTime = time - $statusDays*86400;
  my $sth = $c->{dbh}->prepare("Delete from status where TS < $sTime");
  $sth->execute();
}
exit 0;
