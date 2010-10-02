package hapConfig::Controller::AutonomousControl;

use strict;
use warnings;
use base 'Catalyst::Controller';
use HAP::ASSimulator;

=head1 NAME

hapConfig::Controller::AutonomousControl - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

my $acs = new HAP::ASSimulator();

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body(
		'Matched hapConfig::Controller::AutonomousControl in AutonomousControl.'
	);
}

sub getAllObjects : Local {
	my ( $self, $c ) = @_;
	my @asObjs =
	  map {
		{
			id        => $_->id,
			shortName => $_->shortname,
			type      => $_->type + 0,
			inPorts   => $_->inports + 0,
			outPorts  => $_->outports + 0,
			display   => JSON::XS->new->utf8(0)->decode( $_->display )
		}
	  } $c->model('hapModel::AcTypes')
	  ->search( {}, { order_by => 'ShortName ASC' } )->all;
	$c->stash->{success} = 'true';
	$c->stash->{data}    = \@asObjs;
	$c->forward('View::JSON');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	if ( $id != 0 ) {
		my $rc = $c->model('hapModel::AcSequence')->search( id => $id )->first;
		$c->stash->{success} = 'true';
		$c->stash->{data}    = {
			id => $rc->id,

			#name   => decode ("utf8", $rc->name),
			name   => $rc->name,
			room   => $rc->room,
			module => $rc->module,
			config => $c->session->{config}
		};
		my @objects;
		my @rc =
		  $c->model('hapModel::AcObjects')->search( sequence => $id )->all;
		foreach (@rc) {
			push @objects, JSON::XS->new->utf8(0)->decode( $_->configobject );
		}
		$c->stash->{data}->{objects} = \@objects;
	}
	if ( $id == 0 ) {
		$c->stash->{data} = {};    # required for extjs
		if ( $c->request->params->{module} ne 'undefined' ) {
			$c->stash->{data} = { module => $c->request->params->{module} };
		}
		elsif ( $c->request->params->{room} ne 'undefined' ) {
			$c->stash->{data} = { room => $c->request->params->{room} };
		}
		$c->stash->{success} = 'true';
	}
	$c->forward('View::JSON');

}

sub delete : Local {
	my ( $self, $c, $id ) = @_;
	my $rc = $c->model('hapModel::AcSequence')->search( id => $id )->delete_all;
	$rc =
	  $c->model('hapModel::AcObjects')->search( sequence => $id )->delete_all;
	if ( $rc == 1 ) {
		$c->stash->{success} = \1;
		$c->stash->{info}    = "Deleted: DB-ID : $id";
	}
	else {
		$c->stash->{success} = \0;
		$c->stash->{info}    = "Failed!: DB-ID : $id";
	}
	$c->forward('View::JSON');
}

sub submit : Local {
	my ( $self, $c, $id ) = @_;
	my $data = {

		#name   => encode("utf8", $c->request->params->{name}),
		name   => $c->request->params->{name},
		room   => $c->request->params->{room},
		module => $c->request->params->{module},
		config => $c->session->{config}
	};
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::AcSequence')->create($data);
		$id = $rs->id;
	}
	else {
		$rs = $c->model('hapModel::AcSequence')->search( id => $id )->first;
		$rs->update($data);
	}

	$rs =
	  $c->model('hapModel::AcObjects')->search( sequence => $id )->delete_all;

	my $jsonData =
	  JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
	foreach (@$jsonData) {
		my $dbData;
		my $acObj = $_;

		# reset sim-values
		$acObj->{calcVar}  = 0;
		$acObj->{simValue} = 0;
		if ( $acObj->{type} == 60 || $acObj->{type} == 61 ) {
			$acObj->{simValue} = $acObj->{display}->{'Init-Value'};
		}
		if ( $acObj->{type} == 96 ) {
			$acObj->{calcVar} = $acObj->{display}->{'Reference'};
		}

		# end reset sim-values
		$dbData->{sequence}     = $id;
		$dbData->{module}       = $c->request->params->{module};
		$dbData->{type}         = $acObj->{type};
		$dbData->{configobject} = JSON::XS->new->utf8(0)->encode($acObj);
		$dbData->{config}       = $c->session->{config};
		$dbData->{x}            = $acObj->{x};
		$rs = $c->model('hapModel::AcObjects')->create($dbData);

	}

	my %objs = &renumber(
		$self, $c,
		$c->request->params->{module},
		$c->session->{config}
	);
	if ( !%objs ) {
		$c->stash->{success} = \0;
		$data->{id}          = $id;
		$c->stash->{data}    = \0;
		$c->forward('View::JSON');
	}
	else {
		foreach my $key ( keys %objs ) {
			$c->log->debug( $objs{$key}->{x} );
			$objs{$key}->{prop1} = 0;
			$objs{$key}->{prop2} = 0;
			$objs{$key}->{prop3} = 0;
			my $confObj =
			  JSON::XS->new->utf8(0)->decode( $objs{$key}->configobject );
			my $display = $confObj->{display};
			if ( $confObj->{type} == 32 ) {
				my @tmp = split( /\./, $display->{'Start Value (s)'} );
				$objs{$key}->{prop1} = $tmp[0];
				$objs{$key}->{prop1} |=
				  ( $display->{'Interval (1/10s)'} & 0x300 ) >> 2;
				$objs{$key}->{prop2} = $tmp[1];
				$objs{$key}->{prop3} = $display->{'Interval (1/10s)'} & 0xFF;
			}
			elsif ( $confObj->{type} == 33 ) {
				my @tmp = split( /:/, $display->{'Start Value (mm:ss)'} );
				$objs{$key}->{prop1} = $tmp[0];
				$objs{$key}->{prop2} = $tmp[1];
				$objs{$key}->{prop1} |=
				  ( $display->{'Interval (s)'} & 0xC00 ) >> 4;
				$objs{$key}->{prop2} |=
				  ( $display->{'Interval (s)'} & 0x300 ) >> 2;
				$objs{$key}->{prop3} = $display->{'Interval (s)'} & 0xFF;
			}
			elsif ( $confObj->{type} == 34 ) {
				my @tmp = split( /:/, $display->{'Start Value (hh:mm)'} );
				$objs{$key}->{prop1} = $tmp[0];
				$objs{$key}->{prop2} = $tmp[1];
				$objs{$key}->{prop2} |=
				  ( $display->{'Interval (m)'} & 0x300 ) >> 2;
				$objs{$key}->{prop3} = $display->{'Interval (m)'} & 0xFF;
				$objs{$key}->{prop1} |= $display->{'Mo.-Fr.'} << 5;
				$objs{$key}->{prop1} |= $display->{'Saturday'} << 6;
				$objs{$key}->{prop1} |= $display->{'Sunday'} << 7;
			}
			elsif ( $confObj->{type} == 35 ) {
				my @tmp = split( /:/, $display->{'Start Value (hh:mm)'} );
				$objs{$key}->{prop1} = $display->{'Start Value (d)'} << 5;
				$objs{$key}->{prop1} |= $tmp[0];
				$objs{$key}->{prop2} = $tmp[1];
				$objs{$key}->{prop2} |=
				  ( $display->{'Intervall (m)'} & 0x300 ) >> 2;
				$objs{$key}->{prop3} = $display->{'Intervall (m)'} & 0xFF;
			}
			elsif ( $confObj->{type} == 56 ) {
				$objs{$key}->{prop1} = $display->{'HAP-Module'};
				$objs{$key}->{prop2} = $display->{'HAP-Device'};
				$objs{$key}->{prop3} = $display->{'Interval (1/10s)'};
			}
			elsif ( $confObj->{type} == 60 || $confObj->{type} == 61 ) {
				$objs{$key}->{prop1} = $display->{'HAP-Module'};
				$objs{$key}->{prop2} = $display->{'HAP-Device'};
				$objs{$key}->{prop3} = $display->{'Init-Value'};
			}
			elsif ( $confObj->{type} == 63 ) {
				$objs{$key}->{prop1} = $display->{'Output-Value'};
				$objs{$key}->{prop2} = $display->{'Delay (1/10s)'} & 0xFF;
				$objs{$key}->{prop3} = $display->{'Delay (1/10s)'} >> 8;
				$objs{$key}->{prop3} |= $display->{'Edge Rising'} << 7;
				$objs{$key}->{prop3} |= $display->{'Edge Falling'} << 6;
			}
			elsif ( $confObj->{type} == 69 || $confObj->{type} == 70 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Shift (Bits)'};
			}
			elsif ( $confObj->{type} >= 72 && $confObj->{type} <= 77 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Value'};
			}
			elsif ( $confObj->{type} >= 80 && $confObj->{type} <= 83 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Value0'};
				$objs{$key}->{prop3} = $display->{'Value1'};
			}
			elsif ( $confObj->{type} == 84 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Offset'};
				$objs{$key}->{prop3} = $display->{'Multiplicator'};
			}
			elsif ( $confObj->{type} == 85 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Offset'};
				$objs{$key}->{prop3} = $display->{'Divisor'};
			}
			elsif ( $confObj->{type} == 86 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Divisor'};
				$objs{$key}->{prop3} = $display->{'Multiplicator'};
			}
			elsif ( $confObj->{type} == 96 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Reference'};
			}
			elsif ( $confObj->{type} == 100 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
			}
			elsif ( $confObj->{type} >= 104 && $confObj->{type} <= 107 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Value0'};
				$objs{$key}->{prop3} = $display->{'Value1'};
			}
			elsif ( $confObj->{type} >= 112 && $confObj->{type} <= 115 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Time-Base'};
				$objs{$key}->{prop3} = $display->{'Value'};
			}
			elsif ( $confObj->{type} == 120 || $confObj->{type} == 121 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'HAP-Module'};
				$objs{$key}->{prop3} = $display->{'HAP-Device'};
			}
			elsif ( $confObj->{type} == 122 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop3} = $display->{'HAP-Device'};
			}
			elsif ( $confObj->{type} == 127 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $display->{'Delay (1/10s)'} & 0xFF;
				$objs{$key}->{prop3} = $display->{'Delay (1/10s)'} >> 8;
				$objs{$key}->{prop3} |= $display->{'Edge Rising'} << 7;
				$objs{$key}->{prop3} |= $display->{'Edge Falling'} << 6;
			}
			elsif ( $confObj->{type} >= 128 && $confObj->{type} <= 132 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
				$objs{$key}->{prop3} = $display->{'Value'};
			}
			elsif ( $confObj->{type} == 133 || $confObj->{type} == 134 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
				$objs{$key}->{prop3} = $display->{'Value'};
			}
			elsif ( $confObj->{type} >= 136 && $confObj->{type} <= 141 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
			}
			elsif ( $confObj->{type} >= 144 && $confObj->{type} <= 157 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
				$objs{$key}->{prop3} = $display->{'Value'};
			}
			elsif ( $confObj->{type} == 164 || $confObj->{type} == 165 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
			}
			elsif ( $confObj->{type} >= 168 && $confObj->{type} <= 171 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
				$objs{$key}->{prop3} = $display->{'Value'};
			}
			elsif ( $confObj->{type} >= 192 && $confObj->{type} <= 235 ) {
				$objs{$key}->{prop1} = $objs{ $confObj->{inPort1} }->{nr};
				$objs{$key}->{prop2} = $objs{ $confObj->{inPort2} }->{nr};
				$objs{$key}->{prop3} = $objs{ $confObj->{inPort3} }->{nr};
			}
		}
		foreach my $key ( keys %objs ) {
			my $rs =
			  $c->model('hapModel::AcObjects')->search( id => $objs{$key}->id )
			  ->first;
			$rs->update(
				{
					object => $objs{$key}->{nr},
					prop1  => $objs{$key}->{prop1},
					prop2  => $objs{$key}->{prop2},
					prop3  => $objs{$key}->{prop3}
				}
			);
		}
		$c->stash->{success} = 'true';
		$data->{id}          = $id;
		$c->stash->{data}    = $data;
		$c->forward('View::JSON');
	}
}

sub simulate : Local {
	my ( $self, $c, $id ) = @_;
	my %objs = &renumberSequence( $self, $c, $c->request->params->{data} );
	my $currSelection = $c->request->params->{currSelection};
	my @response;
	if ( !%objs ) {
		$c->stash->{success} = \0;
		$c->stash->{data}    = \0;
		$c->forward('View::JSON');
	}
	else {
		##foreach my $key ( sort { $objs{$a}->{nr} cmp $objs{$b}->{nr} } keys %objs ) {    # order by object number
		foreach
		  my $key ( sort { $objs{$a}->{x} <=> $objs{$b}->{x} } keys %objs )
		{
			#$c->log->debug("$objs{$key}->{x} $objs{$key}->{uid}");
			my ( $v0, $v1, $v2 ) = 0;
			my $confObj  = $objs{$key};
			my $display  = $confObj->{'display'};
			my $simValue = $confObj->{'simValue'};
			my $calcVar  = $confObj->{'calcVar'};
			my $simText  = "";
			#$c->log->debug("simval: $simValue -- calcVar: $calcVar");

			if ( $confObj->{type} == 0 ) {

			}
			elsif ( $confObj->{type} == 32 ) {
				my @tmp = split( /\./, $display->{'Start Value (s)'} );
				$v0 = $tmp[0];
				$v0 |= ( $display->{'Interval (1/10s)'} & 0x300 ) >> 2;
				$v1 = $tmp[1];
				$v2 = $display->{'Interval (1/10s)'} & 0xFF;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 33 ) {
				my @tmp = split( /:/, $display->{'Start Value (mm:ss)'} );
				$v0 = $tmp[0];
				$v1 = $tmp[1];
				$v0 |= ( $display->{'Interval (s)'} & 0xC00 ) >> 4;
				$v1 |= ( $display->{'Interval (s)'} & 0x300 ) >> 2;
				$v2 = $display->{'Interval (s)'} & 0xFF;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 34 ) {
				my @tmp = split( /:/, $display->{'Start Value (hh:mm)'} );
				$v0 = $tmp[0];
				$v1 = $tmp[1];
				$v1 |= ( $display->{'Interval (m)'} & 0x300 ) >> 2;
				$v2 = $display->{'Interval (m)'} & 0xFF;
				$v0 |= $display->{'Mo.-Fr.'} << 5;
				$v0 |= $display->{'Saturday'} << 6;
				$v0 |= $display->{'Sunday'} << 7;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 35 ) {
				my @tmp = split( /:/, $display->{'Start Value (hh:mm)'} );
				$v0 = $display->{'Start Value (d)'} << 5;
				$v0 |= $tmp[0];
				$v1 = $tmp[1];
				$v1 |= ( $display->{'Intervall (m)'} & 0x300 ) >> 2;
				$v2 = $display->{'Intervall (m)'} & 0xFF;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 56 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 60 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$display->{'Init-Value'} );
			}
			elsif ( $confObj->{type} == 61 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$display->{'Init-Value'} );
			}
			elsif ( $confObj->{type} == 63 ) {
				$v0 = $display->{'Output-Value'};
				$v1 = $display->{'Delay (1/10s)'} & 0xFF;
				$v2 = $display->{'Delay (1/10s)'} >> 8;
				$v2 |= $display->{'Edge Rising'} << 7;
				$v2 |= $display->{'Edge Falling'} << 6;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} == 69 || $confObj->{type} == 70 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type}, $simValue, $calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Shift (Bits)'}, $v2
				);
			}
			elsif ( $confObj->{type} >= 72 && $confObj->{type} <= 77 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Value'}, $v2 );
			}
			elsif ( $confObj->{type} >= 80 && $confObj->{type} <= 86 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Value0'},
					$display->{'Value1'}
				);
			}
			elsif ( $confObj->{type} == 96 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type}, $simValue, $calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Reference'}, $v2
				);
			}
			elsif ( $confObj->{type} == 100 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$v1, $v2 );
			}
			elsif ( $confObj->{type} >= 104 && $confObj->{type} <= 107 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Value0'},
					$display->{'Value1'}
				);
			}
			elsif ( $confObj->{type} >= 112 && $confObj->{type} <= 115 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$display->{'Time-Base'},
					$display->{'Value'}
				);
			}
			elsif ( $confObj->{type} == 120 || $confObj->{type} == 121 ) {
				if (   $objs{ $confObj->{inPort1} }->{'type'} == 63
					|| $objs{ $confObj->{inPort1} }->{'type'} == 127 )
				{
					( $simValue, $calcVar ) =
					  $acs->calc( $confObj->{type}, $simValue, $objs{ $confObj->{inPort1} }->{'calcVar'} | 128,
						$objs{ $confObj->{inPort1} }->{'simValue'},
						$v1, $v2 );
					$c->log->debug("SIM: $simValue, CALC: $calcVar");
				}
				else {
					( $simValue, $calcVar ) =
					  $acs->calc( $confObj->{type}, $simValue, $calcVar,
						$objs{ $confObj->{inPort1} }->{'simValue'},
						$v1, $v2 );
				}
			}
			elsif ( $confObj->{type} == 122 ) {
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$v1, $v2 );
			}
			elsif ( $confObj->{type} == 127 ) {
				$v0 = $objs{ $confObj->{inPort1} }->{'simValue'};
				$v1 = $display->{'Delay (1/10s)'} & 0xFF;
				$v2 = $display->{'Delay (1/10s)'} >> 8;
				$v2 |= $display->{'Edge Rising'} << 7;
				$v2 |= $display->{'Edge Falling'} << 6;
				( $simValue, $calcVar ) =
				  $acs->calc( $confObj->{type}, $simValue, $calcVar, $v0, $v1,
					$v2 );
			}
			elsif ( $confObj->{type} >= 128 && $confObj->{type} <= 132 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$display->{'Value'}
				);
			}
			elsif ( $confObj->{type} == 133 || $confObj->{type} == 134 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$display->{'Value'}
				);
			}
			elsif ( $confObj->{type} >= 136 && $confObj->{type} <= 141 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$v2
				);
			}
			elsif ( $confObj->{type} >= 144 && $confObj->{type} <= 157 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$display->{'Value'}
				);
			}
			elsif ( $confObj->{type} == 164 || $confObj->{type} == 165 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$v2
				);
			}
			elsif ( $confObj->{type} >= 168 && $confObj->{type} <= 171 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$display->{'Value'}
				);
			}
			elsif ( $confObj->{type} >= 192 && $confObj->{type} <= 235 ) {
				( $simValue, $calcVar ) = $acs->calc(
					$confObj->{type},
					$simValue,
					$calcVar,
					$objs{ $confObj->{inPort1} }->{'simValue'},
					$objs{ $confObj->{inPort2} }->{'simValue'},
					$objs{ $confObj->{inPort3} }->{'simValue'}
				);
			}
			$confObj->{'simValue'} = $simValue;
			$confObj->{'calcVar'}  = $calcVar;
			# add display value
			if ($confObj->{type} == 121 || $confObj->{type} == 122) {
				my $tmp = $c->model('hapModel::StaticOutputvaluetemplates')->search( type => $simValue)->first;
				if (defined($tmp)) {
					$simText = $tmp->name;
				}
			}
			push @response,
			  {
				'uid'      => $confObj->{uid},
				'calcVar'  => $calcVar + 0,
				'simValue' => $simValue + 0,
				'simText'  => $simText
			  };
		}
		$c->stash->{data}    = \@response;
		$c->stash->{success} = \1;
		$c->forward('View::JSON');
	}
}

sub simulatereset : Local {
	my ( $self, $c, $id ) = @_;
	my %objs = &renumberSequence( $self, $c, $c->request->params->{data} );
	my $currSelection = $c->request->params->{currSelection};
	my @response;
	if ( !%objs ) {
		$c->stash->{success} = \0;
		$c->stash->{data}    = \0;
		$c->forward('View::JSON');
	}
	else {
		foreach
		  my $key ( sort { $objs{$a}->{x} <=> $objs{$b}->{x} } keys %objs )
		{
			$c->log->debug("$objs{$key}->{x} $objs{$key}->{uid}");
			my $confObj  = $objs{$key};
			my $display  = $confObj->{'display'};
			my $simValue = 0;
			my $calcVar  = 0;
			if ( $confObj->{type} == 60 || $confObj->{type} == 61 ) {
				$simValue = $display->{'Init-Value'};
				$calcVar  = $display->{'Init-Value'};
			}
			elsif ( $confObj->{type} == 96 ) {
				$calcVar = $display->{'Reference'};
			}
			push @response,
			  {
				'uid'      => $confObj->{uid},
				'calcVar'  => $calcVar + 0,
				'simValue' => $simValue + 0
			  };
		}
		$c->stash->{data}    = \@response;
		$c->stash->{success} = \1;
		$c->forward('View::JSON');
	}
}

#sub renumber : Private {

#  my ( $self, $c, $module, $config ) = @_;
#  my @rs = $c->model('hapModel::AcObjects')->search( module => $module )->all;
#  my $z = scalar(@rs) - 1;
#  my ( %numbered, %unnumbered );
#  foreach (@rs) {
#    my $confObj = JSON::XS->new->utf8(0)->decode( $_->configobject );
#    if ( $confObj->{type} != 256 ) {    # its a comment
#      if ( $confObj->{type} == 120 || $confObj->{type} == 121 ) {
#        $_->{nr} = $z--;
#        $numbered{ $confObj->{uid} } = $_;
#      }
#      else {
#        $unnumbered{ $confObj->{uid} } = $_;
#      }
#    }
#  }
#  my $loopCount = 0;
#  while ( scalar( keys(%unnumbered) ) > 0 ) {
#    $loopCount++;
#    foreach my $key ( keys %numbered ) {
#      my $confObj = JSON::XS->new->utf8(0)->decode( $numbered{$key}->configobject );
#      if ( !defined( $numbered{$key}->{seen} ) ) {
#        for ( my $i = 1 ; $i < 4 ; $i++ ) {
#          if ( defined( $confObj->{"inPort$i"} ) ) {
#            if ( defined( $unnumbered{ $confObj->{"inPort$i"} } ) ) {    # if object already numbered -> its not in here
#              $unnumbered{ $confObj->{"inPort$i"} }->{nr} = $z--;
#              $numbered{ $confObj->{"inPort$i"} } = $unnumbered{ $confObj->{"inPort$i"} };
#              delete $unnumbered{ $confObj->{"inPort$i"} };
#            }
#          }
#        }
#      }
#      $numbered{$key}->{seen} = 1;
#    }
#    if ( $loopCount > 40 ) {
#      $c->log->debug('### ENDLESS LOOP DETECTED ###');
#      return ();
#    }
#  }
#  return %numbered;
#}

sub renumber : Private {
	my ( $self, $c, $module, $config ) = @_;
	my @rs =
	  $c->model('hapModel::AcObjects')
	  ->search( { module => $module }, { order_by => 'Sequence ASC, X ASC' } )
	  ->all;
	my $i = 0;
	my %tmp;
	foreach (@rs) {
		my $confObj = JSON::XS->new->utf8(0)->decode( $_->configobject );
		$_->{nr} = $i;
		$i++;
		$tmp{ $confObj->{uid} } = $_;
	}
	return %tmp;
}

#sub renumberSequence : Private {
#  my ( $self, $c, $data ) = @_;
#  my $jsonData = JSON::XS->new->utf8(0)->decode($data);
#  my $z        = scalar(@$jsonData) - 1;
#  my ( %numbered, %unnumbered );
#  foreach (@$jsonData) {
#    my $confObj = $_;
#    if ( $confObj->{type} != 256 ) {    # its a comment
#      if ( $confObj->{type} == 120 || $confObj->{type} == 121 ) {
#        $_->{nr} = $z--;
#        $numbered{ $confObj->{uid} } = $_;
#      }
#      else {
#        $unnumbered{ $confObj->{uid} } = $_;
#      }
#    }
#  }
#  my $loopCount = 0;
#  while ( scalar( keys(%unnumbered) ) > 0 ) {
#    $loopCount++;
#    foreach my $key ( keys %numbered ) {
#      my $confObj = $numbered{$key};
#      if ( !defined( $numbered{$key}->{seen} ) ) {
#        for ( my $i = 1 ; $i < 4 ; $i++ ) {
#          if ( defined( $confObj->{"inPort$i"} ) ) {
#            if ( defined( $unnumbered{ $confObj->{"inPort$i"} } ) ) {    # if object already numbered -> its not in here
#              $unnumbered{ $confObj->{"inPort$i"} }->{nr} = $z--;
#              $numbered{ $confObj->{"inPort$i"} } = $unnumbered{ $confObj->{"inPort$i"} };
#              delete $unnumbered{ $confObj->{"inPort$i"} };
#            }
#          }
#        }
#      }
#      $numbered{$key}->{seen} = 1;
#    }
#    if ( $loopCount > 40 ) {
#      $c->log->debug('### ENDLESS LOOP DETECTED ###');
#      return ();
#    }
#  }
#  return %numbered;
#}

sub renumberSequence : Private {
	my ( $self, $c, $data ) = @_;
	my $jsonData = JSON::XS->new->utf8(0)->decode($data);
	my %tmp;
	foreach (@$jsonData) {
		$tmp{ $_->{uid} } = $_;
	}
	return %tmp;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
