#!/usr/bin/perl
my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = localtime(time);
if ( $wday == 0 ) {
  $wday = 6;
}
else {
 $wday = $wday - 1;
}
system( "/opt/hap/bin/helper/hap-sendcmd2.pl", "destination 255 time-set day $wday hour $hour minute $min second $sec");
