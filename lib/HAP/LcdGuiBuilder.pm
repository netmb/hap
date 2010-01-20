=head1 NAME

HAP::LcdGuiBuilder - The Home Automation Project LCD-GUI-Builder

=head1 DESCRIPTION

Generates LCD-GUI-Commands from the Database-Backend  

=cut

package HAP::LcdGuiBuilder;
use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";

my @queue;
my @batch;
my @cmd;
my $pageSize = 32;
my %mAddress;

sub new {
  my ( $class, $c ) = @_;
  my $self = { c => $c };
  return bless $self, $class;
}

sub buildLcdGui {
  my ( $self, $module ) = @_;
  $self->{'mCast'}   = 254;
  $self->{'config'}  = $self->{c}->{DefaultConfig};
  $self->{'modules'} = $module;
  @batch             = $self->db("SELECT ID from abstractdevice WHERE Config=$self->{config} AND Module=$module AND SubType=240 AND Attrib0=1");

  my @m = $self->db("SELECT ID, Address FROM module WHERE Config=$self->{config}");
  foreach (@m) {
    $mAddress{ $_->{ID} } = $_->{Address};
  }
  $mAddress{0} = 0;

  my @objs = $self->db("SELECT Offset, String from lcd_objects WHERE AbstractDevID=$batch[0]->{ID} ORDER BY Offset ASC");
  foreach (@objs) {
    $self->{string} .= $_->{String};
  }
}

sub prepareTransfer {
  my ($self) = @_;
  @cmd = ();
  my $i = 0;
  my $mStr;
  $self->add( "destination $mAddress{$self->{modules}} multicast-group " . ( 2**( $self->{'mCast'} - 240 ) ) );
  $self->add("{\"MCastGroup\": [$mAddress{$self->{modules}}]}");
  $self->add("{\"MCastAddress\": $self->{mCast}}");

  my $fileSize = length( $self->{string} );
  my $cmdCount = int( $fileSize / $pageSize );
  if ( $fileSize % $pageSize ) {    # if modulo value > 0 : wee need another page
    $cmdCount++;
  }
  $cmdCount = $cmdCount * 10 + 10;    # Pageaddress & checksum + 8 Page Packets + 10 Control-Packets (Start/Stop..)
  $self->add("destination $self->{mCast} firmware-size $fileSize");
  $self->add("destination $self->{mCast} protocol start gui-config-download ");
  $self->{offset} = 0;
  return \@cmd, $cmdCount;
}

sub getFirmwarePage {
  my ($self) = @_;
  my $str = undef;
  if ($self->{offset} < length($self->{string})) {
    $str = substr( $self->{string}, $self->{offset}, $pageSize );
  }
  if ($str) {
    my $len = length($str);
    if ( $len < $pageSize && $len > 0 ) {
      $str .= chr(255) x ( $pageSize - $len );    #padding
    }

    # Page-Packet
    my @p = ();
    $p[0] = {
      device => 16,
      v0     => 168,
      v1     => $self->{offset} & 0xFF,
      v2     => $self->{offset} >> 8
    };
    $p[9] = { %{ $p[0] } };

    # Data Packages
    my $z = 1;
    for ( my $i = 0 ; $i < $pageSize ; $i = $i + 4 ) {
      $p[$z] = {
        device => ord( substr( $str, $i,     1 ) ),
        v0     => ord( substr( $str, $i + 1, 1 ) ),
        v1     => ord( substr( $str, $i + 2, 1 ) ),
        v2     => ord( substr( $str, $i + 3, 1 ) )
      };
      $p[9]->{device} += $p[$z]->{device};
      $p[9]->{v0}     += $p[$z]->{v0};
      $p[9]->{v1}     += $p[$z]->{v1};
      $p[9]->{v2}     += $p[$z]->{v2};
      $z++;
    }

    # Checksum Package
    $p[9]->{device} = 256 - ( $p[9]->{device} % 256 );
    $p[9]->{device} = 0 if ( $p[9]->{device} == 256 );
    $p[9]->{v0} = 256 - ( $p[9]->{v0} % 256 );
    $p[9]->{v0} = 0 if ( $p[9]->{v0} == 256 );
    $p[9]->{v1} = 256 - ( $p[9]->{v1} % 256 );
    $p[9]->{v1} = 0 if ( $p[9]->{v1} == 256 );
    $p[9]->{v2} = 256 - ( $p[9]->{v2} % 256 );
    $p[9]->{v2} = 0 if ( $p[9]->{v2} == 256 );

    @cmd = ();
    my $i = 0;
    foreach (@p) {
      if ( $i == 0 ) {    #Page-Address
        $self->add("destination $self->{mCast} protocol start-page-address $self->{offset} eeprom-address e8");
      }
      else {
        $self->add("destination $self->{mCast} data $_->{device} $_->{v0} $_->{v1} $_->{v2}")    #Data
      }
      $i++;
    }
    $self->{offset} += $pageSize;
    return \@cmd;
  }
  else {
    return 0;
  }
}

sub finishTransfer {
  my ($self) = @_;
  @cmd = ();
  $self->add("destination $self->{mCast} protocol end");
  $self->add("destination $self->{mCast} save-config");

  foreach (@batch) {
    my @mCast = $self->db("SELECT MCastGroups from module WHERE Config=$self->{config} AND ID=$self->{modules}");
    $self->add("destination $mAddress{$self->{modules}} multicast-group $mCast[0]->{MCastGroups}");
  }
  $self->add("{\"MCastAddress\": 0}");
  $self->add("destination $mAddress{$self->{modules}} system-full-reset");    
  return \@cmd;
}

sub previousPage {
  my ($self) = @_;
  $self->{offset} -= $pageSize;
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

sub add {
  my ( $self, $line ) = @_;
  push @cmd, $line;
}

1;
