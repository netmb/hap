=head1 NAME

HAP::POE::Filter::Datagram -  The Home Automation Project POE-Wheel-Filter

=head1 DESCRIPTION

POE-Wheel-Filter for HAP-Datagrams

=cut

package HAP::POE::Filter::Datagram;

use strict;
use warnings;
use vars qw($VERSION);
use base qw(POE::Filter);
use Carp qw(croak);

sub FRAMING_BUFFER () { 0 }
sub BLOCK_SIZE ()     { 1 }
sub EXPECTED_SIZE ()  { 2 }

$VERSION = '1.00';

sub new {
  my $type = shift;
  croak "$type must be given an even number of parameters" if @_ & 1;
  my %params = @_;

  my $block_size = 8;

  my $self = bless [
    '',             # FRAMING_BUFFER
    $block_size,    # BLOCK_SIZE
    undef,          # EXPECTED_SIZE
  ], $type;

  $self;
}

sub get_one_start {
  my ( $self, $stream ) = @_;
  $self->[FRAMING_BUFFER] .= join '', @$stream;
}

sub get_one {
  my $self = shift;

  BEGIN {
    eval { require bytes } and bytes->import;
  }
  return [] unless length( $self->[FRAMING_BUFFER] ) >= $self->[BLOCK_SIZE];
  my $block = substr( $self->[FRAMING_BUFFER], 0, $self->[BLOCK_SIZE] );
  substr( $self->[FRAMING_BUFFER], 0, $self->[BLOCK_SIZE] ) = '';
  my $tmp = {
    vlan        => ord( substr( $block, 0, 1 ) ),
    source      => ord( substr( $block, 1, 1 ) ),
    destination => ord( substr( $block, 2, 1 ) ),
    mtype       => ord( substr( $block, 3, 1 ) ),
    device      => ord( substr( $block, 4, 1 ) ),
    v0          => ord( substr( $block, 5, 1 ) ),
    v1          => ord( substr( $block, 6, 1 ) ),
    v2          => ord( substr( $block, 7, 1 ) ),
  };
  return [$tmp];
}

sub put {
  my ( $self, $block) = @_;
  my @raw;
  my @b = @$block;
  my $dgram = $b[0];
  my $tmp =
      chr( $dgram->{vlan} )
    . chr( $dgram->{source} )
    . chr( $dgram->{destination} )
    . chr( $dgram->{mtype} )
    . chr( $dgram->{device} )
    . chr( $dgram->{v0} )
    . chr( $dgram->{v1} )
    . chr( $dgram->{v2} );
  push @raw, $tmp;
  return \@raw;
}

sub get_pending {
  my $self = shift;
  return undef unless length $self->[FRAMING_BUFFER];
  [ $self->[FRAMING_BUFFER] ];
}

1;
