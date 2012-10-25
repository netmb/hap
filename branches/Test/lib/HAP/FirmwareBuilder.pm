=head1 NAME

HAP::FirmwareBuilder - The Home Automation Project Firmware-Builder

=head1 DESCRIPTION

Generates Firmware-Commands from the Database-Backend  

=cut

package HAP::FirmwareBuilder;
use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../lib";
use File::Copy;
use File::Path;
use Archive::Zip;

my @queue;
my @batch;
my @cmd;
my $pageSize = 64;

sub new {
  my ( $class, $c ) = @_;
  my $self = { c => $c };
  return bless $self, $class;
}

sub buildQueue {
  my ( $self, $modules ) = @_;
  $self->{'mCast'}   = 254;
  $self->{'config'}  = $self->{c}->{'DefaultConfig'};
  $self->{'modules'} = $modules;
  @queue             =
    $self->db("SELECT ID, Address, FirmwareOptions, FirmwareID, MCastGroups FROM module WHERE Config=$self->{config} AND ID IN($modules) ORDER BY FirmwareOptions ASC, FirmwareID ASC");

  # Get Batch-Count for %-Calculation
  my @c = $self->db("SELECT FirmwareOptions, FirmwareID FROM module WHERE Config=$self->{config} AND ID IN($modules) GROUP BY FirmwareOptions, FirmwareID");
  return scalar(@c);
}

sub nextBatch {
  my ($self) = @_;
  my $i = 0;
  @batch = ();
  my @modules = ();
  foreach (@queue) {
    if ( $i == 0 ) {
      push @batch, {%$_};
      push @modules, $_->{ID};
    }
    else {
      if ( ( $_->{FirmwareOptions} == $queue[ $i - 1 ]->{FirmwareOptions} ) && ( $_->{FirmwareID} == $queue[ $i - 1 ]->{FirmwareID} ) ) {
        push @batch, {%$_};
        push @modules, $_->{ID};
      }
      else {
        last;
      }
    }
    $i++;
  }
  splice( @queue, 0, $i );
  if ( scalar(@modules) > 0 ) {
    return \@modules;
  }
  else {
    return 0;
  }
}

sub prepareTransfer {
  my ($self) = @_;
  @cmd = ();
  my $i = 0;
  my $mStr;
  foreach (@batch) {
    $self->add( "destination $_->{Address} multicast-group " . ( 2**( $self->{'mCast'} - 240 ) ) );
    if ( $i == 0 ) {
      $mStr = $_->{'Address'};
    }
    else {
      $mStr .= "," . $_->{'Address'};
    }
    $i++;
  }
  $self->add("{\"MCastGroup\": [$mStr]}");
  $self->add("{\"MCastAddress\": $self->{mCast}}");
  my $fileSize = -s "$self->{c}->{FirmwareOutputPath}/$batch[0]->{FirmwareID}/ha.hex";
  my $cmdCount = int( $fileSize / $pageSize );
  if ( $fileSize % $pageSize ) {    # if modulo value > 0 : wee need another page
    $cmdCount++;
  }
  $cmdCount = $cmdCount * 2 + $cmdCount * 16 + 5;    # Pageaddress & checksum + 16 Page Packets + 5 Control-Packets (Start/Stop..)
  $self->add("destination $self->{mCast} firmware-size $fileSize");
  $self->add("destination $self->{mCast} protocol start firmware-download");
  $self->{offset} = 0;
  open( $self->{FW}, "<$self->{c}->{FirmwareOutputPath}/$batch[0]->{FirmwareID}/ha.hex" );
  return \@cmd, $cmdCount;
}

sub getFirmwarePage {
  my ($self) = @_;
  seek $self->{FW}, $self->{offset}, 0;
  read( $self->{FW}, my $str, $pageSize );
  if ($str) {
    my $len = length($str);
    if ( $len < $pageSize && $len > 0 ) {
      $str .= chr(255) x ( $pageSize - $len );    #padding
    }

    # Page-Packet
    my @p = ();
    $p[0] = {
      device => 16,
      v0     => 160,
      v1     => $self->{offset} & 0xFF,
      v2     => $self->{offset} >> 8
    };
    $p[17] = { %{ $p[0] } };

    # Data Packages
    my $z = 1;
    for ( my $i = 0 ; $i < $pageSize ; $i = $i + 4 ) {
      $p[$z] = {
        device => ord( substr( $str, $i,     1 ) ),
        v0     => ord( substr( $str, $i + 1, 1 ) ),
        v1     => ord( substr( $str, $i + 2, 1 ) ),
        v2     => ord( substr( $str, $i + 3, 1 ) )
      };
      $p[17]->{device} += $p[$z]->{device};
      $p[17]->{v0}     += $p[$z]->{v0};
      $p[17]->{v1}     += $p[$z]->{v1};
      $p[17]->{v2}     += $p[$z]->{v2};
      $z++;
    }

    # Checksum Package
    $p[17]->{device} = 256 - ( $p[17]->{device} % 256 );
    $p[17]->{device} = 0 if ( $p[17]->{device} == 256 );
    $p[17]->{v0} = 256 - ( $p[17]->{v0} % 256 );
    $p[17]->{v0} = 0 if ( $p[17]->{v0} == 256 );
    $p[17]->{v1} = 256 - ( $p[17]->{v1} % 256 );
    $p[17]->{v1} = 0 if ( $p[17]->{v1} == 256 );
    $p[17]->{v2} = 256 - ( $p[17]->{v2} % 256 );
    $p[17]->{v2} = 0 if ( $p[17]->{v2} == 256 );

    @cmd = ();
    my $i = 0;
    foreach (@p) {
      if ( $i == 0 ) {    #Page-Address
        $self->add("destination $self->{mCast} protocol start-page-address $self->{offset} eeprom-address e32");
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
  $self->add("destination $self->{mCast} start-mode full-default-config");
  $self->add("destination $self->{mCast} save-config");

  foreach (@batch) {
    $self->add("destination $_->{Address} multicast-group $_->{MCastGroups}");
    $self->add("destination $_->{Address} system-full-reset");
  }
  $self->add("{\"MCastAddress\": 0}");
  return \@cmd;
}

sub previousPage {
  my ($self) = @_;
  $self->{offset} -= $pageSize;
}

sub buildFirmwareForBatch {
  my ($self) = @_;
  my $fwId   = $batch[0]->{'FirmwareID'};
  my @fw     = $self->db("SELECT Filename, Content FROM firmware WHERE ID=$fwId");

  rmtree( "$self->{c}->{FirmwareOutputPath}/$fwId", 0, 0 );
  mkdir("$self->{c}->{FirmwareOutputPath}/$fwId/");
  open( TMPFILE, ">$self->{c}->{FirmwareOutputPath}/$fwId/$fw[0]->{Filename}" );
  print TMPFILE $fw[0]->{Content};
  close TMPFILE;
  my $zip = Archive::Zip->new("$self->{c}->{FirmwareOutputPath}/$fwId/$fw[0]->{Filename}");
  $zip->extractTree( 'ha25', "$self->{c}->{FirmwareOutputPath}/$fwId" );
  $fw[0]->{Filename} =~ s/ . zip //;
  opendir( my $fwDir, "$self->{c}->{FirmwareOutputPath}/$fwId" );
  my @preCompiled = grep { /.*\.hex/ } readdir($fwDir);
  closedir $fwDir;

  if ( !$preCompiled[0] ) {
    &modifySourceFiles( $self, "$self->{c}->{FirmwareOutputPath}/$fwId/mv.h", "$self->{c}->{FirmwareOutputPath}/$fwId/Makefile", $batch[0]->{'FirmwareOptions'} );
    my $rc = system("cd $self->{c}->{FirmwareOutputPath}/$fwId \; make clean >/dev/null; make  >/dev/null");
    if ( $rc == 0 && -e "$self->{c}->{FirmwareOutputPath}/$fwId/ha.hex") {
      return 1, "$self->{c}->{FirmwareOutputPath}/$fwId/ha.hex";
    }
  }
  else {
    return 1, "$self->{c}->{FirmwareOutputPath}/$fwId/$preCompiled[0]";
  }
  return 0;
}

sub getBatch {
  my ($self) = @_;
  return \@batch;
}

sub modifySourceFiles {
  my ( $self, $mvFile, $makeFile, $fwOpt ) = @_;

  # Compile Options
  open( IN,  "<$mvFile" );
  open( OUT, ">$mvFile.tmp" );
  my $passedOptions = 0;    # if all defines passed: Stop grepping, so that the rest of the source code stays untouched.
  while ( my $str = <IN> ) {
    $passedOptions = 1 if ( $str =~ /.*CompilerOptionen berechnen.*/ );
    if ( $passedOptions == 0 ) {
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAES[\s|\t]/ && ( $fwOpt & 1 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAER[\s|\t]/ && ( $fwOpt & 2 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHABZ[\s|\t]/ && ( $fwOpt & 4 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAFM[\s|\t]/ && ( $fwOpt & 8 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHACB[\s|\t]/ && ( $fwOpt & 16 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAIR[\s|\t]/ && ( $fwOpt & 32 ) == 0 );

      $str = "//" . $str . "\n"
        if ( $str =~ m/^\#define COHALCD[\s|\t]/ && ( $fwOpt & 64 ) == 0 && ( $fwOpt & 128 ) == 0 );    # No LCD
      $str = "\#define COHALCD 1\n"
        if ( $str =~ m/^\#define COHALCD[\s|\t]/ && ( $fwOpt & 64 ) == 1 && ( $fwOpt & 128 ) == 0 );    # LCD 1 Row
      $str = "\#define COHALCD 2\n"
        if ( $str =~ m/^\#define COHALCD[\s|\t]/ && ( $fwOpt & 64 ) == 0 && ( $fwOpt & 128 ) == 1 );    # LCD 2 Row
      $str = "\#define COHALCD 3\n"
        if ( $str =~ m/^\#define COHALCD[\s|\t]/ && ( $fwOpt & 64 ) == 1 && ( $fwOpt & 128 ) == 1 );    # LCD 3 Row

      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHALI[\s|\t]/       && ( $fwOpt & 256 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAAI[\s|\t]/       && ( $fwOpt & 512 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHADIDS1820[\s|\t]/ && ( $fwOpt & 1024 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHASW[\s|\t]/       && ( $fwOpt & 2048 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHADM[\s|\t]/       && ( $fwOpt & 4096 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHARS[\s|\t]/       && ( $fwOpt & 8192 ) == 0 );

      $str = "//" . $str . "\n"
        if ( $str =~ m/^\#define COHADG[\s|\t]/ && ( $fwOpt & 16384 ) == 0 && ( $fwOpt & 32768 ) == 0 );    # No Encoder
      $str = "\#define COHADG 1\n"
        if ( $str =~ m/^\#define COHADG[\s|\t]/ && ( $fwOpt & 16384 ) == 1 && ( $fwOpt & 32768 ) == 0 );    # PEC Encoder
      $str = "\#define COHADG 2\n"
        if ( $str =~ m/^\#define COHADG[\s|\t]/ && ( $fwOpt & 16384 ) == 1 && ( $fwOpt & 32768 ) == 1 );    # STEC Encoder

      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAGUI[\s|\t]/ && ( $fwOpt & 65536 ) == 0 );
      $str = "//" . $str . "\n" if ( $str =~ m/^\#define COHAAS[\s|\t]/  && ( $fwOpt & 131072 ) == 0 );
    }
    print OUT $str;
  }
  close IN;
  close OUT;
  rename $mvFile, $mvFile . ".org";
  rename $mvFile . ".tmp", $mvFile;

  # Makefile
  open( IN,  "<$makeFile" );
  open( OUT, ">$makeFile.tmp" );
  while ( my $str = <IN> ) {
    $str = "DIRAVR = $self->{c}->{AVRPath}\n" if ( $str =~ m/^DIRAVR\s=.*/ );
    $str = "FORMAT = binary\n" if ( $str =~ m/^FORMAT.*/ );
    print OUT $str;
  }
  close IN;
  close OUT;
  rename $makeFile, $makeFile . ".org";
  rename $makeFile . ".tmp", $makeFile;
  return 1;
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

sub checkPreCompiled {
  my ( $self, $zipFile ) = @_;
  my $zip           = Archive::Zip->new($zipFile);
  my @hexFile       = $zip->membersMatching('.*\.hex');
  my @compileOption = $zip->membersMatching('.*\.option');
  if ( defined( $hexFile[0] ) && defined( $compileOption[0] ) ) {
    $compileOption[0]->fileName() =~ /.*\/(\d+)\.option.*/;
    return $1;
  }
  else {
    return undef;
  }
}    

1;
