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
  my $tm = int( gettimeofday() * 1000 ) % 0xffffffff;
  $self->{c}->{hmCmdNr} = $self->{c}->{hmCmdNr} ? ( $self->{c}->{hmCmdNr} + 1 ) % 256 : 1;
  my $hexNo = sprintf "%02x", $self->{c}->{hmCmdNr};

  my $hmId = $self->{c}->{Homematic}->{HmLanId};
  if ( $dgram->{mtype} == 0 && $hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-Pl-2' )
  {                    # hap set command and wallmount-switch
    if ( $dgram->{v0} == 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020". $hmDeviceData->{'channel'}."000000" );
    }
    elsif ( $dgram->{v0} > 0 ) {
      $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A011" . $hmId . $hmDeviceData->{'homematicAddress'} . "020". $hmDeviceData->{'channel'}."C80000" );
    }
  }
  elsif ( $dgram->{mtype} == 8 && $hmDeviceData->{'homematicDeviceType'} eq 'HM-LC-Sw1-Pl-2' ) { # hap query command
    $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hexNo . "A001" . $hmId . $hmDeviceData->{'homematicAddress'} . "0". $hmDeviceData->{'channel'}."0E" );
  }
  else {
    $error = "% Unrecognized Homematic command or destination-device does not support the command";
  }
  return $error, $msg;
}

sub decrypt {
  my ( $self, $dgram, $homematicDevicesByHmId, $homematicMIdToHap ) = @_;

  my @mParts = split( ',', $dgram );
  my $leadingChar = substr( $mParts[0], 0, 1 );
  my $hmLanStatus = substr( $mParts[1], 0, 4 );
  
  if ( $hmLanStatus eq '0008' ) {    # no ack received -> timeout
    return $dgram;
  }

  # 0001=ack:seems to announce the new message counter
  # 0002=message send done, no ack was requested
  # 0008=nack - HMLAN did not receive an ACK,
  # 0021= 'R'
  # 0081=open
  # 0100=with 'E', not 'R'.
  # 0081=open
  # 04xx=nothing will be sent anymore? try restart

  if ( $leadingChar =~ m/^I/ ) {    # Message from HMLan
    return $dgram;
  }

  if ( $leadingChar =~ m/^[ER]/ ) {
    my $mId         = substr( $mParts[0], 1,  8 );
    my $source      = substr( $mParts[5], 6,  6 );
    my $destination = substr( $mParts[5], 12, 6 );
    my $flag = hex( substr( $mParts[5], 2, 2 ) );
    my $messageNo   = substr( $mParts[5], 0, 2 );
    my $messageType = substr( $mParts[5], 4, 2 );
    my $payload     = substr( $mParts[5], 18 );

    # messageType 2 = AckStatus
    # messageType 10 = Info Level
    # messageType 41 = Event

    my $hapDgram = {
      vlan        => 0,
      source      => 0,
      destination => 0,
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
    $hapDgram->{device} = $homematicDevicesByHmId->{$source}->{address};

    if ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-LC-Sw1-Pl-2" ) {
      if ( ( $messageType eq "02" && $payload =~ m/^01/ )
        || ( $messageType eq "10" && $payload =~ m/^06/ ) )
      {
        if ( $payload =~ m/^(..)(..)(..)(..)/ ) {
          my ( $subType, $chn, $level, $err ) = ( $1, $2, $3, hex($4) );
          my $value = hex($level) / 2;

          $hapDgram->{v0} = $value;
          $hapDgram->{v1} = 0;
          $hapDgram->{v2} = 0;
        }
      }
    }
    elsif ( $homematicDevicesByHmId->{$source}->{homematicDeviceType} eq "HM-Sec-SC" ) {
      if ( $messageType eq "41" ) {
        if ( $payload =~ m/^(..)(..)(..)/ ) {
          my ( $chn, $cnt, $state ) = ( $1, $2, $3 );

          if ( $state eq "C8" ) {    # open
            $hapDgram->{v0} = 200;
          }
          elsif ( $state eq "64" ) {    # tiled
            $hapDgram->{v0} = 100;
          }
          elsif ( $state eq "00" ) {    # closed
            $hapDgram->{v0} = 0;
          }
          $hapDgram->{v1} = 0;
          $hapDgram->{v2} = 0;
        }
      }
    }
    return $hapDgram;
  }
  return $dgram;
}

1;

