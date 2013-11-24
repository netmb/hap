#!/usr/bin/perl

=head1 NAME

hap-mp.pl - The Home Automation Project Message Processing Daemon

=cut

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";

use POE;
use POE::Component::Server::TCP;
use POE::Wheel::ReadWrite;
use POE::Component::EasyDBI;
use HAP::POE::Filter::Datagram;
use HAP::Init;
use HAP::Parser;
use HAP::HomematicParser;
use HAP::MessageRoutines;
use JSON::XS;
use Device::SerialPort;
use POE::Component::Client::TCP;
use Symbol qw(gensym);
use Time::HiRes qw(gettimeofday);
use Digest::MD5 qw(md5_hex);

my $json = new JSON::XS;
$json = $json->allow_unknown(1);
my $mroutine = new HAP::MessageRoutines();

my $c        = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml", SKIP_DB => 1 );
my $parser   = new HAP::Parser($c);
my $hmParser = new HAP::HomematicParser($c);

my %mapping;
my %homematicDevices;
my %homematicDevicesByHmId;
my $homematicState;
my %homematicMIdToHap;
my %makroByDatagram;
my $hmConfig;
my %hmMsgQueue;

foreach ( 224 .. 239 ) {    # Source-Addresses
  $mapping{$_} = undef;
}

################################################################################
# Sessions
################################################################################

POE::Component::EasyDBI->new(
  alias    => 'database',
  dsn      => $c->{'Model::hapModel'}->{'connect_info'}[0],
  username => $c->{'Model::hapModel'}->{'connect_info'}[1],
  password => $c->{'Model::hapModel'}->{'connect_info'}[2],
  options  => { autocommit => 1, },
);

POE::Session->create(
  inline_states => {
    _start => sub {
      $_[KERNEL]->alias_set('main');
      if ( $c->{ServerCUConnection}->{Type} eq 'Serial' ) {
        $_[KERNEL]->yield('serialSetup');
        $_[KERNEL]->yield('serialCheck');
      }
      $_[KERNEL]->yield('dbGetHomematicDevices');    #fill homematic hashes
      $_[KERNEL]->yield('dbGetMakroByDatagram');
      $_[KERNEL]->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', 'Startup complete.' );

    },
    serialSetup                  => \&serialSetup,
    serverCuIn                   => \&serverCuIn,
    serverCuOut                  => \&serverCuOut,
    hmLanIn                      => \&hmLanIn,
    hmLanOut                     => \&hmLanOut,
    clearMIdfromHash             => \&clearMIdfromHash,
    initHmLan                    => \&initHmLan,
    keepalive                    => \&keepalive,
    serialCheck                  => \&serialCheck,
    dbAddLogEntry                => \&dbAddLogEntry,
    dbGetModuleId                => \&dbGetModuleId,
    dbGetDeviceData              => \&dbGetDeviceData,
    dbUpdateStatus               => \&dbUpdateStatus,
    dbGetMakro                   => \&dbGetMakro,
    dbGetFirmwareId              => \&dbGetFirmwareId,
    dbGetHomematicDevices        => \&dbGetHomematicDevices,
    dbGetFirmwareOptions         => \&dbGetFirmwareOptions,
    dbUpdateFirmwareVersion      => \&dbUpdateFirmwareVersion,
    dbUpdateFirmwareOptions      => \&dbUpdateFirmwareOptions,
    dbGetMakroByDatagram         => \&dbGetMakroByDatagram,
    executeMakroScript           => \&executeMakroScript,
    executeMakroScriptByDatagram => \&executeMakroScriptByDatagram,
    multicastAlert               => \&multicastAlert,
    fillHomematicHash            => \&fillHomematicHash,
    fillMakroByDatagramHash      => \&fillMakroByDatagramHash
  },
);

POE::Component::Server::TCP->new(
  Alias              => 'tcpServer',
  Port               => $c->{MessageProcessor}->{Port},
  ClientConnected    => \&tcpClientConnect,
  ClientDisconnected => \&tcpClientDisconnect,
  ClientError        => \&tcpClientDisconnect,
  ClientInput        => \&tcpClientInput,
  InlineStates       => { ClientOutput => \&tcpClientOutput },
);

if ( $c->{ServerCUConnection}->{Type} eq 'Network' ) {
  POE::Component::Client::TCP->new(
    Alias         => 'tcpClient',
    RemoteAddress => $c->{ServerCUConnection}->{Host},
    RemotePort    => $c->{ServerCUConnection}->{Port},
    ConnectError  => \&tcpServerReconnect,
    Disconnected  => \&tcpServerReconnect,
    Connected     => sub {
      print "Success. Connected to $c->{ServerCUConnection}->{Host}:$c->{ServerCUConnection}->{Port}\n";
    },
    ServerInput  => \&serverCuIn,
    InlineStates => {
      ServerOutput => sub {
        my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
        $heap->{server}->put($data);
        }
    },
    Filter => HAP::POE::Filter::Datagram->new(),
  );
}

if ( $c->{Homematic}->{HmLanId} && length( $c->{Homematic}->{HmLanId} ) == 6 ) {
  POE::Component::Client::TCP->new(
    Alias         => 'hmLanClient',
    RemoteAddress => $c->{Homematic}->{HmLanIp},
    RemotePort    => $c->{Homematic}->{HmLanPort},
    ConnectError  => \&hmLanTcpServerReconnect,
    Disconnected  => \&hmLanTcpServerReconnect,
    Connected     => sub {
      print "Success. Connected to HMLAN $c->{Homematic}->{HmLanIp}:$c->{Homematic}->{HmLanPort}. Sending Initialization sequence\n";
      $homematicState->{dPend}    = 0;
      $homematicState->{lastSend} = 0;
      my $s2000 = sprintf( "%02X", secSince2000() );
      $_[KERNEL]->post( 'main' => hmLanOut  => "A$c->{Homematic}->{HmLanId}" );
      $_[KERNEL]->post( 'main' => hmLanOut  => "C" );
      my $hmSecKey = '';
      $hmSecKey = uc(md5_hex($c->{Homematic}->{HmSecKey})) if (defined($c->{Homematic}->{HmSecKey}) && length($c->{Homematic}->{HmSecKey}) > 0);
      $_[KERNEL]->post( 'main' => hmLanOut  => "Y01,01,".$hmSecKey );
      $_[KERNEL]->post( 'main' => hmLanOut  => "Y02,00," );
      $_[KERNEL]->post( 'main' => hmLanOut  => "Y03,00," );
      $_[KERNEL]->post( 'main' => hmLanOut  => "Y03,00," );
      $_[KERNEL]->post( 'main' => hmLanOut  => "T$s2000,04,00,00000000" );
      $_[KERNEL]->post( 'main' => hmLanOut  => "A$c->{Homematic}->{HmLanId}" );
      $_[KERNEL]->post( 'main' => keepalive => "" );
    },
    ServerInput  => \&hmLanIn,
    InlineStates => {
      ServerOutput => sub {
        my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
        if ( $heap->{connected} ) {
          $heap->{server}->put($data);
        }
        }
    }
  );
}

$poe_kernel->run();

################################################################################
# Serial
################################################################################

sub serialSetup {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
  my $handle = gensym();
  my $port   = undef;
  my $i      = 0;
  while ( !$port || !$port->rts_active("YES") ) {
    print "Trying to open $c->{ServerCUConnection}->{Ports}[$i]\n";
    $port = tie( *$handle, "Device::SerialPort", $c->{ServerCUConnection}->{Ports}[$i] );
    $i++;
    $i = 0 if ( $i >= scalar( @{ $c->{ServerCUConnection}->{Ports} } ) );
    select( undef, undef, undef, 0.5 );
  }
  print "Success. Opened $c->{ServerCUConnection}->{Ports}[$i - 1]\n";
  $port->datatype('raw');
  $port->user_msg("ON");
  $port->baudrate(19200);
  $port->databits(8);
  $port->parity("none");
  $port->stopbits(1);
  $port->handshake("none");
  $port->buffers( 8192, 8192 );
  $port->write_settings();
  $heap->{port}       = $port;
  $heap->{port_wheel} = POE::Wheel::ReadWrite->new(
    Handle     => $handle,
    Filter     => HAP::POE::Filter::Datagram->new(),
    InputEvent => "serverCuIn",
    ErrorEvent => sub {
      delete $heap->{port_wheel};
      $kernel->yield('serialSetup');
    },
  );
}

sub hmLanIn {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  print "HMLAN in raw   : $data\n";
  my @mParts = split( ',', $data );
  my $leadingChar = substr( $mParts[0], 0, 1 );
  if ( $leadingChar =~ m/^[ER]/ ) {
    my ( $hapMsg, $hmMsg ) = $hmParser->decrypt( $data, \%homematicDevicesByHmId, \%homematicMIdToHap );
    print
"HMLAN in parsed: mId:$hmMsg->{mId}, source: $hmMsg->{source}, dest: $hmMsg->{destination}, flag: $hmMsg->{flag}, msgNo: $hmMsg->{messageNo}, messageType: $hmMsg->{messageType}-$hmMsg->{mTypeText}, channel: $hmMsg->{channel}, payload: $hmMsg->{payload}\n";

    if ( $hmMsg->{messageType} eq '00' ) {    # someone pressed the config button on remote-homematic device
      print "Received Config-request from: $hmMsg->{source} \n";
      if ($hmConfig) {
        if ( $hmConfig->{type} eq 'pairing' ) {
          $hmConfig->{target} = $hmMsg->{source};
        }
        print "We have and Config-object of type $hmConfig->{type} for $hmConfig->{target}. Building command queue...\n";
        my @queue = $hmParser->buildHmConfigDatagrams($hmConfig);
        $hmMsgQueue{ $hmMsg->{source} } = { idx => 0, array => \@queue };
        $kernel->post( 'main' => hmLanOut => @{ $hmMsgQueue{ $hmMsg->{source} }->{array} }[ $hmMsgQueue{ $hmMsg->{source} }->{idx} ] );
      }
    }
    else {                                    # normal in
      if ( $hmMsgQueue{ $hmMsg->{source} } ) {    # we have remaining config-objects for this source
        $hmMsgQueue{ $hmMsg->{source} }->{idx}++;
        if ( scalar( @{ $hmMsgQueue{ $hmMsg->{source} }->{array} } ) >= $hmMsgQueue{ $hmMsg->{source} }->{idx} + 1 ) {
          $kernel->post( 'main' => hmLanOut => @{ $hmMsgQueue{ $hmMsg->{source} }->{array} }[ $hmMsgQueue{ $hmMsg->{source} }->{idx} ] );
        }
        else {
          delete($hmMsgQueue{ $hmMsg->{source} });
        }
      }
      else {                                      # do common stuff
        if ( ref($hapMsg) ) {
          print &composeAnswer( "HMLAN in to HAP:", $hapMsg ) . "\n";

          # Makro by datagram stuff
          my $mUid = buildHashFromMessagePart($hapMsg);
          if ( defined( $makroByDatagram{$mUid} ) ) {
            if ( checkValues( $makroByDatagram{$mUid}->{msg}, $hapMsg ) == 1 ) {
              $kernel->post(
                'main' => executeMakroScriptByDatagram => {
                  makro  => $makroByDatagram{$mUid}->{makro},
                  hapMsg => $hapMsg
                }
              );
            }
          }
        }

        if ( ref($hapMsg) && $homematicMIdToHap{ $hmMsg->{mId} } ) {    # looks like an received command initiated by a session
          $kernel->post( $mapping{ $homematicMIdToHap{ $hmMsg->{mId} } }->{session} => ClientOutput => $hapMsg );
          $kernel->delay('clearMIdfromHash');                           #remove auto-clean delay
          delete( $homematicMIdToHap{ $hmMsg->{mId} } );
        }

        if ( ref($hapMsg) && $homematicDevicesByHmId{ $hmMsg->{source} }->{channels}->{ $hmMsg->{channel} }->{notify} ) {    # valid message but no session, could be an event
          my $notifyHapMsg = {
            vlan        => $hapMsg->{vlan},
            source      => $hapMsg->{source},
            destination => $homematicDevicesByHmId{ $hmMsg->{source} }->{channels}->{ $hmMsg->{channel} }->{notify},
            device      => $hapMsg->{device},
            mtype       => 16,
            v0          => $hapMsg->{v0},
            v1          => $hapMsg->{v1},
            v2          => $hapMsg->{v2}
          };
          $kernel->post( main => serverCuOut => $notifyHapMsg );
          $kernel->post( main => serverCuIn  => $notifyHapMsg );
        }
      }
    }

    #send ack
    if ( $hmMsg->{destination} eq $c->{Homematic}->{HmVirtualId} ) {
      select(undef, undef, undef, 0.1);
      my $tm = int( gettimeofday() * 1000 ) % 0xffffffff;
      my $msg = sprintf( "S%08X,00,00000000,01,%08X,%s", $tm, $tm, $hmMsg->{messageNo} . "8002" . $c->{Homematic}->{HmVirtualId}. $hmMsg->{source} . "01010000" );
      $kernel->post( 'main' => hmLanOut => $msg );
    }
    else {
      $kernel->post( 'main' => hmLanOut => '+' . $hmMsg->{source} );
    }
  }
  else {
    print "Unprocessed: $data\n";
  }
}

sub hmLanOut {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];

  my $tn = gettimeofday();

  # calculate maximum data speed for HMLAN.
  #  Theorie 2,5kByte/s
  #  tested allowes no more then 2 byte/ms incl overhead
  #  It is even slower if HMLAN waits for acks, acks are missing,...
  my $bytPend = $homematicState->{dPend} - int( ( $tn - $homematicState->{lastSend} ) * 4000 );
  $bytPend = 0 if ( $bytPend < 0 );
  $homematicState->{dPend}    = $bytPend + length($data);
  $homematicState->{lastSend} = $tn;
  my $wait = $bytPend / 4000;    # HMLAN
                                 #  => wait time to protect HMLAN overload
                                 #  my $wait = $bytPend>>11; # fast divide by 2048

  # It is not possible to answer befor 100ms
  my $id = ( length($data) > 51 ) ? substr( $data, 46, 6 ) : "";
  my $DevDelay = 0;
  if ( $id && $homematicState->{nextSend}{$id} ) {
    $DevDelay = $homematicState->{nextSend}{$id} - $tn;                       # calculate time passed
    $DevDelay = ( $DevDelay > 0.01 ) ? ( $DevDelay -= int($DevDelay) ) : 0;
  }
  $wait = ( $DevDelay > $wait ) ? $DevDelay : $wait;                          # select the longer waittime
  select( undef, undef, undef, $wait ) if ( $wait > 0.01 );
  print "HMLAN out: $data\n";
  $kernel->post( 'hmLanClient' => ServerOutput => $data );
}

sub serverCuIn {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( !$c->{Crypto} ) {
    $data = $mroutine->decrypt( $data, $c->{CryptKey}, $c->{CryptOption} );    #$kernel->delay('serverCuOut'); # clear retransmit
  }
  print &composeAnswer( "Serial in:", $data ) . "\n";  
  # Makro by datagram stuff
  my $mUid = buildHashFromMessagePart($data);
  if ( defined( $makroByDatagram{$mUid} ) ) {
    if ( checkValues( $makroByDatagram{$mUid}->{msg}, $data ) == 1 ) {
      $kernel->post(
        'main' => executeMakroScriptByDatagram => {
          makro  => $makroByDatagram{$mUid}->{makro},
          hapMsg => $data
        }
      );
    }
  }

  if ( $data->{mtype} == 77
    && ( $data->{device} == 128 || $data->{device} == 130 ) )
  {
    $kernel->post( 'main' => dbGetModuleId => $data );
  }
  if ( $data->{mtype} == 9 || $data->{mtype} == 16 ) {
    $kernel->post( 'main' => dbGetModuleId => $data );
  }
  elsif ( $data->{mtype} == 123 ) {    # Timesync
    $kernel->post( main => serverCuOut => $mroutine->getTime($data) );
    return;
  }
  elsif ( $data->{mtype} == 24 ) {     # Makro
    $kernel->post( 'main' => dbGetMakro => $data );
  }
  elsif ( $data->{mtype} == 77 && $data->{device} == 28 ) {    # Firmware-Version
    $kernel->post( 'main' => dbGetFirmwareId => $data );
  }
  elsif ( $data->{mtype} == 77 && $data->{device} == 30 ) {    # Firmware-Version
    $kernel->post( 'main' => dbGetFirmwareOptions => $data );
  }

  # Special handling for loopback communication (Server himself is destination)
  if ( $data->{destination} == $c->{CCUAddress} ) {
    my $sData = {
      vlan        => $data->{vlan},
      source      => $c->{CCUAddress},
      destination => $data->{source},
      mtype       => $data->{mtype} + 1,
      v0          => $data->{v0},
      v1          => $data->{v1},
      v2          => $data->{v2}
    };
    $kernel->post( $mapping{ $data->{source} }->{session} => ClientOutput => $sData );
  }
  else {
    $kernel->post( $mapping{ $data->{destination} }->{session} => ClientOutput => $data );
  }

  # Start Script on Multicast
  if ( $data->{destination} >= 240
    && $data->{destination} <= 253
    && $data->{mtype} == 16 )
  {
    $kernel->post( 'main' => multicastAlert => $data );
  }

  return;
}

sub serverCuOut {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( !$c->{Crypto} ) {
    $data = $mroutine->crypt( $data, $c->{CryptKey}, $c->{CryptOption} );
  }
  print &composeAnswer( "Serial out:", $data ) . "\n";
  if ( $c->{ServerCUConnection}->{Type} eq 'Serial' ) {
    $heap->{port_wheel}->put($data);
  }
  else {
    $kernel->post( 'tcpClient' => ServerOutput => $data );
  }
  $! = 0;
  return;
}

sub serialCheck {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
  if ( !$heap->{port}->rts_active("YES") ) {
    print "Detected Serial-Connection is lost.\n";
    $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', 'Detected Serial-Connection lost.' );
    $kernel->yield('serialSetup');
  }
  $kernel->delay_add( 'serialCheck', 60 );
}

################################################################################
# Database
################################################################################

sub dbGetModuleId {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0, ARG1 ];
  $kernel->post(
    'database',
    'single' => {
      sql     => "SELECT ID from module WHERE Config=$c->{DefaultConfig} AND Address=$data->{source}",
      hapData => $data,
      event   => 'dbGetDeviceData',
    },
  );

}

sub dbGetDeviceData {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0, ARG1 ];
  if ( $data->{result} ) {
    my $module = $data->{result};
    my $device = $data->{hapData}->{device};
    if (
      $data->{hapData}->{mtype} == 77
      && ( $data->{hapData}->{device} == 128
        || $data->{hapData}->{device} == 130 )
      )
    {
      $device = $data->{hapData}->{v0};
    }

    $kernel->post(
      'database',
      'arrayhash' => {
        sql => "
SELECT device.Name, device.Formula, Type FROM device WHERE device.Config=$c->{DefaultConfig} AND device.Module=$module AND device.Address=$device UNION 
SELECT logicalinput.Name, logicalinput.Formula, 128 AS \"Type\" FROM logicalinput WHERE logicalinput.Config=$c->{DefaultConfig} AND logicalinput.Module=$module AND logicalinput.Address=$device UNION
SELECT digitalinput.Name,digitalinput.Formula, 40 AS \"Type\" FROM digitalinput WHERE digitalinput.Config=$c->{DefaultConfig} AND digitalinput.Module=$module AND digitalinput.Address=$device UNION 
SELECT analoginput.Name, analoginput.Formula, 32 AS \"Type\" FROM analoginput WHERE analoginput.Config=$c->{DefaultConfig} AND analoginput.Module=$module AND analoginput.Address=$device UNION
SELECT abstractdevice.Name, NULL, 192 AS \"Type\" FROM abstractdevice WHERE abstractdevice.Config=$c->{DefaultConfig} AND abstractdevice.Module=$module AND abstractdevice.Address=$device UNION
SELECT homematic.Name, homematic.Formula, 0 FROM homematic WHERE homematic.Config=$c->{DefaultConfig} AND homematic.Module=$module and homematic.Address=$device
"
        ,
        dbModuleId => $module,
        hapData    => $data->{hapData},
        event      => 'dbUpdateStatus',
      },
    );

  }
}

sub dbUpdateStatus {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  foreach ( @{ $data->{result} } ) {
    if (
      $data->{hapData}->{mtype} == 77
      && ( $data->{hapData}->{device} == 128
        || $data->{hapData}->{device} == 130 )
      )
    {
      my $status = $data->{hapData}->{v2} * 256 + $data->{hapData}->{v1};
      if ( $_->{'Formula'} ) {
        my $formula = $_->{'Formula'};
        $formula =~ s/x|X/$status/g;
        $status = eval($formula);
      }
      $kernel->post(
        'database',
        insert => {
          sql          => 'INSERT INTO status (TS, Type, Module, Address, Status, Config) VALUES (?,?,?,?,?,?)',
          placeholders => [ time(), 76, $data->{dbModuleId}, $data->{hapData}->{v0}, $status, $c->{DefaultConfig} ],
          event        => '',
        }
      );

    }

    # Update Status only if message is not a Digital- or Analog-Input trigger-Status-Message
    elsif ( !( ( $_->{'Type'} == 32 || $_->{'Type'} == 40 ) && $data->{hapData}->{mtype} == 16 ) ) {
      my $status = $data->{hapData}->{v1} * 256 + $data->{hapData}->{v0};
      if ( $_->{'Formula'} ) {
        my $formula = $_->{'Formula'};
        $formula =~ s/x|X/$status/g;
        $status = eval($formula);
      }
      $kernel->post(
        'database',
        insert => {
          sql          => 'INSERT INTO status (TS, Type, Module, Address, Status, Config) VALUES (?,?,?,?,?,?)',
          placeholders => [ time(), $_->{'Type'}, $data->{dbModuleId}, $data->{hapData}->{device}, $status, $c->{DefaultConfig} ],
          event        => '',
        }
      );
      $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', "$_->{Name} Status $status" );
    }
  }
}

sub dbGetHomematicDevices {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql =>
"SELECT module2.Address as Module, homematic.Address, homematic.HomematicAddress, static_homematicdevicetypes.Name as HomematicDeviceType, module.Address as Notify, homematic.Channel FROM homematic 
left join static_homematicdevicetypes on HomematicDeviceType = static_homematicdevicetypes.ID 
left join module on Notify = module.ID
left join module as module2 on Module = module2.ID
WHERE homematic.Config = $c->{DefaultConfig}",
      event => 'fillHomematicHash',
    },
  );
}

sub dbGetFirmwareId {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql      => "SELECT ID FROM firmware WHERE VMajor = $data->{v0} AND VMinor = $data->{v1} AND VPhase = $data->{v2}",
      datagram => $data,
      event    => 'dbUpdateFirmwareVersion',
    },
  );
}

sub dbUpdateFirmwareVersion {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  foreach ( @{ $data->{result} } ) {
    $kernel->post(
      'database',
      do => {
        sql          => 'UPDATE module SET FirmwareVersion = ?, CurrentFirmwareID = ? WHERE Address = ? AND Config = ?',
        placeholders => [ "$data->{datagram}->{v0}.$data->{datagram}->{v1}.$data->{datagram}->{v1}", $_->{ID}, $data->{datagram}->{source}, $c->{DefaultConfig} ],
        event        => '',
      }
    );
  }
}

sub dbGetFirmwareOptions {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql      => "SELECT CurrentFirmwareOptions FROM module WHERE Address = $data->{source}  AND Config = $c->{DefaultConfig}",
      datagram => $data,
      event    => 'dbUpdateFirmwareOptions',
    },
  );
}

sub dbUpdateFirmwareOptions {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  foreach ( @{ $data->{result} } ) {
    $kernel->post(
      'database',
      do => {
        sql          => 'UPDATE module SET CurrentFirmwareOptions = ? WHERE Address = ? AND Config = ?',
        placeholders => [ $_->{CurrentFirmwareOptions} | ( $data->{datagram}->{v1} << ( 8 * $data->{datagram}->{v0} ) ), $data->{datagram}->{source}, $c->{DefaultConfig} ],
        event        => '',
      }
    );
  }
}

sub dbGetMakro {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  my $makroNr = $data->{v1} * 256 + $data->{v0};
  $kernel->post(
    'database',
    'arrayhash' => {
      sql   => "SELECT Name, ID FROM makro WHERE MakroNr = $makroNr AND Config = $c->{DefaultConfig}",
      event => 'executeMakroScript',
    },
  );
}

sub dbGetMakroByDatagram {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql =>
"SELECT makro_by_datagram.VLAN, module.Address as Source, module2.Address as Destination, MType, makro_by_datagram.Address as Device, v0, v1, v2, makro.ID, makro.Name FROM hap.makro_by_datagram 
left join module on module.id = Source
left join module as module2 on module2.id = Destination
left join makro on makro.id = Makro
where Active = 1 and makro_by_datagram.Config = $c->{DefaultConfig}",
      event => 'fillMakroByDatagramHash',
    },
  );
}

sub dbAddLogEntry {
  my ( $kernel, $heap, $session, $pid, $source, $type, $message ) = @_[ KERNEL, HEAP, SESSION, ARG0, ARG1, ARG2, ARG3 ];
  my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
  my $time = sprintf( "%4d-%02d-%02d %02d:%02d:%02d ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec );
  $kernel->post(
    'database',
    insert => {
      sql          => 'INSERT INTO log (Time, PID, Source, Type, Message) VALUES (?,?,?,?,?)',
      placeholders => [ $time, $pid, $source, $type, $message ],
      event        => '',
    }
  );
}

################################################################################
# TCP-Server (Communication with Human-Interface)
################################################################################

sub tcpClientConnect {
  my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
  foreach my $key ( keys %mapping ) {
    if ( !$mapping{$key} ) {

      #my $c = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml" );
      print "Source:" . $key . " -> Session:" . $session->ID . "\n";

      #$mapping{$key} = { session => $session->ID, c => $c };
      $mapping{$key} = { session => $session->ID };

      #$heap->{c} = $c;
      $heap->{SessionSource} = $key;

      #$heap->{parser} = new HAP::Parser($c);
      last;
    }
  }
  if ( $heap->{SessionSource} ) {
    $heap->{client}->put("\{\"SessionSource\": $heap->{SessionSource}\}");
  }
  else {
    $heap->{client}->put("% Sorry, no sessions left. Exiting.\n");
    $kernel->yield('shutdown');
  }
}

sub tcpClientDisconnect {
  my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
  if ( $heap->{SessionSource} ) {
    $mapping{ $heap->{SessionSource} } = undef;
  }
}

sub tcpClientInput {
  my ( $kernel, $session, $heap, $data ) = @_[ KERNEL, SESSION, HEAP, ARG0 ];
  if ( $data =~ /\{.*\}/i ) {    # config-object
    my $cObj;
    eval { $cObj = $json->decode($data); };
    if ($@) {
      $heap->{client}->put("% Unknown Config Object");
      return;
    }
    if ( defined( $cObj->{DefaultConfig} ) ) {
      $c = new HAP::Init(
        FILE   => "$FindBin::Bin/../etc/hap.yml",
        CONFIG => $cObj->{DefaultConfig}
      );
      $parser = new HAP::Parser($c);
      print "Set Config to $cObj->{DefaultConfig}\n";
      $heap->{client}->put("[ACK] Set Config to $cObj->{DefaultConfig}");
    }
    if ( defined( $cObj->{DefaultVLAN} ) ) {
      $c->{DefaultVLAN} = $cObj->{DefaultVLAN};
      $heap->{client}->put("[ACK] Set VLAN to $cObj->{DefaultVLAN}");
    }
    if ( defined( $cObj->{Crypto} ) ) {
      $c->{Crypto} = $cObj->{Crypto};
      $heap->{client}->put("[ACK] Set Crypto to $cObj->{Crypto}");
    }
    if ( defined( $cObj->{MCastGroup} ) ) {
      my $tmp = $cObj->{MCastGroup};
      if ( ref $tmp && scalar(@$tmp) == 0 ) {
        $heap->{MCastGroup}   = undef;
        $heap->{MCastAddress} = undef;
      }
      else {
        $heap->{MCastGroup} = $cObj->{MCastGroup};
      }
      $heap->{client}->put("[ACK] Set Multicast Group");
    }
    if ( defined( $cObj->{MCastAddress} ) ) {    # maybe Zero so also false
      if ( $cObj->{MCastAddress} == 0 ) {
        $heap->{MCastGroup}   = undef;
        $heap->{MCastAddress} = undef;
        $heap->{client}->put("[ACK] Disabled Multicast");
      }
      elsif ( $cObj->{MCastAddress} < 240 ) {
        $heap->{client}->put("[ERR] Multicast Addresses < 240 are not allowed");
      }
      else {
        $heap->{MCastAddress} = $cObj->{MCastAddress};
        $heap->{client}->put("[ACK] Set Multicast Addresses to $cObj->{MCastAddress}");
      }
    }
    if ( defined( $cObj->{HomematicRefresh} ) ) {
      $kernel->post( main => 'dbGetHomematicDevices' );
    }
    if ( defined( $cObj->{MakroByDatagramUpdate} ) ) {
      $kernel->post( main => 'dbGetMakroByDatagram' );
    }
    return;
  }
  if ( $data =~ /.*quit|exit.*/i ) {    # exit request
    $kernel->yield('shutdown');
    return;
  }
  my ( $error, $dgram );
  ( $error, $dgram, $hmConfig ) = $parser->parse( $data, $heap->{'SessionSource'} );    # command line parsing
  if ($error) {
    $heap->{client}->put($error);
  }
  else {

    # handle Homematic Config stuff
    #if ($hmConfig) {
    #  print "HM CONFIG DGRAM\n";
    #  if ( ref( $hmConfig{ $hmConfigDgram->{source} } ) eq 'ARRAY' ) {                          # we have an config-array for source, so append new commands
    #    print "IS AN ARRAY\n";
    #    push @{ $hmConfig{ $hmConfigDgram->{source} } }, $hmParser->buildHmConfigDatagrams($hmConfigDgram);
    #  }
    #  else {
    #    @{ $hmConfig{ $hmConfigDgram->{source} } } = ( $hmParser->buildHmConfigDatagrams($hmConfigDgram) );
    #  }
    #}

    # handle Homematic
    if ($hmConfig) {
      # do nothing, global $hmConfig gets checked in HMLanIn when received a config-request command
      print "Got HMConfig-Cmd from parser. Stored in hmConfig-Var for later processing\n";
      $heap->{client}->put("[ACK] Received Homematic-Config Command. Press Config-Button on Homematic-Device now!");
    }
    elsif ( $homematicDevices{ ( $dgram->{destination} << 8 ) ^ $dgram->{device} } ) {
      my $hmDeviceData = $homematicDevices{ ( $dgram->{destination} << 8 ) ^ $dgram->{device} };
      my ( $error, $hmDgram ) = $hmParser->parse( $dgram, $hmDeviceData );
      if ($error) {
        $heap->{client}->put($error);
      }
      else {
        $heap->{predictions} = $mroutine->getPrediction( $dgram, $heap->{MCastGroup} );
        my @mParts = split( ',', $hmDgram );
        my $mId = substr( $mParts[0], 1, 8 );
        $homematicMIdToHap{$mId} = $heap->{'SessionSource'};
        $kernel->post( main => hmLanOut => $hmDgram );
        $kernel->delay_add( 'ClientOutput', $mroutine->getTimeout($dgram), "[ERR] No Answer." );
        $kernel->delay_add( 'clearMIdfromHash', 2, $mId );
      }
    }

    # handle HAP
    else {
      $heap->{predictions} = $mroutine->getPrediction( $dgram, $heap->{MCastGroup} );
      if ( $dgram->{mtype} != 60 ) {    # raw-data
        $kernel->delay_add( 'ClientOutput', $mroutine->getTimeout($dgram), "[ERR] No Answer." );
      }

      # Message for server
      if ( $dgram->{destination} == $c->{CCUAddress} ) {
        $kernel->post( main => serverCuIn => $dgram );
      }
      else {
        $kernel->post( main => serverCuOut => $dgram );
      }
    }
  }
}

sub tcpClientOutput {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( ref($data) ) {    # looks like an datagram-object
    my $compareResult = $mroutine->compare( $heap->{predictions}, $data, $heap->{MCastGroup} );
    if ( $compareResult == 1 ) {    # we're fine
      $kernel->delay('ClientOutput');    # clear delay
      $heap->{client}->put( $parser->reverseParse($data) );

      #$heap->{client}->put( &composeAnswer("[ACK]", $data) );
    }
    elsif ( $compareResult == 3 ) {
      $kernel->delay('ClientOutput');    # clear delay
                                         #$heap->{client}->put( &composeAnswer( "[ACK]", $data ) );
      $data->{source} = $heap->{MCastAddress} || $data->{source};

      $heap->{client}->put( &composeAnswer( "[ACK]", $data ) );

      #$heap->{client}->put( $parser->reverseParse($data) );
    }
    elsif ( $compareResult == 4 ) {
      $kernel->delay('ClientOutput');    # clear delay
      $data->{source} = $heap->{MCastAddress} || $data->{source};
      $heap->{client}->put( &composeAnswer( "[ERR]", $data ) );
    }
    elsif ( $compareResult == 0 ) {
      $kernel->delay('ClientOutput');    # clear delay
      $heap->{client}->put( &composeAnswer( "[ERR Prediction]", $data ) );
    }
  }
  else {
    if ( $heap->{client} ) {             # if client closes to fast, this one gets undefined
      $heap->{client}->put($data);
    }
    else {
      $mapping{ $heap->{SessionSource} } = undef;
      $kernel->yield('shutdown');
    }
  }
}

################################################################################
# TCP-Client (Communication with ServerCU)
################################################################################

sub tcpServerReconnect {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
  print "Connection to $c->{ServerCUConnection}->{Host}:$c->{ServerCUConnection}->{Port} lost. Trying reconnect...\n";
  $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', 'Detected ServerCU-Connection lost.' );
  $kernel->delay( reconnect => 2 );
}

################################################################################
# TCP-Client (Communication with Homematic HMLan-Interface)
################################################################################

sub hmLanTcpServerReconnect {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
  print "Connection to HMLAN $c->{Homematic}->{HmLanIp}:$c->{Homematic}->{HmLanPort} lost. Trying reconnect...\n";
  $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', 'Detected HMLAN-Connection lost.' );
  $kernel->delay( reconnect => 2 );
}

################################################################################
# Makro
################################################################################

#straight from database
sub executeMakroScript {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  foreach ( @{ $data->{result} } ) {
    print "Executing Makro-Script: $_->{ID}.$_->{Name}\n";
    $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', "Executing Makro-Script: $_->{ID}.$_->{Name}" );
    my $wheel = POE::Wheel::Run->new(
      Program     => $c->{MacroPath} . "/" . $_->{ID} . "." . $_->{Name},
      StdinEvent  => '',
      StdoutEvent => '',
      StderrEvent => '',
      ErrorEvent  => '',
      CloseEvent  => '',
    );
  }
}

sub executeMakroScriptByDatagram {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  my @parameters = (
    $data->{hapMsg}->{vlan},  $data->{hapMsg}->{source}, $data->{hapMsg}->{destination}, $data->{hapMsg}->{device},
    $data->{hapMsg}->{mtype}, $data->{hapMsg}->{v0},     $data->{hapMsg}->{v1},          $data->{hapMsg}->{v2}
  );
  print "Executing Makro-Script: $data->{makro} with Params: " . join( " ", @parameters ) . "\n";
  $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', "Executing Makro-Script: $data->{makro} with Params: " . join( " ", @parameters ) );
  my $wheel = POE::Wheel::Run->new(
    Program     => $c->{MacroPath} . "/" . $data->{makro},
    ProgramArgs => \@parameters,
    StdinEvent  => '',
    StdoutEvent => '',
    StderrEvent => '',
    ErrorEvent  => '',
    CloseEvent  => '',
  );
}

################################################################################
# Fill Homematic Hash
################################################################################

sub fillHomematicHash {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  %homematicDevices       = ();
  %homematicDevicesByHmId = ();
  foreach ( @{ $data->{result} } ) {
    $homematicDevices{ ( $_->{Module} << 8 ) ^ $_->{Address} } = {
      homematicAddress    => $_->{HomematicAddress},
      homematicDeviceType => $_->{HomematicDeviceType},
      notify              => $_->{Notify},
      channel             => $_->{Channel}
    };
    if ( defined( $homematicDevicesByHmId{ $_->{HomematicAddress} } ) ) {    # oops, device already present, must be an device with multiple channels
      $homematicDevicesByHmId{ $_->{HomematicAddress} }->{channels}->{ $_->{Channel} } = { address => $_->{Address}, notify => $_->{Notify} };
    }
    else {
      $homematicDevicesByHmId{ $_->{HomematicAddress} } = {
        homematicAddress    => $_->{HomematicAddress},
        homematicDeviceType => $_->{HomematicDeviceType},
        module              => $_->{Module},
        channels            => { $_->{Channel} => { address => $_->{Address}, notify => $_->{Notify} } }
      };
    }
  }
}

################################################################################
# Makro By Datagram
################################################################################

sub fillMakroByDatagramHash {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  %makroByDatagram = ();
  foreach ( @{ $data->{result} } ) {
    my $hapMsgPart = {
      vlan        => $_->{VLAN},
      source      => $_->{Source},
      destination => $_->{Destination},
      mtype       => $_->{MType},
      device      => $_->{Device},
      v0          => $_->{v0},
      v1          => $_->{v1},
      v2          => $_->{v2},
    };
    my $mUid = buildHashFromMessagePart($hapMsgPart);
    $makroByDatagram{$mUid} = {
      makro => $_->{ID} . "." . $_->{Name},
      msg   => $hapMsgPart
    };
  }
}

sub checkValues {
  my ( $dbMsg, $hapMsg ) = @_;
  my $ex1 = compareValues( $hapMsg->{v0}, $dbMsg->{v0} );
  my $ex2 = compareValues( $hapMsg->{v1}, $dbMsg->{v1} );
  my $ex3 = compareValues( $hapMsg->{v2}, $dbMsg->{v2} );

  if ( $ex1 == 1 && $ex2 == 1 && $ex3 == 1 ) {
    return 1;
  }
  else {
    return 0;
  }
}

sub compareValues {
  my ( $hapValue, $dbStr ) = @_;
  print "COMPARE: $hapValue to $dbStr\n";
  $dbStr =~ /([<>=]{0,2})(\d{1,3})/;
  my $op      = $1;
  my $dbValue = $2;
  my $execute = 0;
  if ( !defined($op) && !defined($dbValue) ) {
    $execute = 1;
  }
  elsif ( ( !defined($op) || $op eq "" ) && defined($dbValue) ) {
    $execute = 1 if ( $hapValue == $dbValue );
  }
  elsif ( $op eq ">" ) {
    $execute = 1 if ( $hapValue > $dbValue );
  }
  elsif ( $op eq "<" ) {
    $execute = 1 if ( $hapValue < $dbValue );
  }
  elsif ( $op eq "=" ) {
    $execute = 1 if ( $hapValue == $dbValue );
  }
  elsif ( $op eq ">=" ) {
    $execute = 1 if ( $hapValue >= $dbValue );
  }
  elsif ( $op eq "<=" ) {
    $execute = 1 if ( $hapValue <= $dbValue );
  }
  return $execute;
}

################################################################################
# MulticastAlert
################################################################################

sub multicastAlert {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  my $val = $data->{v1} * 256 + $data->{v0};
  my @parameters = ( $data->{destination}, $data->{source}, $data->{device}, $val );
  print "Execute Script for MulicastAlert-Address: $data->{destination}\n";
  $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', "Execute Script for MulicastAlert-Address: $data->{destination}\n" );
  my $wheel = POE::Wheel::Run->new(
    Program     => "$c->{ScriptsPath}/MulticastAlert.pl",
    ProgramArgs => \@parameters,
    StdinEvent  => '',
    StdoutEvent => '',
    StderrEvent => '',
    ErrorEvent  => '',
    CloseEvent  => '',
  );
}

################################################################################
# Clear Mapping between Homematic-Message-Id an Hap-Session-Source if no data
# received
################################################################################

sub clearMIdfromHash {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  delete( $homematicMIdToHap{$data} );
}

################################################################################
# Keepalive for Homematic HMLAN
################################################################################

sub keepalive {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  $kernel->post( 'hmLanClient' => ServerOutput => "K" );
  $kernel->delay( 'keepalive' => 29 );
}

################################################################################
# Helper
################################################################################

sub composeAnswer {
  my ( $status, $data ) = @_;
  return $status . " vlan:$data->{vlan}, source:$data->{source}, destination:$data->{destination}, mtype:$data->{mtype}, device:$data->{device}, v0:$data->{v0}, v1:$data->{v1}, v2:$data->{v2}";
}

sub secSince2000 {

  # Calculate the local time in seconds from 2000.
  my $t = time();
  my @l = localtime($t);
  my @g = gmtime($t);
  $t += 60 * ( ( $l[2] - $g[2] + ( ( ( $l[5] << 9 ) | $l[7] ) <=> ( ( $g[5] << 9 ) | $g[7] ) ) * 24 + $l[8] ) * 60 + $l[1] - $g[1] )

    # timezone and daylight saving...
    - 946684800    # seconds between 01.01.2000, 00:00 and THE EPOCH (1970)
    - 7200;        # HM Special
  return $t;
}

sub buildHashFromMessagePart {
  my ($data) = @_;
  my $hashStr =
    sprintf( "%03d", $data->{vlan} ) . sprintf( "%03d", $data->{source} ) . sprintf( "%03d", $data->{destination} ) . sprintf( "%03d", $data->{mtype} ) . sprintf( "%03d", $data->{device} );
  return $hashStr;
}


