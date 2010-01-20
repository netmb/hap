package HAP::ASSimulator;
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

sub evalEdgeFlags {
	my ( $pv0, $pv1 ) = @_;
	my $tmp = 0;
	if ( $pv0 > 0 ) {
		$tmp |= 1;
	}
	if ( $pv1 > 0 ) {
		$tmp |= 2;
	}
	return $tmp;

}

sub calc {
	my ( $self, $type, $simValue, $x, $v0, $v1, $v2 ) = @_;
	if ( $type == 0 ) {
		$simValue = 0;
	}
	elsif ( $type == 32 ) {
		if ( $x > 0 ) {
			$simValue = 0xFF;
		}
		else {
			$simValue = 0x00;
		}
	}
	elsif ( $type == 33 ) {
		if ( $x > 0 ) {
			$simValue = 0xFF;
		}
		else {
			$simValue = 0x00;
		}
	}
	elsif ( $type == 34 ) {
		if ( $x > 0 ) {
			$simValue = 0xFF;
		}
		else {
			$simValue = 0x00;
		}
	}
	elsif ( $type == 35 ) {
		if ( $x > 0 ) {
			$simValue = 0xFF;
		}
		else {
			$simValue = 0x00;
		}
	}
	elsif ( $type == 56 ) {
	}
	elsif ( $type == 60 ) {
	}
	elsif ( $type == 61 ) {
	    if ($x == $simValue) {
		$simValue = $v2;
	    }
	    $x = $simValue;
#		if ( $x > 0 ) {
#			$simValue = $v2;
#			$x        = 0;
#		}
#		if ( $simValue != $v2 ) {
#			$x = 1;
#		}
	}
	elsif ( $type == 63 || $type == 127 ) {
		if (   ( $simValue < $v0 && $v2 & 0x80 )
			|| ( $simValue > $v0 && $v2 & 0x40 ) )
		{
			$x = 1;
		}
		else {
			$x = 0;
		}
		$simValue = $v0;
	}
	elsif ( $type == 69 || $type == 133 ) {
		$simValue = $v0 << $v1;
	}
	elsif ( $type == 70 || $type == 134 ) {
		$simValue = $v0 >> $v1;
	}
	elsif ( $type == 72 || $type == 136 ) {
		if ( $v0 == $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 73 || $type == 137 ) {
		if ( $v0 != $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 74 || $type == 138 ) {
		if ( $v0 < $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 75 || $type == 139 ) {
		if ( $v0 <= $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 76 || $type == 140 ) {
		if ( $v0 > $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 77 || $type == 141 ) {
		if ( $v0 >= $v1 ) {
			$simValue = 255;
		}
		else {
			$simValue = 0;
		}
	}
	elsif ( $type == 80 || $type == 144 || $type == 208 ) {
		$simValue = $v0 + $v1 + $v2;
	}
	elsif ( $type == 81 || $type == 145 || $type == 209 ) {
		$simValue = $v0 - $v1 - $v2;
	}
	elsif ( $type == 82 || $type == 146 || $type == 210 ) {
		$simValue = $v0 * $v1 * $v2;
	}
	elsif ( $type == 83 || $type == 147 || $type == 211 ) {
		$simValue = $v0 / $v1 / $v2;
	}
	elsif ( $type == 128 || $type == 192 ) {
		$simValue = $v0 & $v1 & $v2;
	}
	elsif ( $type == 129 || $type == 193 ) {
		$simValue = $v0 | $v1 | $v2;
	}
	elsif ( $type == 130 || $type == 194 ) {
		$simValue = ~( $v0 & $v1 & $v2 );
	}
	elsif ( $type == 131 || $type == 195 ) {
		$simValue = ~( $v0 | $v1 | $v2 );
	}
	elsif ( $type == 132 || $type == 196 ) {
		$simValue = $v0 ^ $v1 ^ $v2;
	}
	elsif ( $type == 84 ) {
		$simValue = ( ( $v0 + $v1 ) & 0xFF ) * ( $v2 / 16 );
	}
	elsif ( $type == 85 ) {
		$simValue = $v2 / ( ( $v0 + $v1 ) & 0xFF );
	}
	elsif ( $type == 86 ) {
		$simValue = $v0 / $v1 * $v2;
	}
	elsif ( $type == 96 ) {
		if ( $v0 < $x ) {
			$v0 = ( $x - $v0 ) >> 1;
			if ( $simValue + $v0 > 255 ) {
				$simValue = 255;
			}
			else {
				$simValue += $v0;
			}
		}
		else {
			$v0 = ( $v0 - $x ) >> 1;
			if ( $v0 > $simValue ) {
				$simValue = 0;
			}
			else {
				$simValue -= $v0;
			}
		}
	}
	elsif ( $type == 100 ) {
		if ( $v0 == 132 ) {
			$simValue = 128;
		}
		elsif ( $v0 == 8 ) {
			if ( $simValue == 136 ) {
				$simValue = 135;
			}
			else {
				$simValue = 255;
			}
		}
		elsif ( $v0 == 136 ) {
			$simValue = 136;
		}
	}
	elsif ( $type == 152 || $type == 216 ) {
		if ( $v0 > 0 ) {
			$simValue = $v2;
		}
		if ( $v1 > 0 ) {
			$simValue = 0;
		}
	}
	elsif ( $type == 153 || $type == 217 ) {
		if ( $v1 > 0 ) {
			$simValue = 0;
		}
		if ( $v0 > 0 ) {
			$simValue = $v2;
		}
	}
	elsif ( $type == 154 || $type == 218 ) {
		if ( $v0 > 0 && $simValue == 0 ) {
			$simValue = $v2;
		}
		else {
			if ( $v1 > 0 && $simValue > 0 ) {
				$simValue = 0;
			}
		}
	}
	elsif ( $type == 155 || $type == 219 ) {
		if ( $v0 > 0 && ~( $x & 1 ) ) {
			$simValue = $v2;
		}
		if ( $v1 > 0 && ~( $x & 2 ) ) {
			$simValue = 0;
		}
		$x = &evalEdgeFlags( $v0, $v1 );
	}
	elsif ( $type == 156 || $type == 220 ) {
		if ( $v1 > 0 && ~( $x & 2 ) ) {
			$simValue = 0;
		}
		if ( $v0 > 0 && ~( $x & 1 ) ) {
			$simValue = $v2;
		}
		$x = &evalEdgeFlags( $v0, $v1 );
	}
	elsif ( $type == 157 || $type == 221 ) {
		if ( $v0 > 0 && ~( $x & 1 ) && $simValue == 0 ) {
			$simValue = $v2;
		}
		elsif ( $v1 > 0 && ~( $x & 2 ) && $simValue > 0 ) {
			$simValue = 0;
		}
		$x = &evalEdgeFlags( $v0, $v1 );
	}
	elsif ( $type == 164 ) {
		if ( $x != $v0 ) {
			if ( $v0 == 132 ) {
				$simValue = 100;
			}
			elsif ( $v0 == 8 ) {
				if ( $x == 136 ) {
					$simValue = 135;
				}
				else {
					$simValue = 255;
				}
			}
			elsif ( $v0 == 136 ) {
				$simValue = 133;
			}
			$x = $v0;
		}
		if ( $v2 != $v1 ) {
			if ( $v1 == 132 ) {
				$simValue = 0;
			}
			elsif ( $v1 == 8 ) {
				if ( $v2 == 136 ) {
					$simValue = 135;
				}
				else {
					$simValue = 255;
				}
			}
			elsif ( $v1 == 136 ) {
				$simValue = 134;
			}
			$v2 = $v1;
		}
	}
	elsif ( $type == 165 ) {
		if ( $x != $v0 ) {
			if ( $v0 == 8 ) {
				if ( $x == 136 ) {
					$simValue = 135;
				}
				else {
					$simValue = 255;
				}
			}
			elsif ( $v0 == 132 || $v0 == 136 ) {
				$simValue = 133;
			}
			$x = $v0;
		}
		if ( $v2 != $v1 ) {
			if ( $v1 == 8 ) {
				if ( $v2 == 136 ) {
					$simValue = 135;
				}
				else {
					$simValue = 255;
				}
			}
			elsif ( $v0 == 132 || $v0 == 136 ) {
				$simValue = 134;
			}
			$v2 = $v1;
		}
	}
	elsif ( $type == 104 || $type == 168 || $type == 232 ) {
		if ( $v0 < $v1 ) {
			if ( $v0 < $v2 ) {
				$simValue = $v0;
			}
			else {
				$simValue = $v2;
			}
		}
		else {
			if ( $v1 < $v2 ) {
				$simValue = $v1;
			}
			else {
				$simValue = $v2;
			}
		}
	}
	elsif ( $type == 105 || $type == 169 || $type == 233 ) {
		if ( $v0 > $v1 ) {
			my $tmp = $v1;
			$v1 = $v0;
			$v0 = $tmp;
		}
		if ( $v1 > $v2 ) {
			my $tmp = $v2;
			$v2 = $v1;
			$v1 = $tmp;
		}
		if ( $v0 > $v1 ) {
			my $tmp = $v1;
			$v1 = $v0;
			$v0 = $tmp;
		}
		$simValue = $v1;
	}
	elsif ( $type == 106 || $type == 170 || $type == 234 ) {
		if ( $v0 > $v1 ) {
			if ( $v0 > $v2 ) {
				$simValue = $v0;
			}
			else {
				$simValue = $v2;
			}
		}
		else {
			if ( $v1 > $v2 ) {
				$simValue = $v1;
			}
			else {
				$simValue = $v2;
			}
		}
	}
	elsif ( $type == 107 || $type == 171 || $type == 235 ) {
		if ( $v0 == 0 ) {
			$simValue = $v1;
		}
		else {
			$simValue = $v2;
		}
	}
	elsif ( $type == 112 ) {
		if ( $v0 > 0 ) {
			$x        = 1;
			$simValue = $v0;
		}
		else {
			if ( $x == 0 ) {
				$simValue = 0;
			}
		}
	}
	elsif ( $type == 113 ) {
		if ( $v0 == 0 ) {
			$x        = 1;
			$simValue = 0;
		}
		else {
			if ( $x == 0 ) {
				$simValue = $v0;
			}
		}
	}
	elsif ( $type == 114 ) {
		if ( $v0 > 0 && $x > 0 ) {
			$simValue = $v0;
		}
		else {
			$simValue = 0;
		}
		if ( $v0 == 0 ) {
			$x = 1;
		}
	}
	elsif ( $type == 115 ) {
		if ( $x == 0 ) {
			$x        = 1;
			$simValue = $v0;
		}
	}
	elsif ( $type == 120 ) {
	  if ( $simValue == $v0 / 2.55 ) {
	    $x = 0;
	  }
	  else {
	    if ( $x != 128 ) {
	      $x = 1;
	    }
	    else {
	      $x = 0;
	    }
	  }
		$simValue = $v0 / 2.55;
	}
	elsif ( $type == 121 ) {
	  if ( $simValue == $v0 ) {
	    $x = 0;
	  }
	  else {
	    if ( $x != 128 && $v0 < 255) {
	      $x = 1;
	    }
	    else {
	      $x = 0;
	    }
	  }
		$simValue = $v0;
	}
	elsif ( $type == 122 ) {
	  if ( $simValue == $v0 ) {
	    $x = 0;
	  }
	  else {
	    $x = 1;
	  }
		$simValue = $v0;
	}
	return $simValue & 0xFF, $x;
}

1;
