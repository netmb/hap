#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use JavaScript::Minifier qw(minify);
my $rootPath = "./../root";
my $index = $rootPath."/src/main/index_debug.tt2";
my $concat = $rootPath."/static/js/hap/hap-concat.js";
my $minified = $rootPath."/static/js/hap/hap-min.js";

open(FI, "<$index");
open(FO, ">$concat");
my $start = 0;
while(<FI>) {
  my $line = $_;
  if ($start == 0 && $_ =~ /.*<\!--.*HAP.*-->.*/) {
    $start = 1;
  }
  if ($start == 1) {
    if ($_ =~ /.*src=\'(.*\.js)\'.*/) {
      if ($1 =~ /.*Layout.js.*/ || $1 =~ /.*hap-min.js.*/ || $1 =~ /.*hap-concat.js.*/) {
        next;
      }
      my $js = $1;
      $js =~ s/^\./$rootPath/;
      print "$js\n";
      open (TMP, "<$js");
      while (<TMP>) {
        print FO $_;
      }
      close TMP;
    }
  }
}
close FO;
close FI;

open (FI, "<$concat");
open (FO, ">$minified");
minify(input => *FI, outfile => *FO);
close FO;
close FI;
