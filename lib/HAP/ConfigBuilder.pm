
=head1 NAME

HAP::ConfigBuilder - The Home Automation Project Config-Builder

=head1 DESCRIPTION

Generates Module-Config-Commands from the Database-Backend

=cut

package HAP::ConfigBuilder;
use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";

my $mapping = { onOff => { 0 => 'off', 1 => 'on' } };

my @cmd;

################################################################################
# Base Settings
################################################################################

sub new {
  my ( $class, $c ) = @_;
  my $self = { c => $c };
  return bless $self, $class;
}

sub create {
  my ( $self, $module ) = @_;
  @cmd = ();
  my $config = $self->{c}->{'DefaultConfig'};
  my %mAddress;
  my @m = $self->db("SELECT ID, Address FROM module WHERE Config=$config");
  foreach (@m) {
    $mAddress{ $_->{ID} } = $_->{Address};
  }
  $mAddress{0} = 0;
  $mAddress{-255} = 255;
  $mAddress{-240} = 240;
  $mAddress{-241} = 241;
  $mAddress{-242} = 242;
  $mAddress{-243} = 243;
  $mAddress{-244} = 244;
  $mAddress{-245} = 245;
  $mAddress{-246} = 246;
  $mAddress{-247} = 247;
  $mAddress{-248} = 248;
  $mAddress{-249} = 249;
  $mAddress{-250} = 250;
  $mAddress{-251} = 251;
  $mAddress{-252} = 252;
  $mAddress{-253} = 253;    

  my @ref      = $self->db("SELECT * FROM module WHERE ID=$module AND Config=$config");
  my $ref      = $ref[0];
  my @upstream = $self->db("SELECT * FROM module WHERE ID=$ref[0]->{UpstreamModule} AND Config=$config");
  my $upstream = $upstream[0];

  # Init
  $self->add("destination $ref->{Address} config-reset");
  if ( $ref->{UpstreamInterface} == 4 ) {
    if ( $upstream->{IsCCU} ) {
      $self->add('{"DefaultVLAN" : 0}');
      $self->add('{"Crypto" : 0}');
    }
    else {
      $self->add("destination $upstream->{Address} radio-vlan 0");
      $self->add("destination $upstream->{Address} encryption-mode off ");
    }
  }
  elsif ( $ref->{UpstreamInterface} == 8 ) {
    $self->add("destination $upstream->{Address} canbus-vlan 0");
  }
  $self->add( "destination 255 magic-packet modul-address $ref->{Address} hardware-address "
      . hex( substr( $ref->{UID}, 0, 2 ) ) . " "
      . hex( substr( $ref->{UID}, 2, 2 ) ) . " "
      . hex( substr( $ref->{UID}, 4, 2 ) ) );

  # Crypto and VLAN
  if ( $ref->{UpstreamInterface} == 4 ) {    # radio
    $self->add("destination $ref->{Address} radio-vlan $ref->{VLAN}");
    if ( $upstream->{IsCCU} ) {
      $self->add( '{"DefaultVLAN" : ' . $upstream->{VLAN} . '}' );
    }
    else {
      $self->add("destination $upstream->{Address} radio-vlan $upstream->{VLAN}");
      $self->add("destination $ref->{Address} encryption-key 0 value $ref->{CryptKey0}");
      $self->add("destination $ref->{Address} encryption-key 1 value $ref->{CryptKey1}");
      $self->add("destination $ref->{Address} encryption-key 2 value $ref->{CryptKey2}");
      $self->add("destination $ref->{Address} encryption-key 3 value $ref->{CryptKey3}");
      $self->add("destination $ref->{Address} encryption-key 4 value $ref->{CryptKey4}");
      $self->add("destination $ref->{Address} encryption-key 5 value $ref->{CryptKey5}");
      $self->add("destination $ref->{Address} encryption-key 6 value $ref->{CryptKey6}");
      $self->add("destination $ref->{Address} encryption-key 7 value $ref->{CryptKey7}");
    }
    my @tmp = $self->db("SELECT ParserCmd FROM static_encryptionmodes WHERE Type=$ref->{CryptOption}");
    my $tmp = $tmp[0];
    $self->add("destination $ref->{Address} encryption-mode $tmp->{ParserCmd} ");
    @tmp = $self->db("SELECT ParserCmd FROM static_encryptionmodes WHERE Type=$upstream->{CryptOption}");
    $tmp = $tmp[0];
    if ( $upstream->{IsCCU} ) {
      $self->add('{"Crypto" : 1}');
    }
    else {
      $self->add("destination $upstream->{Address} encryption-mode $tmp->{ParserCmd} ");
    }
    $self->add("destination $ref->{Address} canbus-vlan $ref->{CANVLAN}");
  }
  elsif ( $ref->{UpstreamInterface} == 8 ) {    # CAN
    $self->add("destination $ref->{Address} canbus-vlan $ref->{CANVLAN}");
    $self->add("destination $upstream->{Address} canbus-vlan $upstream->{CANVLAN}");
    $self->add("destination $upstream->{Address} radio-vlan $upstream->{VLAN}");
    $self->add("destination $ref->{Address} encryption-key 0 value $ref->{CryptKey0}");
    $self->add("destination $ref->{Address} encryption-key 1 value $ref->{CryptKey1}");
    $self->add("destination $ref->{Address} encryption-key 2 value $ref->{CryptKey2}");
    $self->add("destination $ref->{Address} encryption-key 3 value $ref->{CryptKey3}");
    $self->add("destination $ref->{Address} encryption-key 4 value $ref->{CryptKey4}");
    $self->add("destination $ref->{Address} encryption-key 5 value $ref->{CryptKey5}");
    $self->add("destination $ref->{Address} encryption-key 6 value $ref->{CryptKey6}");
    $self->add("destination $ref->{Address} encryption-key 7 value $ref->{CryptKey7}");
    my @tmp = $self->db("SELECT ParserCmd FROM static_encryptionmodes WHERE Type=$ref->{CryptOption}");
    my $tmp = $tmp[0];
    $self->add("destination $ref->{Address} encryption-mode $tmp->{ParserCmd} ");
    $self->add("destination $ref->{Address} radio-vlan $ref->{VLAN}");
  }
  $self->add("destination $ref->{Address} multicast-group $ref->{MCastGroups}");
  $self->add("destination $ref->{Address} bridge-mode $mapping->{onOff}->{$ref->{BridgeMode}}");

  # Defaults
  my @tmp = $self->db("SELECT DISTINCT ParserCmd FROM static_startmodes WHERE Type=$ref->{StartMode}");
  my $tmp = $tmp[0];
  $self->add("destination $ref->{Address} start-mode $tmp->{ParserCmd}");
  $self->add("destination $ref->{Address} ccu-address $mAddress{$ref->{CCUAddress}}");
  $self->add("destination $ref->{Address} buzzer-level $ref->{BuzzerLevel}");
  $self->add("destination $ref->{Address} li-activation-time bounce-free $ref->{LIBounceDelay}");
  $self->add("destination $ref->{Address} li-activation-time short $ref->{LIShortDelay}");
  $self->add("destination $ref->{Address} li-activation-time long $ref->{LILongDelay}");
  $self->add("destination $ref->{Address} receive-buffer-len $ref->{ReceiveBuffer}");
  $self->add("destination $ref->{Address} dimmer-ignition-len $ref->{DimmerTicLength}");
  $self->add("destination $ref->{Address} dimmer-control-delay $ref->{DimmerCycleLength}");

  # Device
  my @devices = $self->db("SELECT * FROM device WHERE Module=$module AND Config=$config ORDER BY Port ASC, Pin ASC");
  foreach (@devices) {
    my @tmp = $self->db("SELECT ParserCmd, DefaultPortPin FROM static_devicetypes WHERE Type=$_->{Type}");
    $tmp = $tmp[0];
    if ( $tmp->{DefaultPortPin} ) {
      my ( $port, $pin ) = split( /-/, $tmp->{DefaultPortPin} );
      $self->add("destination $ref->{Address} pin-config port $port pin $pin type 0 device-address 30");
    }
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} type $tmp->{ParserCmd} device-address $_->{Address} ");
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} status-modul-address $mAddress{$_->{Notify}}");
  }

  # Logical-Inputs
  my @lis = $self->db("SELECT * FROM logicalinput WHERE Module=$module AND Config=$config");
  foreach (@lis) {
    my $type = "logical-input";
    if ( ( $_->{Type} & 1 ) == 1 ) {
      $type = $type . " rising-edge";
    }
    if ( ( $_->{Type} & 2 ) == 2 ) {
      $type = $type . " falling-edge";
    }
    if ( ( $_->{Type} & 4 ) == 4 && ( $_->{Type} & 8 ) == 0 ) {
      $type = $type . " bounce-free";
    }
    if ( ( $_->{Type} & 4 ) == 0 && ( $_->{Type} & 8 ) == 8 ) {
      $type = $type . " short";
    }
    if ( ( $_->{Type} & 12 ) == 12 ) {
      $type = $type . " long";
    }
    if ( ( $_->{Type} & 16 ) == 16 ) {
      $type = $type . " pull-up-resistor";
    }
    if ( ( $_->{Type} & 32 ) == 32 ) {
      $type = $type . " force-bounce-free";
    }
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} type $type device-address $_->{Address} ");
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} status-modul-address $mAddress{$_->{Notify}}");
  }

  # Analog-Inputs
  my @ais = $self->db("SELECT * FROM analoginput WHERE Module=$module AND Config=$config");
  foreach (@ais) {
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} type analog-input device-address $_->{Address} ");
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} status-modul-address $mAddress{$_->{Notify}}");
    $self->add("destination $ref->{Address} analog-input-device $_->{Address} sample-rate $_->{SampleRate}");

    my $t0 = ( $_->{Trigger0} * 16 & 0xFF ) | ( ( ( $_->{Trigger0} * 16 >> 8 ) & 0xFF ) << 8 );
    $self->add("destination $ref->{Address} analog-input-device $_->{Address} trigger 0 value $t0 ");
    my $t0Hyst = ( $_->{Trigger0Hyst} * 16 & 0xFF );
    my $notify = "no-status-message";
    if ( ( $_->{Trigger0Notify} & 4 ) == 4 ) {
      $notify = 'lower-limit-message';
    }
    if ( ( $_->{Trigger0Notify} & 8 ) == 8 ) {
      $notify = "limit-message";
    }
    if ( ( $_->{Trigger0Notify} & 12 ) == 12 ) {
      $notify = "all-status-message";
    }
    $self->add("destination $ref->{Address} analog-input-device $_->{Address} trigger 0 hysteresis $t0Hyst $notify ");

    my $t1 = ( $_->{Trigger1} * 16 & 0xFF ) | ( ( ( $_->{Trigger1} * 16 >> 8 ) & 0xFF ) << 8 );
    $self->add("destination $ref->{Address} analog-input-device $_->{Address} trigger 1 value $t1 ");
    my $t1Hyst = ( $_->{Trigger1Hyst} * 16 & 0xFF );
    $notify = "no-status-message";
    if ( ( $_->{Trigger1Notify} & 4 ) == 4 ) {
      $notify = 'lower-limit-message';
    }
    if ( ( $_->{Trigger1Notify} & 8 ) == 8 ) {
      $notify = "limit-message";
    }
    if ( ( $_->{Trigger1Notify} & 12 ) == 12 ) {
      $notify = "all-status-message";
    }
    $self->add("destination $ref->{Address} analog-input-device $_->{Address} trigger 1 hysteresis $t1Hyst $notify ");
  }

  # Digital-Inputs
  my @dis = $self->db("SELECT * FROM digitalinput WHERE Module=$module AND Config=$config");
  foreach (@dis) {
    my @tmp = $self->db("SELECT ParserCmd FROM static_digitalinputtypes WHERE Type=$_->{Type}");
    $tmp = $tmp[0];
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} type digital-input device-address $_->{Address} ");
    $self->add("destination $ref->{Address} pin-config port $_->{Port} pin $_->{Pin} status-modul-address $mAddress{$_->{Notify}}");
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} type $tmp->{ParserCmd}");
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} sample-rate $_->{SampleRate}");

    my $t0 = ( $_->{Trigger0} * 16 & 0xFF ) | ( ( ( $_->{Trigger0} * 16 >> 8 ) & 0xFF ) << 8 );
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} trigger 0 value $t0 ");
    my $t0Hyst = ( $_->{Trigger0Hyst} * 16 & 0xFF );
    my $notify = "no-status-message";
    if ( ( $_->{Trigger0Notify} & 4 ) == 4 ) {
      $notify = 'lower-limit-message';
    }
    if ( ( $_->{Trigger0Notify} & 8 ) == 8 ) {
      $notify = "limit-message";
    }
    if ( ( $_->{Trigger0Notify} & 12 ) == 12 ) {
      $notify = "all-status-message";
    }
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} trigger 0 hysteresis $t0Hyst $notify ");

    my $t1 = ( $_->{Trigger1} * 16 & 0xFF ) | ( ( ( $_->{Trigger1} * 16 >> 8 ) & 0xFF ) << 8 );
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} trigger 1 value $t1 ");
    my $t1Hyst = ( $_->{Trigger1Hyst} * 16 & 0xFF );
    $notify = "no-status-message";
    if ( ( $_->{Trigger1Notify} & 4 ) == 4 ) {
      $notify = 'lower-limit-message';
    }
    if ( ( $_->{Trigger1Notify} & 8 ) == 8 ) {
      $notify = "limit-message";
    }
    if ( ( $_->{Trigger1Notify} & 12 ) == 12 ) {
      $notify = "all-status-message";
    }
    $self->add("destination $ref->{Address} digital-input-device $_->{Address} trigger 1 hysteresis $t1Hyst $notify ");
  }

  # LCD-Guis
  my @lcdguis = $self->db("SELECT * FROM abstractdevice WHERE Module=$module AND Config=$config AND Type=96 AND SubType=240");
  foreach (@lcdguis) {
    $self->add("destination $ref->{Address} gui-device new-address $_->{Address} status-modul-address $mAddress{$_->{Notify}}");
  }

  # Rotary-Encoder
  my @encoders = $self->db("SELECT * FROM abstractdevice WHERE Module=$module AND Config=$config AND Type=96 AND SubType=224");
  foreach (@encoders) {
    $self->add("destination $ref->{Address} rotary-encoder-dev new-address $_->{Address} status-modul-address $mAddress{$_->{Notify}}");

    # A
    my @tmp = $self->db("SELECT Module, Address FROM logicalinput WHERE ID=$_->{ChildDevice0}");
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} input-device-a $tmp[0]->{Address}");

    # B
    @tmp = $self->db("SELECT Module, Address FROM logicalinput WHERE ID=$_->{ChildDevice1}");
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} input-device-b $tmp[0]->{Address}");

    # P1
    @tmp = $self->db("SELECT Module, Address FROM logicalinput WHERE ID=$_->{ChildDevice2}");
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} input-device-t $tmp[0]->{Address}");

    # Output Module
    @tmp = $self->db("SELECT Module, Address FROM abstractdevice WHERE ID=$_->{ChildDevice3}");
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} output-modul $mAddress{$tmp[0]->{Module}} device $tmp[0]->{Address}");

    # Input Module
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} input-modul $ref->{Address}");

    # Speed
    $self->add("destination $ref->{Address} rotary-encoder-dev $_->{Address} speed $_->{Attrib2}");
  }

  # Shutter
  my @shutters = $self->db("SELECT * FROM abstractdevice WHERE Module=$module AND Config=$config AND Type=192");
  foreach (@shutters) {
    $self->add("destination $ref->{Address} shutter-device new-address $_->{Address} status-modul-address $mAddress{$_->{Notify}}");

    # Up
    my @tmp = $self->db("SELECT Module, Address FROM device WHERE ID=$_->{ChildDevice0}");
    $self->add("destination $ref->{Address} shutter-device $_->{Address} up-modul $mAddress{$_->{Module}} device $tmp[0]->{Address}");

    # Down
    @tmp = $self->db("SELECT Module, Address FROM device WHERE ID=$_->{ChildDevice1}");
    $self->add("destination $ref->{Address} shutter-device $_->{Address} down-modul $mAddress{$_->{Module}} device $tmp[0]->{Address}");

    # Type
    my $type = "normal";
    if ( defined( $_->{Attrib1} ) && $_->{Attrib1} == 1 ) {
      $type = "pulse-contact-ctrl";
    }
    $self->add("destination $ref->{Address} shutter-device $_->{Address} type $type");

    # Driving-time
    $self->add( "destination $ref->{Address} shutter-device $_->{Address} max-driving-time " . ( $_->{Attrib0} * 5 ) );
  }

  # Infrared Keys
  my @keys = $self->db("SELECT * FROM remotecontrol_learned WHERE Module=$module AND Config=$config");
  foreach (@keys) {
    my @tmp = $self->db("SELECT ParserCmd FROM static_ircodes WHERE Code=$_->{Action}");
    $self->add("destination $ref->{Address} ir-device $_->{Address} button $_->{Code} command $tmp[0]->{ParserCmd} ");
  }

  # Infrared Mappings
  my @mappings = $self->db("SELECT * FROM remotecontrol_mapping WHERE Module=$module AND Config=$config");
  foreach (@mappings) {
    if ( $_->{DestDevice} != 0 ) {
      my @tmp = $self->db("SELECT Module, Address FROM device WHERE ID=$_->{DestDevice}");
      $self->add("destination $ref->{Address} ir-address $_->{IRKey} modul-address $mAddress{$tmp[0]->{Module}} device-address $tmp[0]->{Address}");
    }
    if ( $_->{DestVirtModule} != 0 ) {
      my @tmp = $self->db("SELECT Module, Address FROM abstractdevice WHERE ID=$_->{DestVirtModule}");
      $self->add("destination $ref->{Address} ir-address $_->{IRKey} modul-address $mAddress{$tmp[0]->{Module}} device-address $tmp[0]->{Address}");
    }
    if ( $_->{DestMakroNr} != 0 ) {
      my @tmp = $self->db("SELECT * FROM makro WHERE ID=$_->{DestMakroNr}");
      $self->add("destination $ref->{Address} ir-hotkey $_->{IRKey} makro $tmp[0]->{MakroNr}");
    }
  }

  # Range Extender
  my @res = $self->db("SELECT * FROM rangeextender WHERE Module=$module AND Config=$config");
  my $i   = 0;
  foreach (@res) {
    $self->add("destination $ref->{Address} remote-extender $i address $_->{DestModule}");
    $i++;
    last if ( $i > 3 );
  }

  # Autonomous Control
  $self->add("destination $ref->{Address} ac-reset");
  my @objs = $self->db("SELECT * FROM ac_objects WHERE Module=$module AND Config=$config AND Type != 256 ORDER BY Object ASC");
  foreach (@objs) {
    $self->add("destination $ref->{Address} ac-object $_->{Object} property 0 value $_->{Type}");
    if ( $_->{Type} == 56 || $_->{Type} == 60 || $_->{Type} == 61 ) {
      $self->add("destination $ref->{Address} ac-object $_->{Object} property 1 value $mAddress{$_->{Prop1}}");
    }
    else {
      $self->add("destination $ref->{Address} ac-object $_->{Object} property 1 value $_->{Prop1}");
    }
    if ( $_->{Type} == 120 || $_->{Type} == 121 ) {
      $self->add("destination $ref->{Address} ac-object $_->{Object} property 2 value $mAddress{$_->{Prop2}}");
    }
    else {
      $self->add("destination $ref->{Address} ac-object $_->{Object} property 2 value $_->{Prop2}");
    }
    $self->add("destination $ref->{Address} ac-object $_->{Object} property 3 value $_->{Prop3}");
  }

  # Save
  $self->add("destination $ref->{Address} save-config");

  # Reset
  $self->add("destination $ref->{Address} system-full-reset");

  # Query Firmware
  $self->add("destination $ref->{Address} get-version");
  $self->add("destination $ref->{Address} get-compiler-option 0");
  $self->add("destination $ref->{Address} get-compiler-option 1");
  $self->add("destination $ref->{Address} get-compiler-option 2");
  $self->add("destination $ref->{Address} get-compiler-option 3");

  return \@cmd;
}

sub add {
  my ( $self, $line ) = @_;
  push @cmd, $line;
}

sub db {
  my ( $self, $sql ) = @_;
  my $sth = $self->{c}->{dbh}->prepare($sql);
  $sth->execute;
  my @rows;
  while ( my $ref = $sth->fetchrow_hashref() ) {
    push @rows, $ref;
  }
  return @rows;
}

sub out {
  my $lines = scalar(@cmd);
  my $i     = 0;
  foreach (@cmd) {
    $i++;
    print "[" . sprintf( "%.0f", ( $i * 100 / $lines ) ) . "%] " . $_ . "\n";
  }
}

1;
