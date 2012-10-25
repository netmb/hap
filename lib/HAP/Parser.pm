=head1 NAME

HAP::Parser -  The Home Automation Project Command-Parser

=head1 DESCRIPTION

Parses user input and converts it into HAP-Commands (and vice versa)

=cut

package HAP::Parser;
use strict;

sub new {
  my ( $class, $c ) = @_;
  my $self = { c => $c };
  return bless $self, $class;
}

sub getConfig {
  my ( $self, $conf ) = @_;
  return $self->{c}->{DefaultConfig};
}

sub getVLAN {
  my ( $self, $conf ) = @_;
  return $self->{c}->{DefaultVLAN};
}

sub getSource {
  my ( $self, $conf, $sessionSource ) = @_;
  return ( $sessionSource || $self->{c}->{CCUAddress} );
}

sub getConfigName {
  my ( $self, $conf ) = @_;    
  return $self->{c}->{DefaultConfigName};
}

sub parse {
  my ( $self, $statement, $sessionSource ) = @_;
  my $stmnt = $statement;
  if ( $stmnt !~ m/\^/ ) { $stmnt .= " ^10"; }
  my @s = split( /\s+/, $stmnt );
  my $n = scalar(@s);
  my $t;
  my $l;
  my $i         = 0;
  my $state     = 0;
  my $prevState = 0;
  my $native    = 0;
  my @res       = ( -1, -1, -1, 0, 0, 0, 0, 0, 0 );
  my $err       = 0;
  do {
    $prevState = $state;
    $t         = $s[$i];
    $l         = length($t);
    if    ( substr( $t, length($t) - 3, 3 ) eq "^63" ) { $state = 60100; }
    elsif ( substr( $t, length($t) - 2, 2 ) eq "^9" )  { $state = 60200; }
    elsif ( $state == 0 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) { $state = 10; }
      elsif ( $t eq substr( "config",      0, $l ) && $l > 0 ) { $state = 100; }
      elsif ( $t eq substr( "destination", 0, $l ) && $l > 0 ) { $state = 160; }
      elsif ( $t eq substr( "source",      0, $l ) && $l > 0 ) { $state = 140; }
      elsif ( $t eq substr( "vlan",        0, $l ) && $l > 0 ) { $state = 120; }
      else { $state = 60300; }
    }
    elsif ( $state == 10 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) { $state = 20; }
      else { $state = 60300; }
    }
    elsif ( $state == 20 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) { $state = 30; }
      else { $state = 60300; }
    }
    elsif ( $state == 30 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 40; }
      else { $state = 60300; }
    }
    elsif ( $state == 40 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 50; }
      else { $state = 60300; }
    }
    elsif ( $state == 50 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 60; }
      else { $state = 60300; }
    }
    elsif ( $state == 60 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 70; }
      else { $state = 60300; }
    }
    elsif ( $state == 70 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 80; }
      else { $state = 60300; }
    }
    elsif ( $state == 80 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      elsif ( $t =~ /^\d+$/ ) { $state = 90; }
      else { $state = 60300; }
    }
    elsif ( $state == 90 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $native = 1;
        $state  = 60000;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 100 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[0] = $t;
          $state = 110;
        }
        else { $state = 60310; }
      }
      elsif ( $t =~ /^[a-zA-Z_]\w*$/ ) {
        my $tmp = &getConfig($self, $t);
        if ( $tmp >= 0 ) {
          $res[0] = $tmp;
          $state = 110;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 110 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "destination", 0, $l ) && $l > 0 ) { $state = 160; }
      elsif ( $t eq substr( "source",      0, $l ) && $l > 0 ) { $state = 140; }
      elsif ( $t eq substr( "vlan",        0, $l ) && $l > 0 ) { $state = 120; }
      else { $state = 60300; }
    }
    elsif ( $state == 120 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[1] = $t;
          $state = 130;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 130 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "destination", 0, $l ) && $l > 0 ) { $state = 160; }
      elsif ( $t eq substr( "source",      0, $l ) && $l > 0 ) { $state = 140; }
      else { $state = 60300; }
    }
    elsif ( $state == 140 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[2] = $t;
          $state = 150;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 150 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "destination", 0, $l ) && $l > 0 ) { $state = 160; }
      else { $state = 60300; }
    }
    elsif ( $state == 160 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[3] = $t;
          $state = 170;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 170 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "ac-object", 0, $l ) && $l > 3 ) {
        $res[4] = 100;
        $state = 1420;
      }
      elsif ( $t eq substr( "ac-reset", 0, $l ) && $l > 3 ) {
        $res[4] = 100;
        $res[8] = 255;
        $state  = 1440;
      }
      elsif ( $t eq substr( "analog-input-device", 0, $l ) && $l > 0 ) {
        $res[4] = 76;
        $res[5] += 64;
        $state = 1080;
      }
      elsif ( $t eq substr( "bridge-mode", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 10;
        $state  = 870;
      }
      elsif ( $t eq substr( "buzzer-level", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 16;
        $state  = 980;
      }
      elsif ( $t eq substr( "canbus-vlan", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 18;
        $state  = 1000;
      }
      elsif ( $t eq substr( "ccu-address", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 6;
        $state  = 850;
      }
      elsif ( $t eq substr( "config-reset", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 3;
        $state  = 830;
      }
      elsif ( $t eq substr( "data", 0, $l ) && $l > 1 ) {
        $res[4] = 60;
        $res[5] = 255;
        $res[6] = 255;
        $res[7] = 255;
        $res[8] = 255;
        $state  = 3370;
      }
      elsif ( $t eq substr( "digital-input-device", 0, $l ) && $l > 2 ) {
        $res[4] = 76;
        $res[5] += 128;
        $state = 1090;
      }
      elsif ( $t eq substr( "dimmer-control-delay", 0, $l ) && $l > 7 ) {
        $res[4] = 76;
        $res[5] = 36;
        $state  = 1050;
      }
      elsif ( $t eq substr( "dimmer-ignition-len", 0, $l ) && $l > 7 ) {
        $res[4] = 76;
        $res[5] = 37;
        $state  = 1060;
      }
      elsif ( $t eq substr( "display-control", 0, $l ) && $l > 8 ) {
        $res[4] = 91;
        $state = 3200;
      }
      elsif ( $t eq substr( "display-data", 0, $l ) && $l > 8 ) {
        $res[4] = 88;
        $res[5] = 160;
        $res[6] = 160;
        $res[7] = 160;
        $res[8] = 160;
        $state  = 3200;
      }
      elsif ( $t eq substr( "eeprom-address", 0, $l ) && $l > 1 ) {
        $res[4] = 28;
        $state = 3250;
      }
      elsif ( $t eq substr( "encryption-key", 0, $l ) && $l > 11 ) {
        $res[4] = 76;
        $res[5] = 15;
        $state  = 950;
      }
      elsif ( $t eq substr( "encryption-mode", 0, $l ) && $l > 11 ) {
        $res[4] = 76;
        $res[5] = 14;
        $state  = 940;
      }
      elsif ( $t eq substr( "error", 0, $l ) && $l > 1 ) {
        $res[4] = 127;
        $state = 3420;
      }
      elsif ( $t eq substr( "firmware-size", 0, $l ) && $l > 0 ) {
        $res[4] = 76;
        $res[5] = 27;
        $state  = 1010;
      }
      elsif ( $t eq substr( "get-compiler-option", 0, $l ) && $l > 4 ) {
        $res[4] = 76;
        $res[5] = 30;
        $state  = 1020;
      }
      elsif ( $t eq substr( "get-flash-flag", 0, $l ) && $l > 4 ) {
        $res[4] = 76;
        $res[5] = 24;
        $state  = 830;
      }
      elsif ( $t eq substr( "get-version", 0, $l ) && $l > 4 ) {
        $res[4] = 76;
        $res[5] = 28;
        $state  = 830;
      }
      elsif ( $t eq substr( "gui-device", 0, $l ) && $l > 1 ) {
        $res[4] = 96;
        $state = 1380;
      }
      elsif ( $t eq substr( "ir-address", 0, $l ) && $l > 3 ) {
        $res[4] = 68;
        $state = 3040;
      }
      elsif ( $t eq substr( "ir-device", 0, $l ) && $l > 3 ) {
        $res[4] = 80;
        $state = 3140;
      }
      elsif ( $t eq substr( "ir-hotkey", 0, $l ) && $l > 3 ) {
        $res[4] = 72;
        $state = 3100;
      }
      elsif ( $t eq substr( "ir-learn-command", 0, $l ) && $l > 3 ) {
        $res[4] = 84;
        $state = 3180;
      }
      elsif ( $t eq substr( "li-activation-time", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 32;
        $state  = 1030;
      }
      elsif ( $t eq substr( "load-config", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 9;
        $state  = 830;
      }
      elsif ( $t eq substr( "magic-packet", 0, $l ) && $l > 2 ) {
        $res[3] = 255;
        $res[4] = 124;
        $state  = 2970;
      }
      elsif ( $t eq substr( "makro", 0, $l ) && $l > 2 ) {
        $res[4] = 24;
        $state = 510;
      }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 5;
        $state  = 840;
      }
      elsif ( $t eq substr( "multicast-group", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 13;
        $state  = 920;
      }
      elsif ( $t eq substr( "pin-config", 0, $l ) && $l > 1 ) {
        $res[4] = 64;
        $state = 560;
      }
      elsif ( $t eq substr( "protocoll", 0, $l ) && $l > 1 ) {
        $res[4] = 56;
        $state = 3310;
      }
      elsif ( $t eq substr( "query", 0, $l ) && $l > 0 ) {
        $res[4] = 8;
        $state = 360;
      }
      elsif ( $t eq substr( "radio-vlan", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 12;
        $state  = 910;
      }
      elsif ( $t eq substr( "receive-buffer-len", 0, $l ) && $l > 2 ) {
        $res[4] = 76;
        $res[5] = 96;
        $state  = 1070;
      }
      elsif ( $t eq substr( "remote-extender", 0, $l ) && $l > 2 ) {
        $res[4] = 76;
        $res[5] = 11;
        $state  = 880;
      }
      elsif ( $t eq substr( "rotary-encoder-dev", 0, $l ) && $l > 1 ) {
        $res[4] = 96;
        $state = 1300;
      }
      elsif ( $t eq substr( "save-config", 0, $l ) && $l > 1 ) {
        $res[4] = 76;
        $res[5] = 8;
        $state  = 830;
      }
      elsif ( $t eq substr( "set", 0, $l ) && $l > 1 ) {
        $res[4] = 0;
        $state = 180;
      }
      elsif ( $t eq substr( "shutter-device", 0, $l ) && $l > 1 ) {
        $res[4] = 96;
        $state = 1190;
      }
      elsif ( $t eq substr( "start-mode", 0, $l ) && $l > 3 ) {
        $res[4] = 76;
        $res[5] = 4;
        $state  = 820;
      }
      elsif ( $t eq substr( "status", 0, $l ) && $l > 3 ) {
        $res[4] = 16;
        $state = 410;
      }
      elsif ( $t eq substr( "system-full-reset", 0, $l ) && $l > 7 ) {
        $res[4] = 76;
        $res[5] = 2;
        $state  = 830;
      }
      elsif ( $t eq substr( "system-reset", 0, $l ) && $l > 7 ) {
        $res[4] = 76;
        $res[5] = 1;
        $state  = 830;
      }
      elsif ( $t eq substr( "time-server", 0, $l ) && $l > 7 ) {
        $res[4] = 76;
        $res[5] = 7;
        $state  = 860;
      }
      elsif ( $t eq substr( "time-set", 0, $l ) && $l > 7 ) {
        $res[4] = 120;
        $state = 2850;
      }
      elsif ( $t eq substr( "time-synch-request", 0, $l ) && $l > 6 ) {
        $res[4] = 123;
        $state = 2960;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 180 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device", 0, $l ) && $l > 0 ) { $state = 190; }
      else { $state = 60300; }
    }
    elsif ( $state == 190 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 200;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 200 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "decrement", 0, $l ) && $l > 1 ) {
        $res[6] = 130;
        $state = 310;
      }
      elsif ( $t eq substr( "down", 0, $l ) && $l > 1 ) {
        $res[6] = 134;
        $state = 330;
      }
      elsif ( $t eq substr( "increment", 0, $l ) && $l > 2 ) {
        $res[6] = 129;
        $state = 300;
      }
      elsif ( $t eq substr( "invert", 0, $l ) && $l > 2 ) {
        $res[6] = 128;
        $state = 290;
      }
      elsif ( $t eq substr( "start", 0, $l ) && $l > 2 ) {
        $res[6] = 136;
        $state = 350;
      }
      elsif ( $t eq substr( "stop", 0, $l ) && $l > 2 ) {
        $res[6] = 135;
        $state = 340;
      }
      elsif ( $t eq substr( "trigger", 0, $l ) && $l > 0 ) { $state = 210; }
      elsif ( $t eq substr( "up", 0, $l ) && $l > 0 ) {
        $res[6] = 133;
        $state = 320;
      }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) { $state = 250; }
      else { $state = 60300; }
    }
    elsif ( $state == 210 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 1 ) {
          $res[6] = 160 + $t;
          $state = 220;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 220 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) { $state = 230; }
      else { $state = 60300; }
    }
    elsif ( $state == 230 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 240;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 240 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 250 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 100 ) {
          $res[6] = $t;
          $state = 260;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 260 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "delay", 0, $l ) && $l > 0 ) { $state = 270; }
      else { $state = 60300; }
    }
    elsif ( $state == 270 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 6553 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 280;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 280 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 290 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 300 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 310 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }

      else { $state = 60300; }
    }
    elsif ( $state == 320 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 330 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 340 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 350 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 360 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device", 0, $l ) && $l > 0 ) { $state = 370; }
      else { $state = 60300; }
    }
    elsif ( $state == 370 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 380;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 380 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "trigger", 0, $l ) && $l > 0 ) { $state = 390; }
      else { $state = 60300; }
    }
    elsif ( $state == 390 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 1 ) {
          $res[8] = 160 + $t;
          $state = 400;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 400 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 410 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device", 0, $l ) && $l > 0 ) { $state = 420; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[6] |= 128;
        $state = 440;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] &= 127;
        $state = 440;
      }
      elsif ( $t eq substr( "trigger", 0, $l ) && $l > 0 ) { $state = 460; }
      elsif ( $t eq substr( "value",   0, $l ) && $l > 0 ) { $state = 480; }
      else { $state = 60300; }
    }
    elsif ( $state == 420 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 430;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 430 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[6] |= 128;
        $state = 440;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) { $state = 440; }
      elsif ( $t eq substr( "trigger",     0, $l ) && $l > 0 ) { $state = 460; }
      elsif ( $t eq substr( "value",       0, $l ) && $l > 0 ) { $state = 480; }
      else { $state = 60300; }
    }
    elsif ( $state == 440 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] |= 4;
        $state = 450;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] |= 12;
        $state = 450;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 450; }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] |= 8;
        $state = 450;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 450 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 460 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 1 ) {
          $res[6] = $t;
          $state = 470;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 470 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "fall-below", 0, $l ) && $l > 9 ) {
        $res[6] |= 64;
        $state = 450;
      }
      elsif ( $t eq substr( "fall-below-and-back", 0, $l ) && $l > 10 ) { $state = 450; }
      elsif ( $t eq substr( "rise-above", 0, $l ) && $l > 9 ) {
        $res[6] |= 192;
        $state = 450;
      }
      elsif ( $t eq substr( "rise-above-and-back", 0, $l ) && $l > 10 ) {
        $res[6] |= 128;
        $state = 450;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 480 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 490;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 490 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "extension", 0, $l ) && $l > 0 ) { $state = 500; }
      else { $state = 60300; }
    }
    elsif ( $state == 500 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 450;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 510 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 520;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "low-byte", 0, $l ) && $l > 0 ) { $state = 530; }
      else { $state = 60300; }
    }
    elsif ( $state == 520 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 530 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 540;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 540 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "high-byte", 0, $l ) && $l > 0 ) { $state = 550; }
      else { $state = 60300; }
    }
    elsif ( $state == 550 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 520;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 560 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 31 ) {
          $res[5] = $t;
          $state = 570;
        }
        else { $state = 60310; }
      }
      elsif ( $t =~ /^[a-d][0-7]$/ ) {
        $res[5] = ( ord( substr( $t, 0, 1 ) ) - 97 ) * 8 + ord( substr( $t, 1, 1 ) ) - 48;
        $state = 570;
      }
      elsif ( $t eq substr( "port", 0, $l ) && $l > 0 ) { $state = 580; }
      else { $state = 60300; }
    }
    elsif ( $state == 570 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "status-modul-address", 0, $l ) && $l > 0 ) {
        $res[5] += 32;
        $state = 610;
      }
      elsif ( $t eq substr( "type", 0, $l ) && $l > 0 ) { $state = 630; }
      else { $state = 60300; }
    }
    elsif ( $state == 580 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[5] = $t * 8;
          $state = 590;
        }
        else { $state = 60310; }
      }
      elsif ( $t =~ /^[a-d]$/ ) {
        $res[5] = ( ord($t) - 97 ) * 8;
        $state = 590;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 590 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "pin", 0, $l ) && $l > 0 ) { $state = 600; }
      else { $state = 60300; }
    }
    elsif ( $state == 600 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 7 ) {
          $res[5] += $t;
          $state = 570;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 610 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 620;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 620 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 630 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 640;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "analog-input", 0, $l ) && $l > 0 ) {
        $res[6] = 32;
        $state = 640;
      }
      elsif ( $t eq substr( "buzzer", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 640;
      }
      elsif ( $t eq substr( "code", 0, $l ) && $l > 0 ) { $state = 660; }
      elsif ( $t eq substr( "digital-input", 0, $l ) && $l > 2 ) {
        $res[6] = 40;
        $state = 640;
      }
      elsif ( $t eq substr( "dimmer", 0, $l ) && $l > 2 ) {
        $res[6] = 64;
        $state = 730;
      }
      elsif ( $t eq substr( "ir-receiver", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 640;
      }
      elsif ( $t eq substr( "lcd", 0, $l ) && $l > 1 ) {
        $res[6] = 48;
        $state = 710;
      }
      elsif ( $t eq substr( "logical-input", 0, $l ) && $l > 1 ) {
        $res[6] = 128;
        $state = 770;
      }
      elsif ( $t eq substr( "serial-interface", 0, $l ) && $l > 1 ) {
        $res[6] = 4;
        $state = 700;
      }
      elsif ( $t eq substr( "spi-miso", 0, $l ) && $l > 5 ) {
        $res[6] = 10;
        $state = 640;
      }
      elsif ( $t eq substr( "spi-mosi", 0, $l ) && $l > 5 ) {
        $res[6] = 9;
        $state = 640;
      }
      elsif ( $t eq substr( "spi-sc", 0, $l ) && $l > 5 ) {
        $res[6] = 11;
        $state = 640;
      }
      elsif ( $t eq substr( "spi-ss", 0, $l ) && $l > 5 ) {
        $res[6] = 8;
        $state = 640;
      }
      elsif ( $t eq substr( "static-output", 0, $l ) && $l > 1 ) {
        $res[6] = 0;
        $state = 690;
      }
      elsif ( $t eq substr( "switch", 0, $l ) && $l > 1 ) {
        $res[6] = 16;
        $state = 640;
      }
      elsif ( $t eq substr( "twi-sc", 0, $l ) && $l > 5 ) {
        $res[6] = 12;
        $state = 640;
      }
      elsif ( $t eq substr( "twi-sd", 0, $l ) && $l > 5 ) {
        $res[6] = 13;
        $state = 640;
      }
      elsif ( $t eq substr( "zero-cross-detection", 0, $l ) && $l > 0 ) {
        $res[6] = 6;
        $state = 640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 640 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      else { $state = 60300; }
    }
    elsif ( $state == 650 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 620;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 660 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 670;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 670 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "offset",         0, $l ) && $l > 0 ) { $state = 680; }
      else { $state = 60300; }
    }
    elsif ( $state == 680 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 32 ) {
          $res[6] += $t;
          $state = 640;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 690 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "high", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 640;
      }
      elsif ( $t eq substr( "low", 0, $l ) && $l > 0 ) { $state = 640; }
      else { $state = 60300; }
    }
    elsif ( $state == 700 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "receiver",       0, $l ) && $l > 0 ) { $state = 640; }
      elsif ( $t eq substr( "transmitter",    0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 710 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 1 ) { $state = 650; }
      elsif ( $t eq substr( "display-data",   0, $l ) && $l > 1 ) { $state = 720; }
      elsif ( $t eq substr( "enable",         0, $l ) && $l > 0 ) {
        $res[6] += 10;
        $state = 640;
      }
      elsif ( $t eq substr( "read-write", 0, $l ) && $l > 2 ) {
        $res[6] += 8;
        $state = 640;
      }
      elsif ( $t eq substr( "register-select", 0, $l ) && $l > 2 ) {
        $res[6] += 9;
        $state = 640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 720 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 7 ) {
          $res[6] += $t;
          $state = 640;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 730 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "long-ignition", 0, $l ) && $l > 0 ) {
        $res[6] += 2;
        $state = 740;
      }
      elsif ( $t eq substr( "soft-delay", 0, $l ) && $l > 1 ) {
        $res[6] += 1;
        $state = 740;
      }
      elsif ( $t eq substr( "switch-restriction", 0, $l ) && $l > 1 ) {
        $res[6] += 4;
        $state = 740;
      }
      elsif ( $t eq substr( "trailing-edge-princ", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 740;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 740 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "long-ignition", 0, $l ) && $l > 0 ) {
        $res[6] += 2;
        $state = 750;
      }
      elsif ( $t eq substr( "soft-delay", 0, $l ) && $l > 1 ) {
        $res[6] += 1;
        $state = 750;
      }
      elsif ( $t eq substr( "switch-restriction", 0, $l ) && $l > 1 ) {
        $res[6] += 4;
        $state = 750;
      }
      elsif ( $t eq substr( "trailing-edge-princ", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 750;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 750 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "long-ignition", 0, $l ) && $l > 0 ) {
        $res[6] += 2;
        $state = 760;
      }
      elsif ( $t eq substr( "soft-delay", 0, $l ) && $l > 1 ) {
        $res[6] += 1;
        $state = 760;
      }
      elsif ( $t eq substr( "switch-restriction", 0, $l ) && $l > 1 ) {
        $res[6] += 4;
        $state = 760;
      }
      elsif ( $t eq substr( "trailing-edge-princ", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 760;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 760 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "long-ignition", 0, $l ) && $l > 0 ) {
        $res[6] += 2;
        $state = 640;
      }
      elsif ( $t eq substr( "soft-delay", 0, $l ) && $l > 1 ) {
        $res[6] += 1;
        $state = 640;
      }
      elsif ( $t eq substr( "switch-restriction", 0, $l ) && $l > 1 ) {
        $res[6] += 4;
        $state = 640;
      }
      elsif ( $t eq substr( "trailing-edge-princ", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 770 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] += 4;
        $state = 780;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 1 ) {
        $res[6] += 2;
        $state = 780;
      }
      elsif ( $t eq substr( "force-bounce-free", 0, $l ) && $l > 1 ) {
        $res[6] += 32;
        $state = 780;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] += 12;
        $state = 780;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 780; }
      elsif ( $t eq substr( "pull-up-resistor", 0, $l ) && $l > 0 ) {
        $res[6] += 16;
        $state = 780;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 780;
      }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 780;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 780 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] += 4;
        $state = 790;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 1 ) {
        $res[6] += 2;
        $state = 790;
      }
      elsif ( $t eq substr( "force-bounce-free", 0, $l ) && $l > 1 ) {
        $res[6] += 32;
        $state = 790;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] += 12;
        $state = 790;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 790; }
      elsif ( $t eq substr( "pull-up-resistor", 0, $l ) && $l > 0 ) {
        $res[6] += 16;
        $state = 790;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 790;
      }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 790;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 790 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] += 4;
        $state = 800;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 1 ) {
        $res[6] += 2;
        $state = 800;
      }
      elsif ( $t eq substr( "force-bounce-free", 0, $l ) && $l > 1 ) {
        $res[6] += 32;
        $state = 800;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] += 12;
        $state = 800;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 800; }
      elsif ( $t eq substr( "pull-up-resistor", 0, $l ) && $l > 0 ) {
        $res[6] += 16;
        $state = 800;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 800;
      }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 800;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 800 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] += 4;
        $state = 810;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 1 ) {
        $res[6] += 2;
        $state = 810;
      }
      elsif ( $t eq substr( "force-bounce-free", 0, $l ) && $l > 1 ) {
        $res[6] += 32;
        $state = 810;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] += 12;
        $state = 810;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 810; }
      elsif ( $t eq substr( "pull-up-resistor", 0, $l ) && $l > 0 ) {
        $res[6] += 16;
        $state = 810;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 810;
      }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 810;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 810 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] += 4;
        $state = 640;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 650; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 1 ) {
        $res[6] += 2;
        $state = 640;
      }
      elsif ( $t eq substr( "force-bounce-free", 0, $l ) && $l > 1 ) {
        $res[6] += 32;
        $state = 640;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] += 12;
        $state = 640;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 640; }
      elsif ( $t eq substr( "pull-up-resistor", 0, $l ) && $l > 0 ) {
        $res[6] += 16;
        $state = 640;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[6] += 1;
        $state = 640;
      }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] += 8;
        $state = 640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 820 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "default-config", 0, $l ) && $l > 0 ) {
        $res[6] = 179;
        $state = 830;
      }
      elsif ( $t eq substr( "full-default-config", 0, $l ) && $l > 0 ) { $state = 830; }
      elsif ( $t eq substr( "normal", 0, $l ) && $l > 0 ) {
        $res[6] = 217;
        $state = 830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 830 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 840 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 850 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 860 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "off", 0, $l ) && $l > 1 ) {
        $res[6] = 0;
        $state = 830;
      }
      elsif ( $t eq substr( "on", 0, $l ) && $l > 1 ) {
        $res[6] = 1;
        $state = 830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 870 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "off", 0, $l ) && $l > 1 ) {
        $res[6] = 0;
        $state = 830;
      }
      elsif ( $t eq substr( "on", 0, $l ) && $l > 1 ) {
        $res[6] = 1;
        $state = 830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 880 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[6] = $t;
          $state = 890;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 890 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "address", 0, $l ) && $l > 0 ) { $state = 900; }
      else { $state = 60300; }
    }
    elsif ( $state == 900 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[7] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 910 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 920 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "all", 0, $l ) && $l > 0 ) {
        $res[6] = 255;
        $res[7] = 255;
        $state  = 830;
      }
      elsif ( $t eq substr( "binary", 0, $l ) && $l > 1 ) { $state = 930; }
      elsif ( $t eq substr( "broadcast", 0, $l ) && $l > 1 ) {
        $res[7] = 128;
        $state = 830;
      }
      elsif ( $t eq substr( "none", 0, $l ) && $l > 0 ) { $state = 830; }
      else { $state = 60300; }
    }
    elsif ( $state == 930 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^[01]+$/ ) {
        if ( length($t) <= 16 ) {
          $res[6] = oct("0b$t") & 0xFF;
          $res[7] = oct("0b$t") >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 940 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "full", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 830;
      }
      elsif ( $t eq substr( "half", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 830;
      }
      elsif ( $t eq substr( "off", 0, $l ) && $l > 0 ) { $state = 830; }
      else { $state = 60300; }
    }
    elsif ( $state == 950 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 7 ) {
          $res[6] = $t;
          $state = 960;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 960 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) { $state = 970; }
      else { $state = 60300; }
    }
    elsif ( $state == 970 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 980 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "ack", 0, $l ) && $l > 1 ) {
        $res[6] = 160;
        $res[7] = 2;
        $state  = 830;
      }
      elsif ( $t eq substr( "all", 0, $l ) && $l > 1 ) {
        $res[6] = 255;
        $res[7] = 255;
        $state  = 830;
      }
      elsif ( $t eq substr( "binary", 0, $l ) && $l > 0 ) { $state = 990; }
      elsif ( $t eq substr( "error", 0, $l ) && $l > 0 ) {
        $res[6] = 64;
        $res[7] = 4;
        $state  = 830;
      }
      elsif ( $t eq substr( "input-event", 0, $l ) && $l > 0 ) {
        $res[6] = 16;
        $res[7] = 1;
        $state  = 830;
      }
      elsif ( $t eq substr( "none", 0, $l ) && $l > 0 ) { $state = 830; }
      elsif ( $t eq substr( "system", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 990 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^[01]+$/ ) {
        if ( length($t) <= 16 ) {
          $res[6] = oct("0b$t") & 0xFF;
          $res[7] = oct("0b$t") >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1000 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1010 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 30720 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1020 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1030 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "bounce-free", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1040;
      }
      elsif ( $t eq substr( "long", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1040;
      }
      elsif ( $t eq substr( "no-restriction", 0, $l ) && $l > 0 ) { $state = 1040; }
      elsif ( $t eq substr( "short", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 1040;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1040 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1050 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1060 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1070 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 1 && $t <= 256 ) {
          $res[6] = $t;
          $state = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1080 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 1100;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1090 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 1110;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1100 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "sample-rate", 0, $l ) && $l > 0 ) {
        $res[5] = 80;
        $state = 1120;
      }
      elsif ( $t eq substr( "trigger", 0, $l ) && $l > 0 ) { $state = 1130; }
      else { $state = 60300; }
    }
    elsif ( $state == 1110 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "sample-rate", 0, $l ) && $l > 0 ) {
        $res[5] = 144;
        $state = 1120;
      }
      elsif ( $t eq substr( "trigger", 0, $l ) && $l > 1 ) { $state = 1130; }
      elsif ( $t eq substr( "type", 0, $l ) && $l > 1 ) {
        $res[5] = 145;
        $state = 1180;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1120 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1130 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 1 ) {
          $res[5] += ( $t * 2 );
          $state = 1140;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1140 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "hysteresis", 0, $l ) && $l > 0 ) {
        $res[5] += 1;
        $state = 1160;
      }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) { $state = 1150; }
      else { $state = 60300; }
    }
    elsif ( $state == 1150 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 830;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1160 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1170;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1170 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "all-status-messages", 0, $l ) && $l > 0 ) {
        $res[8] = 12;
        $state = 830;
      }
      elsif ( $t eq substr( "limit-message", 0, $l ) && $l > 1 ) {
        $res[8] = 8;
        $state = 830;
      }
      elsif ( $t eq substr( "lower-limit-message", 0, $l ) && $l > 1 ) {
        $res[8] = 4;
        $state = 830;
      }
      elsif ( $t eq substr( "no-status-message", 0, $l ) && $l > 0 ) { $state = 830; }
      else { $state = 60300; }
    }
    elsif ( $state == 1180 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "ds18b20", 0, $l ) && $l > 4 ) {
        $res[7] = 1;
        $state = 830;
      }
      elsif ( $t eq substr( "ds18s20", 0, $l ) && $l > 4 ) {
        $res[7] = 2;
        $state = 830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1190 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 1240;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "new-address", 0, $l ) && $l > 0 ) {
        $res[7] = 192;
        $state = 1200;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1200 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 1210;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1210 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "status-modul-address", 0, $l ) && $l > 0 ) { $state = 1220; }
      else { $state = 60300; }
    }
    elsif ( $state == 1220 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1230 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 1240 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "down-modul", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1250;
      }
      elsif ( $t eq substr( "max-driving-time", 0, $l ) && $l > 0 ) {
        $res[6] = 128;
        $state = 1280;
      }
      elsif ( $t eq substr( "type", 0, $l ) && $l > 0 ) {
        $res[6] = 129;
        $state = 1290;
      }
      elsif ( $t eq substr( "up-modul", 0, $l ) && $l > 0 ) { $state = 1250; }
      else { $state = 60300; }
    }
    elsif ( $state == 1250 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[7] = $t;
          $state = 1260;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1260 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device", 0, $l ) && $l > 0 ) { $state = 1270; }
      else { $state = 60300; }
    }
    elsif ( $state == 1270 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1280 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1290 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "normal", 0, $l ) && $l > 0 ) { $state = 1230; }
      elsif ( $t eq substr( "pulse-contact-ctrl", 0, $l ) && $l > 0 ) {
        $res[7] += 1;
        $state = 1230;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1300 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 1340;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "new-address", 0, $l ) && $l > 0 ) {
        $res[7] = 224;
        $state = 1310;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1310 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 1320;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1320 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "status-modul-address", 0, $l ) && $l > 0 ) { $state = 1330; }
      else { $state = 60300; }
    }
    elsif ( $state == 1330 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1340 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "input-device-a", 0, $l ) && $l > 13 ) {
        $res[6] = 1;
        $state = 1350;
      }
      elsif ( $t eq substr( "input-device-b", 0, $l ) && $l > 13 ) {
        $res[6] = 2;
        $state = 1350;
      }
      elsif ( $t eq substr( "input-device-t", 0, $l ) && $l > 13 ) {
        $res[6] = 3;
        $state = 1350;
      }
      elsif ( $t eq substr( "input-modul", 0, $l ) && $l > 6 ) { $state = 1360; }
      elsif ( $t eq substr( "output-modul", 0, $l ) && $l > 0 ) {
        $res[6] = 4;
        $state = 1250;
      }
      elsif ( $t eq substr( "speed", 0, $l ) && $l > 0 ) {
        $res[6] = 5;
        $state = 1370;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1350 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1360 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[7] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1370 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1380 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "new-address", 0, $l ) && $l > 0 ) {
        $res[7] = 240;
        $state = 1390;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1390 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 1400;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1400 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "status-modul-address", 0, $l ) && $l > 0 ) { $state = 1410; }
      else { $state = 60300; }
    }
    elsif ( $state == 1410 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 1230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1420 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[5] = $t;
          $state = 1430;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1430 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "active-input", 0, $l ) && $l > 1 ) {
        $res[7] = 56;
        $state = 1760;
      }
      elsif ( $t eq substr( "addition-1", 0, $l ) && $l > 9 ) {
        $res[7] = 80;
        $state = 1960;
      }
      elsif ( $t eq substr( "addition-2", 0, $l ) && $l > 9 ) {
        $res[7] = 144;
        $state = 2540;
      }
      elsif ( $t eq substr( "addition-3", 0, $l ) && $l > 9 ) {
        $res[7] = 208;
        $state = 2770;
      }
      elsif ( $t eq substr( "and-2", 0, $l ) && $l > 4 ) {
        $res[7] = 128;
        $state = 2470;
      }
      elsif ( $t eq substr( "and-3", 0, $l ) && $l > 4 ) {
        $res[7] = 192;
        $state = 2770;
      }
      elsif ( $t eq substr( "control-element-0", 0, $l ) && $l > 0 ) {
        $res[7] = 96;
        $state = 1930;
      }
      elsif ( $t eq substr( "div-with-offset", 0, $l ) && $l > 3 ) {
        $res[7] = 85;
        $state = 2160;
      }
      elsif ( $t eq substr( "division-1", 0, $l ) && $l > 9 ) {
        $res[7] = 83;
        $state = 2080;
      }
      elsif ( $t eq substr( "division-2", 0, $l ) && $l > 9 ) {
        $res[7] = 147;
        $state = 2660;
      }
      elsif ( $t eq substr( "division-3", 0, $l ) && $l > 9 ) {
        $res[7] = 211;
        $state = 2770;
      }
      elsif ( $t eq substr( "equal-1", 0, $l ) && $l > 6 ) {
        $res[7] = 72;
        $state = 1930;
      }
      elsif ( $t eq substr( "equal-2", 0, $l ) && $l > 6 ) {
        $res[7] = 136;
        $state = 2510;
      }
      elsif ( $t eq substr( "falling-delay", 0, $l ) && $l > 1 ) {
        $res[7] = 112;
        $state = 2300;
      }
      elsif ( $t eq substr( "flipflop-0-2", 0, $l ) && $l > 11 ) {
        $res[7] = 152;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-0-3", 0, $l ) && $l > 11 ) {
        $res[7] = 216;
        $state = 2810;
      }
      elsif ( $t eq substr( "flipflop-1-2", 0, $l ) && $l > 11 ) {
        $res[7] = 153;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-1-3", 0, $l ) && $l > 11 ) {
        $res[7] = 217;
        $state = 2810;
      }
      elsif ( $t eq substr( "flipflop-2-2", 0, $l ) && $l > 11 ) {
        $res[7] = 154;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-2-3", 0, $l ) && $l > 11 ) {
        $res[7] = 218;
        $state = 2810;
      }
      elsif ( $t eq substr( "flipflop-3-2", 0, $l ) && $l > 11 ) {
        $res[7] = 155;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-3-3", 0, $l ) && $l > 11 ) {
        $res[7] = 219;
        $state = 2810;
      }
      elsif ( $t eq substr( "flipflop-4-2", 0, $l ) && $l > 11 ) {
        $res[7] = 156;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-4-3", 0, $l ) && $l > 11 ) {
        $res[7] = 220;
        $state = 2810;
      }
      elsif ( $t eq substr( "flipflop-5-2", 0, $l ) && $l > 11 ) {
        $res[7] = 157;
        $state = 2700;
      }
      elsif ( $t eq substr( "flipflop-5-3", 0, $l ) && $l > 11 ) {
        $res[7] = 221;
        $state = 2810;
      }
      elsif ( $t eq substr( "forward-control-1", 0, $l ) && $l > 16 ) {
        $res[7] = 107;
        $state = 2260;
      }
      elsif ( $t eq substr( "forward-control-2", 0, $l ) && $l > 16 ) {
        $res[7] = 171;
        $state = 2470;
      }
      elsif ( $t eq substr( "forward-control-3", 0, $l ) && $l > 16 ) {
        $res[7] = 235;
        $state = 2770;
      }
      elsif ( $t eq substr( "forward-greater-1", 0, $l ) && $l > 16 ) {
        $res[7] = 106;
        $state = 2260;
      }
      elsif ( $t eq substr( "forward-greater-2", 0, $l ) && $l > 16 ) {
        $res[7] = 170;
        $state = 2470;
      }
      elsif ( $t eq substr( "forward-greater-3", 0, $l ) && $l > 16 ) {
        $res[7] = 234;
        $state = 2770;
      }
      elsif ( $t eq substr( "forward-less-1", 0, $l ) && $l > 13 ) {
        $res[7] = 104;
        $state = 2260;
      }
      elsif ( $t eq substr( "forward-less-2", 0, $l ) && $l > 13 ) {
        $res[7] = 168;
        $state = 2470;
      }
      elsif ( $t eq substr( "forward-less-3", 0, $l ) && $l > 13 ) {
        $res[7] = 232;
        $state = 2770;
      }
      elsif ( $t eq substr( "forward-middle-1", 0, $l ) && $l > 15 ) {
        $res[7] = 105;
        $state = 2260;
      }
      elsif ( $t eq substr( "forward-middle-2", 0, $l ) && $l > 15 ) {
        $res[7] = 169;
        $state = 2470;
      }
      elsif ( $t eq substr( "forward-middle-3", 0, $l ) && $l > 15 ) {
        $res[7] = 233;
        $state = 2770;
      }
      elsif ( $t eq substr( "forward-timed", 0, $l ) && $l > 8 ) {
        $res[7] = 115;
        $state = 2300;
      }
      elsif ( $t eq substr( "greater-1", 0, $l ) && $l > 8 ) {
        $res[7] = 76;
        $state = 1930;
      }
      elsif ( $t eq substr( "greater-2", 0, $l ) && $l > 8 ) {
        $res[7] = 140;
        $state = 2510;
      }
      elsif ( $t eq substr( "greater-equal-1", 0, $l ) && $l > 14 ) {
        $res[7] = 77;
        $state = 1930;
      }
      elsif ( $t eq substr( "greater-equal-2", 0, $l ) && $l > 14 ) {
        $res[7] = 141;
        $state = 2510;
      }
      elsif ( $t eq substr( "input-delay", 0, $l ) && $l > 6 ) {
        $res[7] = 113;
        $state = 2300;
      }
      elsif ( $t eq substr( "input-limiting", 0, $l ) && $l > 6 ) {
        $res[7] = 114;
        $state = 2300;
      }
      elsif ( $t eq substr( "left-shift-1", 0, $l ) && $l > 11 ) {
        $res[7] = 69;
        $state = 1900;
      }
      elsif ( $t eq substr( "left-shift-2", 0, $l ) && $l > 11 ) {
        $res[7] = 133;
        $state = 2510;
      }
      elsif ( $t eq substr( "less-1", 0, $l ) && $l > 5 ) {
        $res[7] = 74;
        $state = 1930;
      }
      elsif ( $t eq substr( "less-2", 0, $l ) && $l > 5 ) {
        $res[7] = 138;
        $state = 2510;
      }
      elsif ( $t eq substr( "less-equal-1", 0, $l ) && $l > 11 ) {
        $res[7] = 75;
        $state = 1930;
      }
      elsif ( $t eq substr( "less-equal-2", 0, $l ) && $l > 11 ) {
        $res[7] = 139;
        $state = 2510;
      }
      elsif ( $t eq substr( "mult-with-offset", 0, $l ) && $l > 10 ) {
        $res[7] = 84;
        $state = 2120;
      }
      elsif ( $t eq substr( "mult-with-ratio-num", 0, $l ) && $l > 10 ) {
        $res[7] = 86;
        $state = 2200;
      }
      elsif ( $t eq substr( "multiplication-1", 0, $l ) && $l > 15 ) {
        $res[7] = 82;
        $state = 2040;
      }
      elsif ( $t eq substr( "multiplication-2", 0, $l ) && $l > 15 ) {
        $res[7] = 146;
        $state = 2620;
      }
      elsif ( $t eq substr( "multiplication-3", 0, $l ) && $l > 15 ) {
        $res[7] = 210;
        $state = 2770;
      }
      elsif ( $t eq substr( "nand-2", 0, $l ) && $l > 5 ) {
        $res[7] = 130;
        $state = 2470;
      }
      elsif ( $t eq substr( "nand-3", 0, $l ) && $l > 5 ) {
        $res[7] = 194;
        $state = 2770;
      }
      elsif ( $t eq substr( "native-output", 0, $l ) && $l > 2 ) {
        $res[7] = 121;
        $state = 2340;
      }
      elsif ( $t eq substr( "no-operation", 0, $l ) && $l > 3 ) { $state = 1440; }
      elsif ( $t eq substr( "no-vol-passive-input", 0, $l ) && $l > 3 ) {
        $res[7] = 60;
        $state = 1800;
      }
      elsif ( $t eq substr( "nor-2", 0, $l ) && $l > 4 ) {
        $res[7] = 131;
        $state = 2470;
      }
      elsif ( $t eq substr( "nor-3", 0, $l ) && $l > 4 ) {
        $res[7] = 195;
        $state = 2770;
      }
      elsif ( $t eq substr( "not-equal-1", 0, $l ) && $l > 10 ) {
        $res[7] = 73;
        $state = 1930;
      }
      elsif ( $t eq substr( "not-equal-2", 0, $l ) && $l > 10 ) {
        $res[7] = 137;
        $state = 2510;
      }
      elsif ( $t eq substr( "or-2", 0, $l ) && $l > 3 ) {
        $res[7] = 129;
        $state = 2470;
      }
      elsif ( $t eq substr( "or-3", 0, $l ) && $l > 3 ) {
        $res[7] = 193;
        $state = 2770;
      }
      elsif ( $t eq substr( "output", 0, $l ) && $l > 5 ) {
        $res[7] = 120;
        $state = 2340;
      }
      elsif ( $t eq substr( "output-modifier-0", 0, $l ) && $l > 16 ) {
        $res[7] = 63;
        $state = 1840;
      }
      elsif ( $t eq substr( "output-modifier-1", 0, $l ) && $l > 16 ) {
        $res[7] = 127;
        $state = 2410;
      }
      elsif ( $t eq substr( "property", 0, $l ) && $l > 0 ) {
        $state = 3520;
      }
      elsif ( $t eq substr( "right-shift-1", 0, $l ) && $l > 12 ) {
        $res[7] = 70;
        $state = 1900;
      }
      elsif ( $t eq substr( "right-shift-2", 0, $l ) && $l > 12 ) {
        $res[7] = 134;
        $state = 2510;
      }
      elsif ( $t eq substr( "status-output", 0, $l ) && $l > 1 ) {
        $res[7] = 122;
        $state = 2380;
      }
      elsif ( $t eq substr( "subtraction-1", 0, $l ) && $l > 12 ) {
        $res[7] = 81;
        $state = 2000;
      }
      elsif ( $t eq substr( "subtraction-2", 0, $l ) && $l > 12 ) {
        $res[7] = 145;
        $state = 2580;
      }
      elsif ( $t eq substr( "subtraction-3", 0, $l ) && $l > 12 ) {
        $res[7] = 209;
        $state = 2770;
      }
      elsif ( $t eq substr( "timer-day", 0, $l ) && $l > 6 ) {
        $res[7] = 34;
        $state = 1590;
      }
      elsif ( $t eq substr( "timer-hour", 0, $l ) && $l > 6 ) {
        $res[7] = 33;
        $state = 1510;
      }
      elsif ( $t eq substr( "timer-minute", 0, $l ) && $l > 6 ) {
        $res[7] = 32;
        $state = 1450;
      }
      elsif ( $t eq substr( "timer-week", 0, $l ) && $l > 6 ) {
        $res[7] = 35;
        $state = 1680;
      }
      elsif ( $t eq substr( "up-down-control-1", 0, $l ) && $l > 16 ) {
        $res[7] = 100;
        $state = 2240;
      }
      elsif ( $t eq substr( "up-down-control-2", 0, $l ) && $l > 16 ) {
        $res[7] = 164;
        $state = 2740;
      }
      elsif ( $t eq substr( "up-down-control-2-sh", 0, $l ) && $l > 17 ) {
        $res[7] = 165;
        $state = 2740;
      }
      elsif ( $t eq substr( "vol-passive-input", 0, $l ) && $l > 0 ) {
        $res[7] = 61;
        $state = 1800;
      }
      elsif ( $t eq substr( "xor-2", 0, $l ) && $l > 4 ) {
        $res[7] = 132;
        $state = 2470;
      }
      elsif ( $t eq substr( "xor-3", 0, $l ) && $l > 4 ) {
        $res[7] = 196;
        $state = 2770;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1440 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 1450 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "intervall-3", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1460;
      }
      elsif ( $t eq substr( "start-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 1470;
      }
      elsif ( $t eq substr( "start-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 1500;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1460 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1470 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1480;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1480 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "intervall-1", 0, $l ) && $l > 0 ) { $state = 1490; }
      else { $state = 60300; }
    }
    elsif ( $state == 1490 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[7] |= ( $t << 6 );
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1500 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 15 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1510 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "intervall-3", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1520;
      }
      elsif ( $t eq substr( "start-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 1530;
      }
      elsif ( $t eq substr( "start-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 1560;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1520 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1530 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1540;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1540 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "intervall-1", 0, $l ) && $l > 0 ) { $state = 1550; }
      else { $state = 60300; }
    }
    elsif ( $state == 1550 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[7] |= ( $t << 6 );
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1560 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1570;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1570 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "intervall-2", 0, $l ) && $l > 0 ) { $state = 1580; }
      else { $state = 60300; }
    }
    elsif ( $state == 1580 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[7] |= ( $t << 6 );
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1590 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "intervall-3", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1600;
      }
      elsif ( $t eq substr( "start-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 1610;
      }
      elsif ( $t eq substr( "start-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 1650;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1600 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1610 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 31 ) {
          $res[7] = $t;
          $state = 1620;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1620 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "saturday", 0, $l ) && $l > 1 ) {
        $res[7] |= 64;
        $state = 1630;
      }
      elsif ( $t eq substr( "sunday", 0, $l ) && $l > 1 ) {
        $res[7] |= 128;
        $state = 1630;
      }
      elsif ( $t eq substr( "workday", 0, $l ) && $l > 0 ) {
        $res[7] |= 32;
        $state = 1630;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1630 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "saturday", 0, $l ) && $l > 1 ) {
        $res[7] |= 64;
        $state = 1640;
      }
      elsif ( $t eq substr( "sunday", 0, $l ) && $l > 1 ) {
        $res[7] |= 128;
        $state = 1640;
      }
      elsif ( $t eq substr( "workday", 0, $l ) && $l > 0 ) {
        $res[7] |= 32;
        $state = 1640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1640 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "saturday", 0, $l ) && $l > 1 ) {
        $res[7] |= 64;
        $state = 1440;
      }
      elsif ( $t eq substr( "sunday", 0, $l ) && $l > 1 ) {
        $res[7] |= 128;
        $state = 1440;
      }
      elsif ( $t eq substr( "workday", 0, $l ) && $l > 0 ) {
        $res[7] |= 32;
        $state = 1440;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1650 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1660;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1660 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "intervall-2", 0, $l ) && $l > 0 ) { $state = 1670; }
      else { $state = 60300; }
    }
    elsif ( $state == 1670 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[7] |= ( $t << 6 );
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1680 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "intervall-3", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1690;
      }
      elsif ( $t eq substr( "start-1-day", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 1700;
      }
      elsif ( $t eq substr( "start-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 1730;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1690 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1700 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 7 ) {
          $res[7] = ( $t << 5 );
          $state = 1710;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1710 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "start-1-hour", 0, $l ) && $l > 0 ) { $state = 1720; }
      else { $state = 60300; }
    }
    elsif ( $state == 1720 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 31 ) {
          $res[7] |= $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1730 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1740;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1740 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "intervall-2", 0, $l ) && $l > 0 ) { $state = 1750; }
      else { $state = 60300; }
    }
    elsif ( $state == 1750 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[7] |= ( $t << 6 );
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1760 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 1770;
      }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1780;
      }
      elsif ( $t eq substr( "query-intervall", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 1790;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1770 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1780 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1790 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1800 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "default-value", 0, $l ) && $l > 2 ) {
        $res[6] = 3;
        $state = 1810;
      }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 2 ) {
        $res[6] = 2;
        $state = 1820;
      }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1830;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1810 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1820 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1830 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1840 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "default-value", 0, $l ) && $l > 2 ) {
        $res[6] = 1;
        $state = 1850;
      }
      elsif ( $t eq substr( "delay-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 1860;
      }
      elsif ( $t eq substr( "delay-3", 0, $l ) && $l > 6 ) {
        $res[6] = 3;
        $state = 1870;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1850 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1860 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1870 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1880;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1880 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 64;
        $state = 1890;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 128;
        $state = 1890;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1890 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 64;
        $state = 1440;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 128;
        $state = 1440;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1900 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "bits", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 1920;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1910;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1910 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1920 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 8 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1930 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1940;
      }
      elsif ( $t eq substr( "reference-value", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 1950;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1940 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1950 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1960 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 1970;
      }
      elsif ( $t eq substr( "summand-1", 0, $l ) && $l > 8 ) {
        $res[6] = 2;
        $state = 1980;
      }
      elsif ( $t eq substr( "summand-2", 0, $l ) && $l > 8 ) {
        $res[6] = 3;
        $state = 1990;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1970 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1980 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 1990 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2000 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2010;
      }
      elsif ( $t eq substr( "subtrahend-1", 0, $l ) && $l > 11 ) {
        $res[6] = 2;
        $state = 2020;
      }
      elsif ( $t eq substr( "subtrahend-2", 0, $l ) && $l > 11 ) {
        $res[6] = 3;
        $state = 2030;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2010 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2020 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2030 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2040 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "factor-1", 0, $l ) && $l > 7 ) {
        $res[6] = 2;
        $state = 2060;
      }
      elsif ( $t eq substr( "factor-2", 0, $l ) && $l > 7 ) {
        $res[6] = 3;
        $state = 2070;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2050;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2050 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2060 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2070 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2080 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "divisor-1", 0, $l ) && $l > 8 ) {
        $res[6] = 2;
        $state = 2100;
      }
      elsif ( $t eq substr( "divisor-2", 0, $l ) && $l > 8 ) {
        $res[6] = 3;
        $state = 2110;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2090;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2090 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2100 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2110 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2120 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "factor", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2150;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2130;
      }
      elsif ( $t eq substr( "summand", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 2140;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2130 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2140 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2150 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2160 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "divisor", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2190;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2170;
      }
      elsif ( $t eq substr( "summand", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 2180;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2170 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2180 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2190 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2200 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "divisor", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 2220;
      }
      elsif ( $t eq substr( "factor", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2230;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2210;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2210 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2220 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2230 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2240 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2250;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2250 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2260 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2270;
      }
      elsif ( $t eq substr( "value-1", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2280;
      }
      elsif ( $t eq substr( "value-2", 0, $l ) && $l > 6 ) {
        $res[6] = 3;
        $state = 2290;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2270 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2280 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2290 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2300 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2310;
      }
      elsif ( $t eq substr( "time", 0, $l ) && $l > 3 ) {
        $res[6] = 3;
        $state = 2320;
      }
      elsif ( $t eq substr( "time-base", 0, $l ) && $l > 4 ) {
        $res[6] = 2;
        $state = 2330;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2310 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2320 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2330 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "days", 0, $l ) && $l > 0 ) {
        $res[7] = 4;
        $state = 1440;
      }
      elsif ( $t eq substr( "hours", 0, $l ) && $l > 0 ) {
        $res[7] = 3;
        $state = 1440;
      }
      elsif ( $t eq substr( "minutes", 0, $l ) && $l > 0 ) {
        $res[7] = 2;
        $state = 1440;
      }
      elsif ( $t eq substr( "seconds", 0, $l ) && $l > 0 ) {
        $res[7] = 1;
        $state = 1440;
      }
      elsif ( $t eq substr( "tenth-of-a-second", 0, $l ) && $l > 0 ) {
        $res[7] = 0;
        $state = 1440;
      }
      elsif ( $t eq substr( "weeks", 0, $l ) && $l > 0 ) {
        $res[7] = 5;
        $state = 1440;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2340 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2350;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2360;
      }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 0 ) {
        $res[6] = 2;
        $state = 2370;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2350 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2360 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2370 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2380 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2390;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2400;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2390 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2400 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2410 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "delay-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2420;
      }
      elsif ( $t eq substr( "delay-3", 0, $l ) && $l > 6 ) {
        $res[6] = 3;
        $state = 2430;
      }
      elsif ( $t eq substr( "input", 0, $l ) && $l > 0 ) {
        $res[6] = 1;
        $state = 2460;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2420 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2430 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 2440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2440 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 64;
        $state = 2450;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 128;
        $state = 2450;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2450 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "falling-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 64;
        $state = 1440;
      }
      elsif ( $t eq substr( "rising-edge", 0, $l ) && $l > 0 ) {
        $res[7] |= 128;
        $state = 1440;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2460 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2470 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2480;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2490;
      }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2500;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2480 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2490 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2500 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2510 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2520;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2530;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2520 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2530 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2540 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2550;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2560;
      }
      elsif ( $t eq substr( "summand", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2570;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2550 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2560 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2570 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2580 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2590;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2600;
      }
      elsif ( $t eq substr( "subtrahend", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2610;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2590 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2600 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2610 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2620 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "factor", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2650;
      }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2630;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2640;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2630 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2640 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2650 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2660 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "divisor", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2690;
      }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2670;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2680;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2670 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2680 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2690 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2700 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-reset", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2710;
      }
      elsif ( $t eq substr( "input-set", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2720;
      }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) {
        $res[6] = 3;
        $state = 2730;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2710 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2720 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2730 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2740 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-down", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2750;
      }
      elsif ( $t eq substr( "input-up", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2760;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2750 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2760 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2770 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-1", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2780;
      }
      elsif ( $t eq substr( "input-2", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2790;
      }
      elsif ( $t eq substr( "input-3", 0, $l ) && $l > 6 ) {
        $res[6] = 3;
        $state = 2800;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2780 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2790 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2800 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2810 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "input-reset", 0, $l ) && $l > 6 ) {
        $res[6] = 2;
        $state = 2820;
      }
      elsif ( $t eq substr( "input-set", 0, $l ) && $l > 6 ) {
        $res[6] = 1;
        $state = 2830;
      }
      elsif ( $t eq substr( "input-value", 0, $l ) && $l > 6 ) {
        $res[6] = 3;
        $state = 2840;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2820 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2830 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2840 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 63 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2850 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "day", 0, $l ) && $l > 0 ) { $state = 2860; }
      else { $state = 60300; }
    }
    elsif ( $state == 2860 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 6 ) {
          $res[8] = $t;
          $state = 2870;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2870 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "hour", 0, $l ) && $l > 0 ) { $state = 2880; }
      else { $state = 60300; }
    }
    elsif ( $state == 2880 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 23 ) {
          $res[8] |= ( $t << 3 );
          $state = 2890;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2890 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "minute", 0, $l ) && $l > 0 ) { $state = 2900; }
      else { $state = 60300; }
    }
    elsif ( $state == 2900 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 59 ) {
          $res[7] = $t;
          $state = 2910;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2910 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "second", 0, $l ) && $l > 0 ) { $state = 2920; }
      else { $state = 60300; }
    }
    elsif ( $state == 2920 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 59 ) {
          $res[6] = $t;
          $state = 2930;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2930 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t eq substr( "hundredth", 0, $l ) && $l > 0 ) { $state = 2940; }
      else { $state = 60300; }
    }
    elsif ( $state == 2940 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 99 ) {
          $res[5] = $t;
          $state = 2950;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2950 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 2960 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 2970 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 0 ) { $state = 2980; }
      else { $state = 60300; }
    }
    elsif ( $state == 2980 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[5] = $t;
          $state = 2990;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 2990 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "hardware-address", 0, $l ) && $l > 0 ) { $state = 3000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3000 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3010;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3010 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 3020;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3020 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 3030;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3030 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3040 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 99 ) {
          $res[5] = $t;
          $state = 3050;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3050 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "modul-address", 0, $l ) && $l > 0 ) { $state = 3060; }
      else { $state = 60300; }
    }
    elsif ( $state == 3060 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3070;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3070 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 3080; }
      else { $state = 60300; }
    }
    elsif ( $state == 3080 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 3090;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3090 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3100 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 9 ) {
          $res[5] = $t;
          $state = 3110;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3110 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "makro", 0, $l ) && $l > 0 ) { $state = 3120; }
      else { $state = 60300; }
    }
    elsif ( $state == 3120 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 65535 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 3130;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3130 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3140 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 31 ) {
          $res[7] = $t;
          $state = 3150;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3150 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "button", 0, $l ) && $l > 0 ) { $state = 3160; }
      else { $state = 60300; }
    }
    elsif ( $state == 3160 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 127 ) {
          $res[5] = $t;
          $state = 3170;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3170 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "command", 0, $l ) && $l > 0 ) { $state = 3180; }
      else { $state = 60300; }
    }
    elsif ( $state == 3180 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 127 ) {
          $res[6] = $t;
          $state = 3190;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "all-off", 0, $l ) && $l > 5 ) {
        $res[6] = 15;
        $state = 3190;
      }
      elsif ( $t eq substr( "all-on", 0, $l ) && $l > 5 ) {
        $res[6] = 12;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-0", 0, $l ) && $l > 7 ) {
        $res[6] = 0;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-1", 0, $l ) && $l > 7 ) {
        $res[6] = 1;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-2", 0, $l ) && $l > 7 ) {
        $res[6] = 2;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-3", 0, $l ) && $l > 7 ) {
        $res[6] = 3;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-4", 0, $l ) && $l > 7 ) {
        $res[6] = 4;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-5", 0, $l ) && $l > 7 ) {
        $res[6] = 5;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-6", 0, $l ) && $l > 7 ) {
        $res[6] = 6;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-7", 0, $l ) && $l > 7 ) {
        $res[6] = 7;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-8", 0, $l ) && $l > 7 ) {
        $res[6] = 8;
        $state = 3190;
      }
      elsif ( $t eq substr( "button-9", 0, $l ) && $l > 7 ) {
        $res[6] = 9;
        $state = 3190;
      }
      elsif ( $t eq substr( "enter", 0, $l ) && $l > 0 ) {
        $res[6] = 38;
        $state = 3190;
      }
      elsif ( $t eq substr( "ignore", 0, $l ) && $l > 0 ) {
        $res[6] = 62;
        $state = 3190;
      }
      elsif ( $t eq substr( "makro", 0, $l ) && $l > 1 ) {
        $res[6] = 30;
        $state = 3190;
      }
      elsif ( $t eq substr( "minus", 0, $l ) && $l > 1 ) {
        $res[6] = 33;
        $state = 3190;
      }
      elsif ( $t eq substr( "plus", 0, $l ) && $l > 0 ) {
        $res[6] = 32;
        $state = 3190;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3190 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3200 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 3210;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3210 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3220;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3220 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 3230;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3230 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 3240;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3240 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3250 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 3260;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "e32", 0, $l ) && $l > 1 ) {
        $res[5] = 161;
        $state = 3260;
      }
      elsif ( $t eq substr( "e8", 0, $l ) && $l > 1 ) {
        $res[5] = 169;
        $state = 3260;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3260 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "read-address", 0, $l ) && $l > 0 ) { $state = 3270; }
      else { $state = 60300; }
    }
    elsif ( $state == 3270 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 32767 ) {
          $res[6] = $t & 0xFF;
          $res[7] = $t >> 8;
          $state  = 3280;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3280 ) {
      if ( $t eq "^10" || $t eq "^13" ) {
        $res[8] = 4;
        $state = 60000;
      }
      elsif ( $t eq substr( "number-of-bytes", 0, $l ) && $l > 0 ) { $state = 3290; }
      else { $state = 60300; }
    }
    elsif ( $state == 3290 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 64 ) {
          $res[8] = $t;
          $state = 3300;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3300 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3310 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "end", 0, $l ) && $l > 0 ) {
        $res[5] = 1;
        $state = 3320;
      }
      elsif ( $t eq substr( "start", 0, $l ) && $l > 4 ) {
        $res[5] = 0;
        $state = 3330;
      }
      elsif ( $t eq substr( "start-page-address", 0, $l ) && $l > 5 ) {
        $res[5] = 16;
        $state = 3340;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3320 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3330 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "firmware-download", 0, $l ) && $l > 0 ) {
        $res[6] = 16;
        $state = 3320;
      }
      elsif ( $t eq substr( "gui-config-download", 0, $l ) && $l > 0 ) {
        $res[6] = 32;
        $state = 3320;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3340 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 32767 ) {
          $res[7] = $t & 0xFF;
          $res[8] = $t >> 8;
          $state  = 3350;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3350 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "eeprom-address", 0, $l ) && $l > 0 ) { $state = 3360; }
      else { $state = 60300; }
    }
    elsif ( $state == 3360 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3320;
        }
        else { $state = 60310; }
      }
      elsif ( $t eq substr( "e32", 0, $l ) && $l > 1 ) {
        $res[6] = 160;
        $state = 3320;
      }
      elsif ( $t eq substr( "e8", 0, $l ) && $l > 1 ) {
        $res[6] = 168;
        $state = 3320;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3370 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[5] = $t;
          $state = 3380;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3380 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3390;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3390 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 3400;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3400 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 3410;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3410 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3420 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-busy", 0, $l ) && $l > 0 ) {
        $res[5] = 2;
        $state = 3430;
      }
      elsif ( $t eq substr( "no-response", 0, $l ) && $l > 0 ) {
        $res[5] = 1;
        $state = 3460;
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3430 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "device-address", 0, $l ) && $l > 0 ) { $state = 3440; }
      else { $state = 60300; }
    }
    elsif ( $state == 3440 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[6] = $t;
          $state = 3450;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3450 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60000; }
      else { $state = 60300; }
    }
    elsif ( $state == 3460 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "remote-modul-addr", 0, $l ) && $l > 0 ) { $state = 3470; }
      else { $state = 60300; }
    }
    elsif ( $state == 3470 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 239 ) {
          $res[6] = $t;
          $state = 3480;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3480 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "message-type", 0, $l ) && $l > 0 ) { $state = 3490; }
      else { $state = 60300; }
    }
    elsif ( $state == 3490 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 3500;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3500 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "remote-device-addr", 0, $l ) && $l > 0 ) { $state = 3510; }
      else { $state = 60300; }
    }
    elsif ( $state == 3510 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[8] = $t;
          $state = 3450;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3520 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 3 ) {
          $res[6] = $t;
          $state = 3530;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    elsif ( $state == 3530 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t eq substr( "value", 0, $l ) && $l > 0 ) { $state = 3540; }
      else { $state = 60300; }
    }
    elsif ( $state == 3540 ) {
      if ( $t eq "^10" || $t eq "^13" ) { $state = 60320; }
      elsif ( $t =~ /^\d+$/ ) {
        if ( $t >= 0 && $t <= 255 ) {
          $res[7] = $t;
          $state = 1440;
        }
        else { $state = 60310; }
      }
      else { $state = 60300; }
    }
    $i++;
  } until $state >= 60000;

  if ( $state == 60000 ) {
    my $flag = 0;
    if ($native) {
      my $marker = $stmnt;
      my $k      = 3;
      if ( $n > 7 ) { $k = 10 - $n; }
      for ( my $i = 0 ; $i < $n - 1 ; $i++ ) {
        if ( $s[$i] >= 0 && ( $s[$i] <= 255 || ( $n == 10 && $i == 0 && $s[$i] <= 65535 ) ) ) {
          my $tmp = $s[$i];
          $tmp    =~ s/./ /g;
          $marker =~ s/$s[$i]/$tmp/;
          $res[$k] = $s[$i];
          $k++;
        }
        else {
          $marker =~ s/^(\s*).*/$1/g;
          $marker .= "^";
          $flag = 1;
          $err  = $marker . "\n% Invalid input detected at '^' marker.";
          last;
        }
      }
    }
    if ( $flag == 0 ) {
      if ( $res[0] == -1 ) { $res[0] = &getConfig($self); }
      if ( $res[1] == -1 ) { $res[1] = &getVLAN( $self, $res[0] ); }
      if ( $res[2] == -1 ) { $res[2] = &getSource( $self, $res[0], $sessionSource ); }
    }
  }
  elsif ( $state == 60100 ) { $err = $prevState . " " . substr( $t, 0, length($t) - 3 ); }
  elsif ( $state == 60200 ) { $err = $prevState . " " . substr( $t, 0, length($t) - 2 ); }
  elsif ( $state == 60300 ) { $err = "% Unrecognized command\n"; }
  elsif ( $state == 60310 ) {
    my $marker = $stmnt;
    for ( my $k = 0 ; $k < $i - 1 ; $k++ ) {
      my $tmp = $s[$k];
      $tmp    =~ s/./ /g;
      $marker =~ s/$s[$k]/$tmp/;
    }
    $marker =~ s/^(\s*).*/$1/g;
    $marker .= "^";
    $err = $marker . "\n% Invalid input detected at '^' marker.\n";
  }
  elsif ( $state == 60320 ) { $err = "% Incomplete command\n"; }
  return $err, { vlan => $res[1], source => $res[2], destination => $res[3], mtype => $res[4], device => $res[5], v0 => $res[6], v1 => $res[7], v2 => $res[8] };
}

sub reverseParse {
  my ( $self, $statement ) = @_;

  #my @s = split( /\s+/, $statement );
  my @s;
  $s[0] = &getConfig($self);
  $s[1] = $statement->{vlan};
  $s[2] = $statement->{source};
  $s[3] = $statement->{destination};
  $s[4] = $statement->{mtype};
  $s[5] = $statement->{device};
  $s[6] = $statement->{v0};
  $s[7] = $statement->{v1};
  $s[8] = $statement->{v2};
  my $type = $s[4] & 3;
  $s[4] &= 252;
  my $result;
  if    ( $type == 1 ) { $result = "[ACK]"; }
  elsif ( $type == 2 ) { $result = "[ERROR]"; }
  else { $result = "[REQUEST]"; }
  $result .= " config ";
  $result .= &getConfigName($self, $s[0] );
  $result .= " vlan ";
  $result .= $s[1];
  $result .= " source ";
  $result .= $s[2];
  $result .= " destination ";
  $result .= $s[3];

  if ( $s[4] == 0 ) {
    $result .= " set device ";
    $result .= $s[5];
    if ( ( $s[6] & 243 ) == 160 ) {
      $result .= " trigger ";
      $result .= ( $s[6] & 12 ) >> 2;
      $result .= " value ";
      $result .= $s[8] << 8 | $s[7];
    }
    elsif ( $s[6] <= 100 ) {
      $result .= " value ";
      $result .= $s[6];
      if ( $s[7] > 0 || $s[8] > 0 ) {
        $result .= " delay ";
        $result .= $s[8] << 8 | $s[7];
      }
    }
    elsif ( $s[6] == 128 ) { $result .= " invert"; }
    elsif ( $s[6] == 129 ) { $result .= " increment"; }
    elsif ( $s[6] == 130 ) { $result .= " decrement"; }
    elsif ( $s[6] == 133 ) { $result .= " up"; }
    elsif ( $s[6] == 134 ) { $result .= " down"; }
    elsif ( $s[6] == 135 ) { $result .= " stop"; }
    elsif ( $s[6] == 136 ) { $result .= " start"; }
    else { $result = "[INVALID MESSAGE]"; }
  }
  elsif ( $s[4] == 8 ) {
    $result .= " query device ";
    $result .= $s[5];
    if ( ( $s[8] & 243 ) == 160 ) {
      $result .= " trigger ";
      $result .= ( $s[8] & 12 ) >> 2;
    }
    if ( $type == 1 ) {
      $result .= " value ";
      $result .= $s[7] << 8 | $s[6];
    }
  }
  elsif ( $s[4] == 16 ) {
    $result .= " status device ";
    $result .= $s[5];
    $result .= " value ";
    $result .= $s[7] << 8 | $s[6];
    $result .= " extension ";
    $result .= $s[8];
  }
  elsif ( $s[4] == 24 ) {
    $result .= " makro ";
    $result .= $s[7] << 8 | $s[6];
  }
  elsif ( $s[4] == 28 ) {
    if ( $type == 1 ) {
      $result .= " eeprom-data";
      $result .= " " . $s[5];
      $result .= " " . $s[6];
      $result .= " " . $s[7];
      $result .= " " . $s[8];
    }
    else {
      $result .= " eeprom-address ";
      if    ( $s[5] == 161 ) { $result .= "e32"; }
      elsif ( $s[5] == 169 ) { $result .= "e8"; }
      else { $result .= $s[5]; }
      $result .= " read-address ";
      $result .= $s[7] << 8 | $s[6];
      $result .= " number-of-bytes ";
      $result .= $s[8];
    }
  }
  elsif ( $s[4] == 56 ) {
    $result .= " protocol ";
    if ( $s[5] == 0 ) {
      $result .= "start ";
      if    ( $s[6] == 16 ) { $result .= "firmware-download"; }
      elsif ( $s[6] == 16 ) { $result .= "gui-config-download"; }
      else { $result = "[INVALID MESSAGE]"; }
    }
    elsif ( $s[5] == 1 ) { $result .= "end"; }
    elsif ( $s[5] == 16 ) {
      $result .= "start-page-address ";
      $result .= $s[8] << 8 | $s[7];
      $result .= " eeprom-address ";
      if    ( $s[6] == 160 ) { $result .= "e32"; }
      elsif ( $s[6] == 168 ) { $result .= "e8"; }
      else { $result .= $s[6]; }
    }
    else { $result = "[INVALID MESSAGE]"; }
  }
  elsif ( $s[4] == 60 ) {
    $result .= " data";
    $result .= " " . $s[5];
    $result .= " " . $s[6];
    $result .= " " . $s[7];
    $result .= " " . $s[8];
  }
  elsif ( $s[4] == 64 ) {
    $result .= " pin-config ";
    $result .= $s[5] & 31;
    if ( $s[5] < 32 ) {
      $result .= " type ";
      if ( ( $s[6] & 254 ) == 0 ) {
        $result .= "static-output ";
        if ( ( $s[6] & 1 ) == 0 ) { $result .= "low"; }
        else { $result .= "high"; }
      }
      elsif ( $s[6] == 2 ) { $result .= "buzzer"; }
      elsif ( $s[6] == 3 ) { $result .= "ir-receiver"; }
      elsif ( ( $s[6] & 254 ) == 4 ) {
        $result .= "serial-interface ";
        if ( ( $s[6] & 1 ) == 0 ) { $result .= "receiver"; }
        else { $result .= "transmitter"; }
      }
      elsif ( $s[6] == 6 )  { $result .= "zero-cross-detection"; }
      elsif ( $s[6] == 8 )  { $result .= "spi-ss"; }
      elsif ( $s[6] == 9 )  { $result .= "spi-mosi"; }
      elsif ( $s[6] == 10 ) { $result .= "spi-miso"; }
      elsif ( $s[6] == 11 ) { $result .= "spi-sc"; }
      elsif ( $s[6] == 12 ) { $result .= "twi-sc"; }
      elsif ( $s[6] == 13 ) { $result .= "twi-sd"; }
      elsif ( $s[6] == 16 ) { $result .= "switch"; }
      elsif ( $s[6] == 32 ) { $result .= "analog-input"; }
      elsif ( $s[6] == 40 ) { $result .= "digital-input"; }
      elsif ( ( $s[6] & 240 ) == 48 ) {
        $result .= "lcd ";
        if    ( ( $s[6] & 16 ) < 8 )   { $result .= "display-data " . $s[6] & 16; }
        elsif ( ( $s[6] & 16 ) == 8 )  { $result .= "read-write"; }
        elsif ( ( $s[6] & 16 ) == 9 )  { $result .= "register-select"; }
        elsif ( ( $s[6] & 16 ) == 10 ) { $result .= "enable"; }
      }
      elsif ( ( $s[6] & 240 ) == 64 ) {
        $result .= "dimmer";
        if ( ( $s[6] & 1 ) == 1 ) { $result .= " soft-delay"; }
        if ( ( $s[6] & 2 ) == 2 ) { $result .= " long-ignition"; }
        if ( ( $s[6] & 4 ) == 4 ) { $result .= " switch-restriction"; }
        if ( ( $s[6] & 8 ) == 8 ) { $result .= " trailing-edge-princ"; }
      }
      elsif ( ( $s[6] & 192 ) == 128 ) {
        $result .= "logical-input";
        if    ( ( $s[6] & 1 ) == 1 )   { $result .= " rising-edge"; }
        if    ( ( $s[6] & 2 ) == 2 )   { $result .= " falling-edge"; }
        if    ( ( $s[6] & 12 ) == 4 )  { $result .= " bounce-free"; }
        elsif ( ( $s[6] & 12 ) == 8 )  { $result .= " short"; }
        elsif ( ( $s[6] & 12 ) == 12 ) { $result .= " long"; }
        if    ( ( $s[6] & 16 ) == 16 ) { $result .= " pull-up-resistor"; }
        if    ( ( $s[6] & 32 ) == 32 ) { $result .= " force-bounce-free"; }
      }
      $result .= " device-address ";
      $result .= $s[7];
    }
    elsif ( ( $s[5] & 224 ) == 32 ) {
      $result .= " status-modul-address ";
      $result .= $s[6];
    }
  }
  elsif ( $s[4] == 68 ) {
    $result .= " ir-address ";
    $result .= $s[5];
    $result .= " modul-address ";
    $result .= $s[6];
    $result .= " device-address ";
    $result .= $s[7];
  }
  elsif ( $s[4] == 72 ) {
    $result .= " ir-hotkey ";
    $result .= $s[5];
    $result .= " makro ";
    $result .= $s[7] << 8 | $s[6];
  }
  elsif ( $s[4] == 76 ) {
    if    ( $s[5] == 1 ) { $result .= " system-reset"; }
    elsif ( $s[5] == 2 ) { $result .= " system-full-reset"; }
    elsif ( $s[5] == 3 ) { $result .= " config-reset"; }
    elsif ( $s[5] == 4 ) {
      $result .= " start-mode ";
      if    ( $s[6] == 217 ) { $result .= "normal"; }
      elsif ( $s[6] == 179 ) { $result .= "default-config"; }
      else { $result .= "full-default-config"; }
    }
    elsif ( $s[5] == 5 ) {
      $result .= " modul-address ";
      $result .= $s[6];
    }
    elsif ( $s[5] == 6 ) {
      $result .= " ccu-address ";
      $result .= $s[6];
    }
    elsif ( $s[5] == 7 ) {
      $result .= " time-server ";
      if ( $s[6] == 0 ) { $result .= "off"; }
      else { $result .= "on"; }
    }
    elsif ( $s[5] == 8 ) { $result .= " save-config"; }
    elsif ( $s[5] == 9 ) { $result .= " load-config"; }
    elsif ( $s[5] == 10 ) {
      $result .= " bridge-mode ";
      if ( $s[6] == 0 ) { $result .= "off"; }
      else { $result .= "on"; }
    }
    elsif ( $s[5] == 11 ) {
      $result .= " remote-extender ";
      $result .= $s[6];
      $result .= " address ";
      $result .= $s[7];
    }
    elsif ( $s[5] == 12 ) {
      $result .= " radio-vlan ";
      $result .= $s[6];
    }
    elsif ( $s[5] == 13 ) {
      $result .= " multicast-group ";
      my $tmp = $s[7] << 8 | $s[6];
      if    ( $tmp == 0 )     { $result .= "none"; }
      elsif ( $tmp == 32768 ) { $result .= "broadcast"; }
      elsif ( $tmp == 65535 ) { $result .= "all"; }
      else {
        $result .= "binary ";
        $result .= sprintf( "%016b", $tmp );
      }
    }
    elsif ( $s[5] == 14 ) {
      $result .= " encryption-mode ";
      if    ( $s[6] == 0 ) { $result .= "off"; }
      elsif ( $s[6] == 1 ) { $result .= "half"; }
      elsif ( $s[6] == 3 ) { $result .= "full"; }
      else { $result = "[INVALID MESSAGE]"; }
    }
    elsif ( $s[5] == 15 ) {
      $result .= " encryption-key ";
      $result .= $s[6];
      $result .= " value ";
      $result .= $s[7];
    }
    elsif ( $s[5] == 16 ) {
      $result .= " buzzer-level ";
      my $tmp = $s[7] << 8 | $s[6];
      if    ( $tmp == 0 )     { $result .= "none"; }
      elsif ( $tmp == 1 )     { $result .= "system"; }
      elsif ( $tmp == 1088 )  { $result .= "error"; }
      elsif ( $tmp == 672 )   { $result .= "ack"; }
      elsif ( $tmp == 272 )   { $result .= "input-event"; }
      elsif ( $tmp == 65535 ) { $result .= "all"; }
      else {
        $result .= "binary ";
        $result .= sprintf( "%016b", $tmp );
      }
    }
    elsif ( $s[5] == 18 ) {
      $result .= " canbus-vlan ";
      $result .= $s[6];
    }
    elsif ( $s[5] == 24 ) {
      $result .= " get-flash-flag";
      if ( $type == 1 ) {
        if    ( $s[6] == 0 )   { $result .= " ready-to-flash"; }
        elsif ( $s[6] == 255 ) { $result .= " no-firmware"; }
        else { $result = "[INVALID MESSAGE]"; }
      }
    }
    elsif ( $s[5] == 27 ) {
      $result .= " firmware-size ";
      $result .= $s[7] << 8 | $s[6];
    }
    elsif ( $s[5] == 28 ) {
      $result .= " get-version";
      if ( $type == 1 ) { $result .= " " . $s[6] . "." . $s[7] . "." . $s[8]; }
    }
    elsif ( $s[5] == 30 ) {
      $result .= " get-compiler-option ";
      $result .= $s[6];
      if ( $type == 1 ) {
        if ( $s[6] == 0 ) {
          if ( ( $s[7] & 1 ) == 1 )     { $result .= " eeprom-support"; }
          if ( ( $s[7] & 2 ) == 2 )     { $result .= " external-reset"; }
          if ( ( $s[7] & 4 ) == 4 )     { $result .= " buzzer"; }
          if ( ( $s[7] & 8 ) == 8 )     { $result .= " radio"; }
          if ( ( $s[7] & 16 ) == 16 )   { $result .= " can-bus"; }
          if ( ( $s[7] & 32 ) == 32 )   { $result .= " ir-interface"; }
          if ( ( $s[7] & 192 ) == 128 ) { $result .= " lcd-2x16"; }
          if ( ( $s[7] & 192 ) == 192 ) { $result .= " lcd-3x16"; }
        }
        elsif ( $s[6] == 1 ) {
          if ( ( $s[7] & 1 ) == 1 )     { $result .= " logical-input"; }
          if ( ( $s[7] & 2 ) == 2 )     { $result .= " analog-input"; }
          if ( ( $s[7] & 4 ) == 4 )     { $result .= " digital-thermometer"; }
          if ( ( $s[7] & 8 ) == 8 )     { $result .= " switch"; }
          if ( ( $s[7] & 16 ) == 16 )   { $result .= " dimmer"; }
          if ( ( $s[7] & 32 ) == 32 )   { $result .= " shutter-control"; }
          if ( ( $s[7] & 192 ) == 64 )  { $result .= " rotary-encoder-pec11"; }
          if ( ( $s[7] & 192 ) == 128 ) { $result .= " rotary-encoder-stec"; }
        }
        elsif ( $s[6] == 2 ) {
          if ( ( $s[7] & 1 ) == 1 ) { $result .= " gui"; }
          if ( ( $s[7] & 2 ) == 2 ) { $result .= " autonomous-control"; }
        }
        elsif ( $s[6] == 3 ) {
        }
      }
    }
    elsif ( $s[5] == 32 ) {
      $result .= " li-activation-time ";
      if    ( $s[6] == 0 ) { $result .= "no-restriction "; }
      elsif ( $s[6] == 1 ) { $result .= "bounce-free "; }
      elsif ( $s[6] == 2 ) { $result .= "short "; }
      elsif ( $s[6] == 3 ) { $result .= "long "; }
      $result .= $s[8] << 8 | $s[7];
    }
    elsif ( $s[5] == 36 ) {
      $result .= " dimmer-control-delay ";
      $result .= $s[6];
    }
    elsif ( $s[5] == 37 ) {
      $result .= " dimmer-ignition-len ";
      $result .= $s[7] << 8 | $s[6];
    }
    elsif ( ( $s[5] & 240 ) == 64 ) {
      $result .= " analog-input-device ";
      $result .= $s[6];
      $result .= " trigger ";
      $result .= $s[5] >> 1 & 7;
      if ( ( $s[5] & 1 ) == 0 ) {
        $result .= " value ";
        $result .= $s[8] << 8 | $s[7];
      }
      else {
        $result .= " hysteresis ";
        $result .= $s[7];
        if    ( ( $s[8] >> 2 & 3 ) == 0 ) { $result .= " no-status-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 1 ) { $result .= " lower-limit-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 2 ) { $result .= " limit-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 3 ) { $result .= " all-status-messages"; }
      }
    }
    elsif ( $s[5] == 80 ) {
      $result .= " analog-input-device ";
      $result .= $s[6];
      $result .= " sample-rate ";
      $result .= $s[8] << 8 | $s[7];
    }
    elsif ( $s[5] == 96 ) {
      $result .= " receive-buffer-len ";
      $result .= $s[6];
    }
    elsif ( ( $s[5] & 240 ) == 128 ) {
      $result .= " digital-input-device ";
      $result .= $s[6];
      $result .= " trigger ";
      $result .= $s[5] >> 1 & 7;
      if ( ( $s[5] & 1 ) == 0 ) {
        $result .= " value ";
        $result .= $s[8] << 8 | $s[7];
      }
      else {
        $result .= " hysteresis ";
        $result .= $s[7];
        if    ( ( $s[8] >> 2 & 3 ) == 0 ) { $result .= " no-status-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 1 ) { $result .= " lower-limit-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 2 ) { $result .= " limit-message"; }
        elsif ( ( $s[8] >> 2 & 3 ) == 3 ) { $result .= " all-status-messages"; }
      }
    }
    elsif ( $s[5] == 144 ) {
      $result .= " digital-input-device ";
      $result .= $s[6];
      $result .= " sample-rate ";
      $result .= $s[8] << 8 | $s[7];
    }
    elsif ( $s[5] == 145 ) {
      $result .= " digital-input-device ";
      $result .= $s[6];
      $result .= " type ";
      if    ( $s[7] == 1 ) { $result .= "ds18b20"; }
      elsif ( $s[7] == 2 ) { $result .= "ds18s20"; }
    }
  }
  elsif ( $s[4] == 80 ) {
    $result .= " ir-device ";
    $result .= $s[7];
    $result .= " button ";
    $result .= $s[5];
    $result .= " command ";
    if    ( $s[6] == 0 )  { $result .= "button-0"; }
    elsif ( $s[6] == 1 )  { $result .= "button-1"; }
    elsif ( $s[6] == 2 )  { $result .= "button-2"; }
    elsif ( $s[6] == 3 )  { $result .= "button-3"; }
    elsif ( $s[6] == 4 )  { $result .= "button-4"; }
    elsif ( $s[6] == 5 )  { $result .= "button-5"; }
    elsif ( $s[6] == 6 )  { $result .= "button-6"; }
    elsif ( $s[6] == 7 )  { $result .= "button-7"; }
    elsif ( $s[6] == 8 )  { $result .= "button-8"; }
    elsif ( $s[6] == 9 )  { $result .= "button-9"; }
    elsif ( $s[6] == 12 ) { $result .= "all-on"; }
    elsif ( $s[6] == 15 ) { $result .= "all-off"; }
    elsif ( $s[6] == 30 ) { $result .= "makro"; }
    elsif ( $s[6] == 32 ) { $result .= "plus"; }
    elsif ( $s[6] == 33 ) { $result .= "minus"; }
    elsif ( $s[6] == 38 ) { $result .= "enter"; }
    elsif ( $s[6] == 62 ) { $result .= "ignore"; }
  }
  elsif ( $s[4] == 84 ) {
    $result .= " ir-learn-command ";
    if    ( $s[6] == 0 )  { $result .= "button-0"; }
    elsif ( $s[6] == 1 )  { $result .= "button-1"; }
    elsif ( $s[6] == 2 )  { $result .= "button-2"; }
    elsif ( $s[6] == 3 )  { $result .= "button-3"; }
    elsif ( $s[6] == 4 )  { $result .= "button-4"; }
    elsif ( $s[6] == 5 )  { $result .= "button-5"; }
    elsif ( $s[6] == 6 )  { $result .= "button-6"; }
    elsif ( $s[6] == 7 )  { $result .= "button-7"; }
    elsif ( $s[6] == 8 )  { $result .= "button-8"; }
    elsif ( $s[6] == 9 )  { $result .= "button-9"; }
    elsif ( $s[6] == 12 ) { $result .= "all-on"; }
    elsif ( $s[6] == 15 ) { $result .= "all-off"; }
    elsif ( $s[6] == 30 ) { $result .= "makro"; }
    elsif ( $s[6] == 32 ) { $result .= "plus"; }
    elsif ( $s[6] == 33 ) { $result .= "minus"; }
    elsif ( $s[6] == 38 ) { $result .= "enter"; }
    elsif ( $s[6] == 62 ) { $result .= "ignore"; }

    if ( $type == 1 ) {
      $result .= " device ";
      $result .= $s[7];
      $result .= " button ";
      $result .= $s[5];
    }
  }
  elsif ( $s[4] == 88 ) {
    if ( $type == 3 ) { $result .= " display-control "; }
    else { $result .= " display-data "; }
    $result .= $s[5] . " " . $s[6] . " " . $s[7] . " " . $s[8];
  }
  elsif ( $s[4] == 96 ) {
    if ( $s[5] == 0 ) {
      if    ( $s[7] == 192 ) { $result .= " shutter-device"; }
      elsif ( $s[7] == 224 ) { $result .= " rotary-encoder-dev"; }
      elsif ( $s[7] == 240 ) { $result .= " gui-device"; }
      $result .= " new-address ";
      $result .= $s[6];
      $result .= " status-modul-address ";
      $result .= $s[8];
    }
    else {
      $result .= " abstract-device ";
      $result .= $s[5];
      $result .= " property ";
      $result .= $s[6];
      $result .= " value0 ";
      $result .= $s[7];
      $result .= " value1 ";
      $result .= $s[8];
    }
  }
  elsif ( $s[4] == 100 ) {
    if ( $s[8] == 255 ) { $result .= " ac-reset"; }
    else {
      $result .= " ac-object ";
      $result .= $s[5];
      $result .= " property ";
      $result .= $s[6];
      $result .= " value ";
      $result .= $s[7];
    }
  }
  elsif ( $s[4] == 120 ) {
    if ( $type < 3 ) {
      $result .= " time-set day ";
      $result .= $s[8] & 7;
      $result .= " hour ";
      $result .= $s[8] >> 3;
      $result .= " minute ";
      $result .= $s[7];
      $result .= " second ";
      $result .= $s[6];
      $result .= " hundredth ";
      $result .= $s[5];
    }
    else { $result .= " time-synch-request"; }
  }
  elsif ( $s[4] == 124 ) {
    if ( $type < 3 ) {
      $result .= " magic-packet modul-address ";
      $result .= $s[5];
      $result .= " hardware-address ";
      $result .= $s[6] . " " . $s[7] . " " . $s[8];
    }
    else {
      $result .= " error ";
      if ( $s[5] == 1 ) {
        $result .= "no-response remote-modul-addr ";
        $result .= $s[6];
        $result .= " message-type ";
        $result .= $s[7];
        $result .= " remote-device-addr ";
        $result .= $s[8];
      }
      elsif ( $s[5] == 2 ) {
        $result .= "device-busy device-address ";
        $result .= $s[6];
      }
    }
  }
  $result .= " [C:" . $s[0];
  $result .= ",V:" . $s[1];
  $result .= ",S:" . $s[2];
  $result .= ",D:" . $s[3];
  $result .= ",MT:" . ( $s[4] + $type );
  $result .= ",DEV:" . $s[5];
  $result .= ",V1:" . $s[6];
  $result .= ",V2:" . $s[7];
  $result .= ",V3:" . $s[8];
  $result .= "]";
  return $result;
}

1;
