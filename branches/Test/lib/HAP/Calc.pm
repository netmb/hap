package HAP::Calc;
use strict;

###############################################################################
## Declaration                                                               ##
###############################################################################


###############################################################################
## Main                                                                      ##
###############################################################################

sub new {
  my ($class) = @_;
  my $self = {};
  return bless $self, $class;
}

sub getFormula {
  my ( $self, $value, $formula ) = @_;
  if (defined($formula) && $formula =~ /.*[x|X]+.*/) {
    $formula =~ s/x|X/$value/g;
    return $formula;
  }
  return $value;
}

sub getSplineValue {
  my ( $self, $valueHigh, $valueLow, $correction, $mPair ) = @_;
  $mPair =~ s/\s//g;
  my @measurePair = split ";", $mPair;
  my @val         = ();
  my @adc         = ();
  foreach (@measurePair) {
    if ( $_ =~ /([0-9]+|[0-9]+\.[0-9]+),([0-9]+|[0-9]+\.[0-9]+)/ ) {    # int and float
      push @val, $2;
      push @adc, $1;
    }
  }
  if ( scalar(@val) != scalar(@adc) || scalar(@val) == 0 || scalar(@adc) == 0 ) {
    return $valueHigh * 256 + $valueLow;
  }
  else {
    my $i = 0;
    foreach (@val) {
      $val[$i] = $_ + $correction;
      $i++;
    }
    my $Spline = new Math::Spline( \@val, \@adc );
    my $value = sprintf( "%.1f", $Spline->evaluate( $valueHigh * 256 + $valueLow ) );
    return $value;
  }
}

1;
