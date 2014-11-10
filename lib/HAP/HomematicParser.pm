#öß§²

=head1 NAME

HAP::HomematicParser -  The Home Automation Project Homematic-Parser

=head1 DESCRIPTION

Builds Homematic-Datagrams 

=cut

package HAP::HomematicParser;
use strict;
use warnings;
use Time::HiRes qw(gettimeofday);

# 00 01=ack:seems to announce the new message counter
# 00 02=message send done, no ack was requested
# 00 08=nack - HMLAN did not receive an ACK,
#    10-info
# 00 21-'R'
#    41-info
# 00 81=open
# 01 00=with 'E', not 'R'.
# 00 81=open
# 04 xx=nothing will be sent anymore? try restart

my %mTypeToText = ( '00', 'config request', '02', 'ACK', '08', 'NACK', '10', 'info', '40', 'event', '41', 'event' );

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
  my ( $self, $dgram, $hmDeviceData ) = @_;
  my $error = undef;
  my $msg;
  my $tm    = &getTm;
  my $hexNo = &getMsgNo;

  my $hmId = $self->{c}->{Homematic}->{HmLanId};
  if ( $dgram->{mtype} == 0 && ($hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-Pl-2' || $hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-FM') ) {    # hap set command and wallmount-switch
    if ( $dgram->{v0} == 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020" . $hmDeviceData->{'channel'} . "000000" );
    }
    elsif ( $dgram->{v0} > 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020" . $hmDeviceData->{'channel'} . "C80000" );
    }
  }
  elsif ( $dgram->{mtype} == 0 && ($hmDeviceData->{'homematicDeviceType'} eq 'HM_LC_SW4_BA_PCB') ) {    # 4x Switch burst mode only ?
    if ( $dgram->{v0} == 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "B011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020" . $hmDeviceData->{'channel'} . "000000" );
    }
    elsif ( $dgram->{v0} > 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "B011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020" . $hmDeviceData->{'channel'} . "C80000" );
    }
  }
  elsif ( $dgram->{mtype} == 8 && ($hmDeviceData->{'homematicDeviceType'} eq 'HM_LC_SW4_BA_PCB') ) {    # hap query command on 4x Switch - burst mode only?
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmDeviceData->{'homematicAddress'} . "0" . $hmDeviceData->{'channel'} . "0E" );
  }
  elsif ( $dgram->{mtype} == 8 && ($hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-Pl-2' || $hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-FM') ) {    # hap query command
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmDeviceData->{'homematicAddress'} . "0" . $hmDeviceData->{'channel'} . "0E" );
  }
  else {
    $error = "% Unrecognized Homematic command or destination-device does not support the command";
  }
  return $error, $msg;
}

sub buildHmConfigDatagrams {
  my ( $self, $hmConfigDgram ) = @_;
  my $error = undef;
  my $msg;
  my $hmId = $self->{c}->{Homematic}->{HmLanId};
  my @arr;
  if ( $hmConfigDgram->{type} eq 'devicepair' ) {
    my $sChannel = sprintf( "%02d", $hmConfigDgram->{sChannel} );
    my $dChannel = sprintf( "%02d", $hmConfigDgram->{dChannel} );

    my $tm    = &getTm;
    my $hexNo = &getMsgNo;
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $sChannel . "01" . $hmConfigDgram->{destination} . $dChannel . "00" );
    push @arr, $msg;

    $tm    = &getTm;
    $hexNo = &getMsgNo;
    $msg   = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $sChannel . "05" . $hmConfigDgram->{destination} . $dChannel . "04" );
    push @arr, $msg;

    $tm    = &getTm;
    $hexNo = &getMsgNo;
    $msg   = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $sChannel . "08" . "0100" );
    push @arr, $msg;

    $tm    = &getTm;
    $hexNo = &getMsgNo;
    $msg   = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $sChannel . "06" );
    push @arr, $msg;

  }
  elsif ( $hmConfigDgram->{type} eq 'pairing' ) {

    my ( $idstr, $s ) = ( $hmId, 0xA );
    $idstr =~ s/(..)/sprintf("%02X%s",$s++,$1)/ge;

    my $dChannel = "00";    # global config or channel-based?

    # start config
    my $tm    = &getTm;
    my $hexNo = &getMsgNo;
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "05" . "00" . "00000000" );
    push @arr, $msg;

    # set id string
    $tm    = &getTm;
    $hexNo = &getMsgNo;
    $msg   = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "08" . "02" . "01" . $idstr );
    push @arr, $msg;

    # end config
    $tm    = &getTm;
    $hexNo = &getMsgNo;
    $msg   = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "06" );
    push @arr, $msg;
  }
  elsif ( $hmConfigDgram->{type} eq 'factoryreset' ) {
    my $tm    = &getTm;
    my $hexNo = &getMsgNo;
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A011" . $hmId . $hmConfigDgram->{target} . "04" . "00" );
    push @arr, $msg;
  }
  elsif ( $hmConfigDgram->{type} eq 'unpair' ) {
    my $tm       = &getTm;
    my $hexNo    = &getMsgNo;
    my $dChannel = sprintf( "%02d", $hmConfigDgram->{dChannel} );
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "08" . "02" . "01" . "0A000B000C00" );
    push @arr, $msg;
  }
  elsif ( $hmConfigDgram->{type} eq 'signing-off' ) {
    my $tm       = &getTm;
    my $hexNo    = &getMsgNo;
    my $dChannel = sprintf( "%02d", $hmConfigDgram->{dChannel} );
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "08" . "08" . "02" );
    push @arr, $msg;
  }
  elsif ( $hmConfigDgram->{type} eq 'signing-on' ) {
    my $tm       = &getTm;
    my $hexNo    = &getMsgNo;
    my $dChannel = sprintf( "%02d", $hmConfigDgram->{dChannel} );
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmConfigDgram->{target} . $dChannel . "08" . "08" . "01" );
    push @arr, $msg;
  }
  return @arr;
}

sub decrypt {
  my ( $self, $dgram, $homematicDevicesByHmId, $homematicMIdToHap ) = @_;
  my @mParts = split( ',', $dgram );
  my $leadingChar = substr( $mParts[0], 0, 1 );
  my $hmLanStatus = substr( $mParts[1], 0, 4 );

  # 00 01=ack:seems to announce the new message counter
  # 00 02=message send done, no ack was requested
  # 00 08=nack - HMLAN did not receive an ACK,
  #    10-info
  # 00 21-'R'
  #    41-info
  # 00 81=open
  # 01 00=with 'E', not 'R'.
  # 00 81=open
  # 04 xx=nothing will be sent anymore? try restart

  if ( $leadingChar =~ m/^I/ ) {    # Message from HMLan
    return $dgram;
  }

  if ( $leadingChar =~ m/^[ER]/ ) {
    my $mId         = substr( $mParts[0], 1,  8 );
    my $source      = substr( $mParts[5], 6,  6 );
    my $destination = substr( $mParts[5], 12, 6 );
    my $messageNo   = substr( $mParts[5], 0,  2 );
    my $flag        = substr( $mParts[5], 2,  2 );
    my $messageType = substr( $mParts[5], 4,  2 );
    my $payload     = substr( $mParts[5], 18 );

    # messageType 02 = AckStatus
    # messageType 10 = Info Level
    # messageType 41 = Event

    # flag: & 0x20 dann ACK required

    my $hmDgram = {
      mId         => $mId,
      source      => $source,
      destination => $destination,
      messageNo   => $messageNo,
      flag        => $flag,
      messageType => $messageType,
      mTypeText   => $mTypeToText{$messageType} || 'unknown',
      channel     => 0,
      payload     => $payload
    };

    if ( $hmLanStatus eq '0008' ) {    # no ack received -> timeout
      return ( $dgram, $hmDgram );
    }

    my $hapDgram = {
      vlan        => 0,
      source      => 0,
      destination => 0,
      device      => 0,
      mtype       => 0,
      v0          => 0,
      v1          => 0,
      v2          => 0
    };

    $hapDgram->{vlan}        = &getVLAN($self);
    $hapDgram->{source}      = $homematicDevicesByHmId->{$source}->{module};
    $hapDgram->{destination} = ( $homematicMIdToHap->{$mId} || $self->{c}->{CCUAddress} );

    if ( $messageType eq "02" ) {    #ACK Status
      $hapDgram->{mtype} = 1;
    }
    elsif ( $messageType eq "10" ) {    #Info Level
      $hapDgram->{mtype} = 9;
    }
    if ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} ) {
      if ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-LC-Sw1-Pl-2" || $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-LC-Sw1-FM" || $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM_LC_SW4_BA_PCB") {
        if ( ( $messageType eq "02" && $payload =~ m/^01/ )
          || ( $messageType eq "10" && $payload =~ m/^06/ ) )
        {
          if ( $payload =~ m/^(..)(..)(..)(..)/ ) {
            my ( $subType, $chn, $level, $err ) = ( $1, hex($2), $3, hex($4) );
            $hmDgram->{channel} = $chn;
            my $value = hex($level) / 2;
            $hapDgram->{v0}     = $value;
            $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} }->{address};
            return ( $hapDgram, $hmDgram );

          }
        }
      }
      elsif ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-Sec-SC" || $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-Sec-RHS" ) {
        if ( $messageType eq "41" ) {
          if ( $payload =~ m/^(..)(..)(..)/ ) {
            my ( $chn, $cnt, $state ) = ( hex($1), $2, $3 );
            $hmDgram->{channel} = $chn;
            if ( $state eq "C8" ) {    # open
              $hapDgram->{v0} = 200;
            }
            elsif ( $state eq "64" ) {    # tiled
              $hapDgram->{v0} = 100;
            }
            elsif ( $state eq "00" ) {    # closed
              $hapDgram->{v0} = 0;
            }
            $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} }->{address};
            return ( $hapDgram, $hmDgram );

          }
        }
      }
      elsif ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-PB-2-WM55" ) {    # wall mount push button 2 channel surface mount
        if ( $messageType =~ m/^4./ && $payload =~ m/^(..)(..)$/ ) {
          my ( $channel, $pushCount ) = ( hex($1), hex($2) );
          $hmDgram->{channel} = ( $channel & 0x3F );
          if ( defined( $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} } ) ) {    # filter channel
                #print "Current push-counter: $pushCount, previous:" . $homematicDevicesByHmId->{$source}->{pushCounter} . "\n";
                #$homematicDevicesByHmId->{$source}->{pushCounter} = $pushCount;
            if ( ( $channel & 0x40 ) == 0x40 ) {
              $hapDgram->{v0} = 140;
            }
            else {
              $hapDgram->{v0} = 132;
            }    # simulate short button push on logical-input
            $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} }->{address};
            return ( $hapDgram, $hmDgram );

          }
          else {
            return ( $dgram, $hmDgram );    # device not configured with this channel - ignore
          }
        }
      }
      elsif ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-Sec-MDIR" || $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-Sen-MDIR-O") {    # indoor and outdoor motion detector
        if ( $messageType eq "41" && $payload =~ m/^01(..)(..)(..)/ ) {
          my ( $cnt, $brigthness, $nextTr ) = ( hex($1), hex($2), ( hex($3) >> 4 ) );           # useable?
          $hapDgram->{v0}     = 132;
          $hmDgram->{channel} = 1;
          $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} }->{address};
          return ( $hapDgram, $hmDgram );
        }
        elsif ( $messageType eq "10" && $payload =~ m/^06(..)(..)(..)/ ) { # info 
            my ($chn, $brightness, $err) = ( hex($1), hex($2), hex($3) );
            $hapDgram->{v0} = $brightness;
            # we have to map the info-data to another channel, otherwise we are not able to differentiate between motion-detection data (HAP value 132) and brigthness-data
            # you need to create 2 virtual devices for this homematic-device: One for Motion-Detection and another one (on channel 2) for brigthness-Information.
            # Background: The Homematic-Datagram uses more than one byte for information, but the Autonomous-control in the CU can only use 1-byte Data for data-input  
            $hmDgram->{channel} = 2;
            $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{channels}->{ $hmDgram->{channel} }->{address};
            return ( $hapDgram, $hmDgram );
        }
      }
    }

    # No device matched - not configured in hap or unkown message
    return ( $dgram, $hmDgram );
  }
  return ( $dgram, undef );
}

sub getTm {
  return int( gettimeofday() * 1000 ) % 0xffffffff;
}

sub getMsgNo {
  my ($self) = @_;
  $self->{c}->{hmCmdNr} = $self->{c}->{hmCmdNr} ? ( $self->{c}->{hmCmdNr} + 1 ) % 256 : 1;
  return uc( sprintf "%02x", $self->{c}->{hmCmdNr} );
}

1;

