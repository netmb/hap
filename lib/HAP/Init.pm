
=head1 NAME

HAP::Init - The Home Automation Project Initilalize-Module

=head1 DESCRIPTION

Builds an config-hash which is required for all HAP-Perl-Scripts

=cut

package HAP::Init;
use strict;
use YAML;
use DBI;

my %init;

sub new {
  my ( $class, %initHash ) = @_;
  my $self = {};
  %init = %initHash;
  if ( defined( $init{FILE} ) && -e $init{FILE} ) {    
    
  }
  elsif ( defined( $ENV{HAPCONFIG_CONFIG} ) && -e $ENV{HAPCONFIG_CONFIG} ) {
    $init{FILE} = $ENV{HAPCONFIG_CONFIG};
  }
  elsif ( -e '/opt/hap/etc/hap.yml' ) {
    $init{FILE} = '/opt/hap/etc/hap.yml';
  }
  bless $self, $class;
  $self = $self->getConfig();
  return bless $self, $class;

#    if ( defined( $init{FILE} ) && -e $init{FILE} ) {
#     return bless ($self), $class, &getConfig( $self, %init );
#    }
#    elsif ( defined( $ENV{HAPCONFIG_CONFIG} ) && -e $ENV{HAPCONFIG_CONFIG} ) {
#      $init{FILE} = $ENV{HAPCONFIG_CONFIG};
#      return bless($self), $class, &getConfig( $self, %init );
#    }
#    elsif ( -e '/opt/hap/etc/hap.yml' ) {
#      $init{FILE} = '/opt/hap/etc/hap.yml';
#      return bless($self), $class, &getConfig( $self, %init );
#    }
#    return bless $self, $class;
}

sub getConfig {
  my ( $self ) = @_;
  
  # Load Defaults
  my $c = YAML::LoadFile( $init{FILE} );
  
  # Connect to DB if Database-Definition found in YAML
  if ( defined( $c->{'Model::hapModel'} ) ) {
    my @drivers = DBI->available_drivers();
    die "No Driver...\n" unless @drivers;
    my $dsn = $c->{'Model::hapModel'}->{'connect_info'};
    $self->{dbh} = DBI->connect(@$dsn) || print "No connection to SQL-Server possible ..  Error Code: DBI::errstr\n";
    $self->{dbh}->{mysql_auto_reconnect} = 1;
  }

  # Overwite Default-Config : Rule is: YAML=>DB=>Supplied via Constructor
  my @res = $self->db("SELECT ID, Name FROM config WHERE IsDefault=1");
  if ( $res[0]->{ID} ) {
    $c->{DefaultConfig}     = $res[0]->{ID};
    $c->{DefaultConfigName} = $res[0]->{Name};
  }
  if ( $init{CONFIG_NAME} ) {
    my @tmp = $self->db("SELECT ID, Name FROM config WHERE Name=$init{CONFIG_NAME}");
    $c->{DefaultConfig}      = $tmp[0]->{ID}   || 0;
    $c->{DefaultConfigNsame} = $tmp[0]->{Name} || "UNDEFINED";
  }
  if ( $init{CONFIG_ID} ) {
    $c->{DefaultConfig} = $init{CONFIG_ID};
    my @tmp = $self->db("SELECT ID, Name FROM config WHERE ID=$init{CONFIG_ID}");
    $c->{DefaultConfig}     = $tmp[0]->{ID}   || 0;
    $c->{DefaultConfigName} = $tmp[0]->{Name} || "UNDEFINED";
  }
  @res = $self->db("SELECT ID, Address FROM module WHERE Config=$c->{DefaultConfig}");
  foreach (@res) {
    $c->{'mAddress'}->{ $_->{'ID'} } = $_->{'Address'};
    $c->{'mID'}->{ $_->{'Address'} } = $_->{'ID'};
  }
  @res                 = $self->db("SELECT * FROM module WHERE Config=$c->{DefaultConfig} AND IsCCUModule=1");
  $c->{ServerCU}       = $res[0]->{Address};
  $c->{DefaultVLAN}    = $res[0]->{VLAN};
  $c->{DefaultCANVLAN} = $res[0]->{CANVLAN};
  $c->{CryptOption}    = $res[0]->{CryptOption};
  $c->{CryptKey}       = {
    0 => $res[0]->{CryptKey0} + 0,
    1 => $res[0]->{CryptKey1} + 0,
    2 => $res[0]->{CryptKey2} + 0,
    3 => $res[0]->{CryptKey3} + 0,
    4 => $res[0]->{CryptKey4} + 0,
    5 => $res[0]->{CryptKey5} + 0,
    6 => $res[0]->{CryptKey6} + 0,
    7 => $res[0]->{CryptKey7} + 0,
  };
  @res = $self->db("SELECT Address FROM module WHERE Config=$c->{DefaultConfig} AND IsCCU=1");
  $c->{CCUAddress} = $res[0]->{Address};

  if ( $init{SKIP_DB} ) {
    $self->{dbh}->disconnect();
  }
  else {
    $c->{dbh} = $self->{dbh};
  }
  return $c;
}

sub getModuleAddress {
  my ( $self, $id ) = @_;
  my @res = $self->db("SELECT Address FROM module WHERE ID=$id");
  return $res[0]->{Address};
}

sub getModuleId {
  my ( $self, $config, $address ) = @_;
  my @res = $self->db("SELECT ID FROM module WHERE Address=$address AND Config=$config");
  return $res[0]->{Address};
}

sub db {
  my ( $self, $sql ) = @_;
  my $sth = $self->{dbh}->prepare($sql);
  $sth->execute;
  my @rows;
  while ( my $ref = $sth->fetchrow_hashref() ) {
    push @rows, $ref;
  }
  return @rows;
}

1;
