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
use HAP::MessageRoutines;
use JSON::XS;
use Device::SerialPort;
use POE::Component::Client::TCP;
use Symbol qw(gensym);

my $json = new JSON::XS;
$json = $json->allow_unknown(1);
my $mroutine = new HAP::MessageRoutines();

my $c = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml", SKIP_DB => 1 );
my $parser = new HAP::Parser($c);

my %mapping;
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
      $_[KERNEL]
        ->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info', 'Startup complete.' );
    },
    serialSetup             => \&serialSetup,
    serverCuIn              => \&serverCuIn,
    serverCuOut             => \&serverCuOut,
    serialCheck             => \&serialCheck,
    dbAddLogEntry           => \&dbAddLogEntry,
    dbGetModuleId           => \&dbGetModuleId,
    dbGetDeviceData         => \&dbGetDeviceData,
    dbUpdateStatus          => \&dbUpdateStatus,
    dbGetMakro              => \&dbGetMakro,
    dbGetFirmwareId         => \&dbGetFirmwareId,
    dbGetFirmwareOptions    => \&dbGetFirmwareOptions,
    dbUpdateFirmwareVersion => \&dbUpdateFirmwareVersion,
    dbUpdateFirmwareOptions => \&dbUpdateFirmwareOptions,
    executeMakroScript      => \&executeMakroScript
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
      print
"Success. Connected to $c->{ServerCUConnection}->{Host}:$c->{ServerCUConnection}->{Port}\n";
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
    $port =
      tie( *$handle, "Device::SerialPort",
      $c->{ServerCUConnection}->{Ports}[$i] );
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

sub serverCuIn {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( !$c->{Crypto} ) {
    $data =
      $mroutine->decrypt( $data, $c->{CryptKey}, $c->{CryptOption} )
      ;    #$kernel->delay('serverCuOut'); # clear retransmit
  }
  print &composeAnswer( "Serial in:", $data ) . "\n";
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
  elsif ( $data->{mtype} == 77 && $data->{device} == 28 ) {   # Firmware-Version
    $kernel->post( 'main' => dbGetFirmwareId => $data );
  }
  elsif ( $data->{mtype} == 77 && $data->{device} == 30 ) {   # Firmware-Version
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
    $kernel->post(
      $mapping{ $data->{source} }->{session} => ClientOutput => $sData );
  }
  else {
    $kernel->post(
      $mapping{ $data->{destination} }->{session} => ClientOutput => $data );
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
    $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info',
      'Detected Serial-Connection lost.' );
    $kernel->yield('serialSetup');
  }
  $kernel->delay_add( 'serialCheck', 60 );
}

################################################################################
# Database
################################################################################

sub dbGetModuleId {
  my ( $kernel, $heap, $session, $data ) =
    @_[ KERNEL, HEAP, SESSION, ARG0, ARG1 ];
  $kernel->post(
    'database',
    'single' => {
      sql =>
"SELECT ID from module WHERE Config=$c->{DefaultConfig} AND Address=$data->{source}",
      hapData => $data,
      event   => 'dbGetDeviceData',
    },
  );

}

sub dbGetDeviceData {
  my ( $kernel, $heap, $session, $data ) =
    @_[ KERNEL, HEAP, SESSION, ARG0, ARG1 ];
  if ( $data->{result} ) {
    my $module = $data->{result};
    my $device = $data->{hapData}->{device};
    if (
      $data->{hapData}->{mtype} == 76
      && ( $data->{hapData}->{device} == 128
        || $data->{hapData}->{device} == 130 )
      ) {
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
SELECT abstractdevice.Name, NULL, 192 AS \"Type\" FROM abstractdevice WHERE abstractdevice.Config=$c->{DefaultConfig} AND abstractdevice.Module=$module AND abstractdevice.Address=$device"
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
      $data->{hapData}->{mtype} == 76
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
          sql =>
'INSERT INTO status (TS, Type, Module, Address, Status, Config) VALUES (?,?,?,?,?,?)',
          placeholders => [
            time(),              $_->{'Type'},
            $data->{dbModuleId}, $data->{hapData}->{v0},
            $status,             $c->{DefaultConfig}
          ],
          event => '',
        }
      );

    }
    my $status = $data->{hapData}->{v1} * 256 + $data->{hapData}->{v0};
    if ( $_->{'Formula'} ) {
      my $formula = $_->{'Formula'};
      $formula =~ s/x|X/$status/g;
      $status = eval($formula);
    }
    $kernel->post(
      'database',
      insert => {
        sql =>
'INSERT INTO status (TS, Type, Module, Address, Status, Config) VALUES (?,?,?,?,?,?)',
        placeholders => [
          time(),              $_->{'Type'},
          $data->{dbModuleId}, $data->{hapData}->{device},
          $status,             $c->{DefaultConfig}
        ],
        event => '',
      }
    );
    $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info',
      "$_->{Name} Status $status" );

  }
}

sub dbGetFirmwareId {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql =>
"SELECT ID FROM firmware WHERE VMajor = $data->{v0} AND VMinor = $data->{v1} AND VPhase = $data->{v2}",
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
        sql =>
'UPDATE module SET FirmwareVersion = ?, CurrentFirmwareID = ? WHERE Address = ? AND Config = ?',
        placeholders => [
"$data->{datagram}->{v0}.$data->{datagram}->{v1}.$data->{datagram}->{v1}",
          $_->{ID}, $data->{datagram}->{source},
          $c->{DefaultConfig}
        ],
        event => '',
      }
    );
  }
}

sub dbGetFirmwareOptions {
  my ( $kernel, $heap, $session, $data ) = @_[ KERNEL, HEAP, SESSION, ARG0 ];
  $kernel->post(
    'database',
    'arrayhash' => {
      sql =>
"SELECT CurrentFirmwareOptions FROM module WHERE Address = $data->{source}  AND Config = $c->{DefaultConfig}",
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
        sql =>
'UPDATE module SET CurrentFirmwareOptions = ? WHERE Address = ? AND Config = ?',
        placeholders => [
          $_->{CurrentFirmwareOptions} |
            ( $data->{datagram}->{v1} << ( 8 * $data->{datagram}->{v0} ) ),
          $data->{datagram}->{source},
          $c->{DefaultConfig}
        ],
        event => '',
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
      sql =>
"SELECT Name, ID FROM makro WHERE MakroNr = $makroNr AND Config = $c->{DefaultConfig}",
      event => 'executeMakroScript',
    },
  );
}

sub dbAddLogEntry {
  my ( $kernel, $heap, $session, $pid, $source, $type, $message ) =
    @_[ KERNEL, HEAP, SESSION, ARG0, ARG1, ARG2, ARG3 ];
  my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
  my $time = sprintf(
    "%4d-%02d-%02d %02d:%02d:%02d ",
    $year + 1900,
    $mon + 1, $mday, $hour, $min, $sec
  );
  $kernel->post(
    'database',
    insert => {
      sql =>
        'INSERT INTO log (Time, PID, Source, Type, Message) VALUES (?,?,?,?,?)',
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
        $heap->{client}
          ->put("[ACK] Set Multicast Addresses to $cObj->{MCastAddress}");
      }
    }
    return;
  }

  if ( $data =~ /.*quit|exit.*/i ) {    # exit request
    $kernel->yield('shutdown');
    return;
  }

  my ( $error, $dgram ) =
    $parser->parse( $data, $heap->{'SessionSource'} );    # command line parsing
  if ($error) {
    $heap->{client}->put($error);
  }
  else {
    $heap->{predictions} =
      $mroutine->getPrediction( $dgram, $heap->{MCastGroup} );
    if ( $dgram->{mtype} != 60 ) {                        # raw-data
      $kernel->delay_add(
        'ClientOutput',
        $mroutine->getTimeout($dgram),
        "[ERR] No Answer."
      );
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

sub tcpClientOutput {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  if ( ref($data) ) {    # looks like an datagram-object
    my $compareResult =
      $mroutine->compare( $heap->{predictions}, $data, $heap->{MCastGroup} );
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
    if ( $heap->{client} ) { # if client closes to fast, this one gets undefined
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
  print
"Connection to $c->{ServerCUConnection}->{Host}:$c->{ServerCUConnection}->{Port} lost. Trying reconnect...\n";
  $kernel->yield( 'dbAddLogEntry', $$, 'hap-mp', 'Info',
    'Detected ServerCU-Connection lost.' );
  $kernel->delay( reconnect => 2 );
}

################################################################################
# Makro
################################################################################

sub executeMakroScript {
  my ( $kernel, $heap, $data ) = @_[ KERNEL, HEAP, ARG0 ];
  foreach ( @{ $data->{result} } ) {
    print "Executing Makro-Script: $_->{ID}.$_->{Name}\n";
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

################################################################################
# Helper
################################################################################

sub composeAnswer {
  my ( $status, $data ) = @_;
  return $status
    . " vlan:$data->{vlan}, source:$data->{source}, destination:$data->{destination}, mtype:$data->{mtype}, device:$data->{device}, v0:$data->{v0}, v1:$data->{v1}, v2:$data->{v2}";
}

