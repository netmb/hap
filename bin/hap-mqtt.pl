#!/usr/bin/perl

=head1 NAME

hap-mqtt.pl - Gateway-Service for MQTT

This services publishes every message that it receives as an MQTT-Topic + Value, e.g. : /HAP/module/device/status
Every MQTT-Client who subscribes to the topic, could receive the device values

To control HAP-Devices, this service is opening a subscription for every device it found in the HAP-Database
Every MQTT-Client could send publish a topic for this device

Supported data: ON, OFF, 0..255

=cut

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";
use POE;
use POE::Component::Client::TCP;
use POE::Wheel::Run;
use WebSphere::MQTT::Client;
use HAP::Init;
my $child;
my $c = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml", SKIP_DB => 1 );

# force child to terminate
$SIG{'INT'} = sub { print "Force termination\n"; $child->kill(9); exit; };

my $mqtt = new WebSphere::MQTT::Client(
  Hostname => $c->{MQTTBroker}->{Host},
  Port     => $c->{MQTTBroker}->{Port} + 0,
  Debug    => 1
);

$mqtt->connect();

POE::Component::Client::TCP->new(
  Alias         => 'tcpClient',
  RemoteAddress => $c->{MessageProcessor}->{Host},
  RemotePort    => $c->{MessageProcessor}->{Port},
  ConnectError  => \&tcpServerReconnect,
  Disconnected  => \&tcpServerReconnect,
  Connected     => sub {
    print
"Success. Connected to $c->{MessageProcessor}->{Host}:$c->{MessageProcessor}->{Port}\n";
  },
  ServerInput  => \&hapMpIn,
  InlineStates => {
    ServerOutput => sub {
      my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
      $heap->{server}->put($data);
    }
  },
);

POE::Session->create(
  inline_states => {
    _start => sub {

      $_[KERNEL]->alias_set('main');

      $child = POE::Wheel::Run->new(
        Program     => \&longRun,
        StdoutEvent => 'hapMpOut'
      );

      $_[KERNEL]->delay( updateStatus  => 5 );
      $_[KERNEL]->delay( subscribe => 5 );
    },
    subscribe => sub {
      my $res = $mqtt->subscribe('/hap/+/+');
    },
    updateStatus => sub {
      $mqtt->status();
      $_[KERNEL]->delay( updateStatus => 5 );
    },
    hapMpIn  => \&hapMpIn,
    hapMpOut => \&hapMpOut,
  },
);

$poe_kernel->run();

sub longRun {
  while () {
    my @res      = $mqtt->receivePub();
    my $topic    = $res[0];
    my $mqttData = $res[1];
    my ( $nope, $preamble, $destination, $address ) = split( '/', $topic );
    my $hapValue = $mqttData;
    if ($mqttData eq "ON") {
      $hapValue = 100;
    }
    elsif ($mqttData eq "OFF") {
      $hapValue = 0;
    }
    print "destination $destination set device $address value $hapValue\n";
  }
}

sub processStdOutFromLongRun {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
}

sub hapMpIn {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  print "Message Processor said: $data\n";
  if( $data =~ /.*SessionSource.*/) {
    $kernel->post( 'tcpClient' => ServerOutput =>'{"Debug" : 1}');
    #why does this not work?
    #$kernel->post( 'main' => hapMpOut => '{"Debug" : 1}'."\n" );
  }
  my $validData = 0;
  if ( $data =~
/.*vlan:(\d+).*source:(\d+).*destination:(\d+).*mtype:(\d+).*device:(\d+).*v0:(\d+).*v1:(\d+).*v2:(\d+)/
    )
  {
    $validData = 1;
  }
  elsif ( $data =~
/.*\[C:\d+,V:(\d+),S:(\d+),D:(\d+),MT:(\d+),DEV:(\d+),V1:(\d+),V2:(\d+),V3:(\d+)\].*/
    )
  {
    $validData = 1;
  }
  my $vlan        = $1;
  my $source      = $2;
  my $destination = $3;
  my $mType       = $4;
  my $device      = $5;
  my $v0          = $6;
  my $v1          = $7;
  my $v2          = $8;

  if ( $validData == 1 ) {
    my $mqttData = "OFF";
    if ( $v0 == 100 ) {
      $mqttData = "ON";
    }
    elsif ( $v0 > 0 ) {
      $mqttData = $v0;
    }

    my $topic = "/hap/$source/$device/status";
    my $res = $mqtt->publish( $mqttData, $topic, 0 );
  }
}

sub hapMpOut {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( $data =~ /.*destination.*/ ) { # only hap messages not debug messages
    print "Sending: $data\n";
    $kernel->post( 'tcpClient' => ServerOutput => $data );
  }
}

sub tcpServerReconnect {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
  print
"Connection to $c->{MessageProcessor}->{Host}:$c->{MessageProcessor}->{Port} lost. Trying reconnect...\n";
  $kernel->delay( reconnect => 2 );
}

