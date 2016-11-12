#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-homekitexport.pl -  The Home Automation Project Homekit-Exporter 

=cut

use warnings;
use strict;
use Getopt::Long;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use IO::Socket::INET;
use Encode;
use HAP::Init;
my $c = new HAP::Init( FILE => "$FindBin::Bin/../../etc/hap.yml" );

my $config = undef;
GetOptions( "config|c=i" => \$config ) or die ;

if (!$config) {
 $config = $c->{DefaultConfig};
}

# hole devices aus datenbank
# loop ueber devices - switch type dimmer
# oeffne file je nach typ
# fuelle ersetzungs hash

open (OUTFILE, ">./hap.items");
 
my $sth = $c->{dbh}->prepare("
Select device.Name as Name, module.Address as Module, device.Type as Type, device.Address as Address from device LEFT JOIN module on module.ID=device.Module WHERE device.Config=$config UNION 
Select logicalinput.Name as Name, module.Address as Module, logicalinput.type as Type, logicalinput.address as Address from logicalinput LEFT JOIN module on module.ID=logicalinput.Module WHERE logicalinput.Config=$config UNION
Select digitalinput.Name as Name, module.Address as Module, digitalinput.type as Type, digitalinput.address as Address from digitalinput LEFT JOIN module on module.ID=digitalinput.Module WHERE digitalinput.Config=$config UNION
Select abstractdevice.Name as Name, module.Address as Module, 96 as Type, abstractdevice.address as Address from abstractdevice LEFT JOIN module on module.ID=abstractdevice.Module WHERE abstractdevice.Config=$config
");
#Select homematic.Name as Name, module.Address as Module, 16 as Type, homematic.Address as Address from homematic LEFT JOIN module on module.ID=homematic.Module WHERE homematic.Config=$config

$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
  my $name = $ref->{Name};
  if (utf8::is_utf8($name)) {
    $name = encode("utf-8", $name);
    #$name = utf8::unicode_to_native($name);
  }
  $name =~ s/\s/_/g;
  $name =~ s/ä/ae/g;
  $name =~ s/ü/ue/g;
  $name =~ s/ö/oe/g;
  $name =~ s/-/_/g;

  if ($ref->{Type} == 16) {
    print OUTFILE "Switch $name \"$name\" {mqtt=\">[hap:/hap/$ref->{Module}/$ref->{Address}:command:*:default], <[hap:/hap/$ref->{Module}/$ref->{Address}/status:state:default]\"}\n";
  } 
  elsif (($ref->{Type} & 64) == 64 && $ref->{Type} != 96) {
    print OUTFILE "Dimmer $name \"$name\" {mqtt=\">[hap:/hap/$ref->{Module}/$ref->{Address}:command:*:default], <[hap:/hap/$ref->{Module}/$ref->{Address}/status:state:default]\"}\n";
  }
  elsif (($ref->{Type} & 96) == 96) {
    print OUTFILE "Rollershutter $name \"$name\" {mqtt=\">[hap:/hap/$ref->{Module}/$ref->{Address}:command:*:default], <[hap:/hap/$ref->{Module}/$ref->{Address}/status:state:default]\"}\n";
  }
  elsif (($ref->{Type} & 128) == 128) {
    print OUTFILE "Contact $name \"$name\" {mqtt=\"<[hap:/hap/$ref->{Module}/$ref->{Address}/status:state:default]\"}\n";
  }
}
close OUTFILE;
exit 0;

