
=head1 NAME

HAP::MessageRoutines -  The Home Automation Project Message-Routines-Module

=head1 DESCRIPTION

Parses user input and tries to predict the outstanding answer.
Calculats Message-Timeouts and handels Encryption/Decryption

=cut

package HAP::MessageRoutines;
use strict;

sub new {
  my ($class) = shift;
  my $self = {};
  return bless $self, $class;
}

sub getPrediction {
  my ( $self, $dgram, $mCastModules ) = @_;
  my $src = $dgram->{source};
  my $dst = $dgram->{destination};
  my @msgs;
  if ( $dst < 240 ) {
    my $tmp = {%$dgram};    #copy object
    $tmp->{source}      = $dgram->{destination};
    $tmp->{destination} = $dgram->{source};
    $tmp->{mtype}       = $dgram->{mtype} + 1;
    push @msgs, $tmp;
  }
  else {
    if ( !$mCastModules ) {    # no MCast-Group
      my $tmp = {%$dgram};
      $tmp->{source}      = "*";                   # Wildcard-Source
      $tmp->{destination} = $dgram->{source};
      $tmp->{mtype}       = $dgram->{mtype} + 1;
      push @msgs, $tmp;
    }
    else {                                         # prediction for every message possible => 1:1 Mapping
      foreach (@$mCastModules) {
        my $tmp = {%$dgram};                       #copy object
        $tmp->{source}      = $_;
        $tmp->{destination} = $dgram->{source};
        $tmp->{mtype}       = $dgram->{mtype} + 1;
        push @msgs, $tmp;
      }
    }
  }
  return \@msgs;
}

sub compare {
  my ( $self, $predictions, $dgram2, $setMCast ) = @_;
  my $i             = 0;
  my $match         = 0;
  my $matchedSource = 0;
  foreach (@$predictions) {
    my $predicted = $_;

    if ( $predicted->{source} == $dgram2->{source} ) {
      $matchedSource = 1;
    }
    if ( $predicted->{mtype} == 9 || $predicted->{mtype} == 77 ) {    # query and config set
      if ( $predicted->{vlan} == $dgram2->{vlan}
        && ( $predicted->{source} == $dgram2->{source} || $predicted->{source} eq "*" )
        && $predicted->{destination} == $dgram2->{destination}
        && $predicted->{mtype} == $dgram2->{mtype}
        && $predicted->{device} == $dgram2->{device} )
      {
        $match = 1;
        $predicted->{matched} = 1;
        last;
      }
    }
    elsif ( $predicted->{mtype} == 85 ) {                             # ir-learn
      if ( $predicted->{vlan} == $dgram2->{vlan}
        && $predicted->{source} == $dgram2->{source}
        && $predicted->{destination} == $dgram2->{destination}
        && $predicted->{mtype} == $dgram2->{mtype} )
      {
        $match = 1;
        $predicted->{matched} = 1;
        last;
      }
    }
    else {
      if ( $predicted->{vlan} == $dgram2->{vlan}
        && ( $predicted->{source} == $dgram2->{source} || $predicted->{source} eq "*" )
        && $predicted->{destination} == $dgram2->{destination}
        && $predicted->{mtype} == $dgram2->{mtype}
        && $predicted->{device} == $dgram2->{device}
        && $predicted->{v0} == $dgram2->{v0}
        && $predicted->{v1} == $dgram2->{v1}
        && $predicted->{v2} == $dgram2->{v2} )
      {
        $match = 1;
        $predicted->{matched} = 1;
        last;
      }
    }
    $i++;
  }

  if ( !$setMCast && $match ) {
    return 1;
  }
  elsif ($setMCast) {
    if ($match) {
      foreach (@$predictions) {
        if ( !$_->{matched} ) {
          return 2;    #not all packages matched
        }
      }
      return 3;        # got all mcast-packages
    }
    elsif ($matchedSource) {
      return 4;
    }
    else {
      return 5;
    }
  }
  else {
    return 0;
  }
}

sub getTimeout {
  my ( $self, $dgram ) = @_;
  my $timeout = .5;
  if ( $dgram->{mtype} == 84 && $dgram->{device} == 0 ) {    # IR-Learn
    $timeout = 5;
  }
  if ( $dgram->{mtype} == 76 && $dgram->{device} == 8 ) {    # save-config
    $timeout = 8;
  }
  if ( $dgram->{mtype} == 76 && $dgram->{device} == 2 ) {    # system-full-reset - may take some time after firmware-flash
    $timeout = 8;
  }
  if ( $dgram->{mtype} == 100 && $dgram->{v2} == 255 ) {     # AS
    $timeout = 2;
  }
  return $timeout;
}

sub getTime {
  my ( $self, $dgram ) = @_;
  my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = localtime(time);
  if ( $wday == 0 ) {
    $wday = 6;
  }
  else {
    $wday = $wday - 1;
  }
  my $data = {
    vlan        => $dgram->{vlan},
    source      => $dgram->{destination},
    destination => $dgram->{source},
    mtype       => 120,
    device      => 0,
    v0          => $sec,
    v1          => $min,
    v2          => ( $hour << 3 ) | $wday
  };
  return $data;
}

sub crypt {
  my ( $self, $dgram, $cryptKey, $cryptOption ) = @_;
  if ( $cryptOption == 0 ) {
    return $dgram;
  }
  if ( ( $cryptOption & 1 ) == 1 ) {
    $dgram->{source}      = $dgram->{source} ^ $cryptKey->{1};
    $dgram->{destination} = $dgram->{destination} ^ $cryptKey->{2};
    $dgram->{mtype}       = $dgram->{mtype} ^ $cryptKey->{3};
    $dgram->{device}      = $dgram->{device} ^ $cryptKey->{4};
    $dgram->{v0}          = $dgram->{v0} ^ $cryptKey->{5};
    $dgram->{v1}          = $dgram->{v1} ^ $cryptKey->{6};
    $dgram->{v2}          = $dgram->{v2} ^ $cryptKey->{7};
  }
  if ( ( $cryptOption & 2 ) == 2 ) {
    $dgram->{vlan} = $dgram->{vlan} ^ $cryptKey->{0};
  }
  return $dgram;
}

sub decrypt {
  my ( $self, $dgram, $cryptKey, $cryptOption ) = @_;
  &crypt( $self, $dgram, $cryptKey, $cryptOption );
}

1;
