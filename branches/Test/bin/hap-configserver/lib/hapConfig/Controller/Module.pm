package hapConfig::Controller::Module;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Module - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::Module in Module.');
}

sub get : Local {
	my ( $self, $c, $id ) = @_;
	my ( $rc, $name, $address, $bridgemode, $isCCU, $isCCUModule, $receiveBuffer, $dimmerCycleLength, $dimmerTicLength, $room, $ccuAddress );
	if ( $id == 0 ) {
		$c->stash->{data} = {};    # required for extjs
		$rc                = $c->model('hapModel::Module')->search( config => $c->session->{config} )->first;    # template
		$isCCU             = 0;
		$isCCUModule       = 0;
		$receiveBuffer     = 4;
		$dimmerCycleLength = 60;
		$dimmerTicLength   = 60;
		my $rb = $c->model('hapModel::Module')->search( config => $c->session->{config}, isccu => 1 )->first;

		if ( defined($rb) ) {
			$ccuAddress = $rb->address;
		}
		if ( $c->request->params->{room} ne 'undefined' ) {
			$room = $c->request->params->{room};
		}
	}
	else {
		$rc                = $c->model('hapModel::Module')->search( id => $id )->first;
		$name              = $rc->name;
		$address           = $rc->address;
		$bridgemode        = $rc->bridgemode;
		$isCCU             = $rc->isccu;
		$isCCUModule       = $rc->isccumodule;
		$receiveBuffer     = $rc->receivebuffer;
		$dimmerCycleLength = $rc->dimmercyclelength;
		$dimmerTicLength   = $rc->dimmerticlength;
		$room              = $rc->room;
	}
	if ( defined($rc) ) {
		my $currFwName = "undefined";
		if ( defined( $rc->currentfirmwareid ) ) {
			my $tmp = $c->model('hapModel::Firmware')->search( id => $rc->currentfirmwareid )->first;
			$currFwName = $tmp->name if ( defined($tmp) );
		}

		my $preCompiled = 0;
		my $tmp = $c->model('hapModel::Firmware')->search( id => $rc->firmwareid )->first;
		$preCompiled = $tmp->precompiled if ( defined($tmp) );

		$c->stash->{data} = {
			id                => $id,
			uid               => $rc->uid,
			name              => $name,
			room              => $room,
			address           => $address,
			ccuaddress        => $rc->ccuaddress,
			upstreaminterface => $rc->upstreaminterface,
			upstreammodule    => $rc->upstreammodule,
			startmode         => $rc->startmode,
			vlan              => $rc->vlan,
			canvlan           => $rc->canvlan,
			firmwareid        => $rc->firmwareid,
			currentfirmwareid => $currFwName,
			precompiled       => $preCompiled,
			libouncedelay     => $rc->libouncedelay,
			lishortdelay      => $rc->lishortdelay,
			lilongdelay       => $rc->lilongdelay,
			receivebuffer     => $receiveBuffer,
			dimmercyclelength => $dimmerCycleLength,
			dimmerticlength   => $dimmerTicLength,
			bridgemode        => $bridgemode,
			isccu             => $isCCU,
			isccumodule       => $isCCUModule,
			config            => $c->session->{config}
		};
		my $mcastGroups = $rc->mcastgroups;
		for ( my $i = 0 ; $i < 17 ; $i++ ) {
			if ( $mcastGroups & ( 2**$i ) ) {
				$c->stash->{data}->{ "mcastgroup/" . ( 2**$i ) } = 1;
			}
		}
		my $buzzerLevel = $rc->buzzerlevel;
		for ( my $i = 0 ; $i < 17 ; $i++ ) {
			if ( $buzzerLevel & ( 2**$i ) ) {
				$c->stash->{data}->{ "buzzerlevel/" . ( 2**$i ) } = 1;
			}
		}
		my $cryptOption = $rc->cryptoption;
		for ( my $i = 0 ; $i < 2 ; $i++ ) {
			if ( $cryptOption & ( 2**$i ) ) {
				$c->stash->{data}->{ "cryptoption/" . ( 2**$i ) } = 1;
			}
		}

		&setFirmwareFlags( $c, 'fwopt',     $rc->firmwareoptions )        if ( defined( $rc->firmwareoptions ) );
		&setFirmwareFlags( $c, 'currfwopt', $rc->currentfirmwareoptions ) if ( defined( $rc->currentfirmwareoptions ) );

		( $c->stash->{data}->{'cryptkey'} = chr( $rc->cryptkey0 ) )
		  if ( $rc->cryptkey0 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey1 ) )
		  if ( $rc->cryptkey1 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey2 ) )
		  if ( $rc->cryptkey2 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey3 ) )
		  if ( $rc->cryptkey3 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey4 ) )
		  if ( $rc->cryptkey4 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey5 ) )
		  if ( $rc->cryptkey5 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey6 ) )
		  if ( $rc->cryptkey6 != 0 );
		( $c->stash->{data}->{'cryptkey'} .= chr( $rc->cryptkey7 ) )
		  if ( $rc->cryptkey7 != 0 );
	}
	else {
		$c->stash->{data} = { room => $room };
	}
	$c->stash->{success} = 'true';
	$c->forward('View::JSON');
}

sub delete : Local {
	my ( $self, $c, $id ) = @_;
	my $rc = $c->model('hapModel::Module')->search( id => $id )->delete_all;
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
		uid               => $c->request->params->{uid},
		name              => $c->request->params->{name},
		room              => $c->request->params->{room},
		address           => $c->request->params->{address},
		ccuaddress        => $c->request->params->{ccuaddress},
		upstreammodule    => $c->request->params->{upstreammodule},
		upstreaminterface => $c->request->params->{upstreaminterface},
		startmode         => $c->request->params->{startmode},
		vlan              => $c->request->params->{vlan},
		canvlan           => $c->request->params->{canvlan},
		firmwareid        => $c->request->params->{firmwareid},
		libouncedelay     => $c->request->params->{libouncedelay},
		lishortdelay      => $c->request->params->{lishortdelay},
		lilongdelay       => $c->request->params->{lilongdelay},
		receivebuffer     => $c->request->params->{receivebuffer},
		dimmercyclelength => $c->request->params->{dimmercyclelength},
		dimmerticlength   => $c->request->params->{dimmerticlength},
		bridgemode        => $c->request->params->{bridgemode} || 0,
		isccu             => $c->request->params->{isccu} || 0,
		isccumodule       => $c->request->params->{isccumodule} || 0,
		config            => $c->session->{config}
	};
	my $buzzerlevel     = 0;
	my $firmwareoptions = 0;
	my $cryptoption     = 0;
	my $mcastgroups     = 0;
	my $paramRef        = $c->request->params;
	foreach my $key (%$paramRef) {

		if ( $key =~ /cryptkey/ ) {
			my $tmpKey = $paramRef->{$key};
			if ( defined($tmpKey) && $tmpKey ne '' ) {    # even if cryptkey is empty, it gets submitted. Extjs Bug?
				$data->{cryptkey0} = ord( substr( $tmpKey, 0, 1 ) ) || 0;
				$data->{cryptkey1} = ord( substr( $tmpKey, 1, 1 ) ) || 0;
				$data->{cryptkey2} = ord( substr( $tmpKey, 2, 1 ) ) || 0;
				$data->{cryptkey3} = ord( substr( $tmpKey, 3, 1 ) ) || 0;
				$data->{cryptkey4} = ord( substr( $tmpKey, 4, 1 ) ) || 0;
				$data->{cryptkey5} = ord( substr( $tmpKey, 5, 1 ) ) || 0;
				$data->{cryptkey6} = ord( substr( $tmpKey, 6, 1 ) ) || 0;
				$data->{cryptkey7} = ord( substr( $tmpKey, 7, 1 ) ) || 0;

			}
		}
		$mcastgroups |= $1 if ( $key =~ /mcastgroup\/(.*)/ );
		$mcastgroups |= 32768;                                   # 255 -> Broadcast
		$buzzerlevel |= $1 if ( $key =~ /buzzerlevel\/(.*)/ );
		$cryptoption |= $1 if ( $key =~ /cryptoption\/(.*)/ );
		if ( $key =~ /fwopt\/(.*)/ ) {
			if ( $1 =~ /64\/1/ ) {
				$firmwareoptions |= 64;
			}
			elsif ( $1 =~ /64\/2/ ) {
				$firmwareoptions |= 128;
			}
			elsif ( $1 =~ /64\/3/ ) {
				$firmwareoptions |= 64;
				$firmwareoptions |= 128;
			}
			elsif ( $1 =~ /16384\/1/ ) {
				$firmwareoptions |= 16384;
			}
			elsif ( $1 =~ /16384\/2/ ) {
				$firmwareoptions |= 32768;
			}
			else {
				$firmwareoptions |= $1;
			}
		}
	}
	if ( $firmwareoptions == 0 ) {    # checkboxes disabled in frontend -> precompiled firmware selected
		my $rc = $c->model('hapModel::Firmware')->search( id => $c->request->params->{firmwareid} )->first;
		if ( defined($rc) ) {
			$firmwareoptions = $rc->compileoptions;
		}
	}
	$data->{mcastgroups}     = $mcastgroups;
	$data->{buzzerlevel}     = $buzzerlevel;
	$data->{firmwareoptions} = $firmwareoptions;
	$data->{cryptoption}     = $cryptoption;
	my $rs;
	if ( $id == 0 ) {
		$rs = $c->model('hapModel::Module')->create($data);
	}
	else {
		$rs = $c->model('hapModel::Module')->search( id => $id )->first;
		$rs->update($data);
	}    
	if ( $data->{upstreammodule} == 0 ) {    #self
		$data->{upstreammodule} = $rs->id;
		$rs = $c->model('hapModel::Module')->search( id => $rs->id )->first;
		$rs->update($data);
	}
	$data->{id}          = $rs->id;
	$c->stash->{success} = \1;
	$c->stash->{info}    = "Done.";
	$c->stash->{data}    = $data;            # push back to form via json
	$c->forward('View::JSON');
}

sub checkForCCU : Local {
	my ( $self, $c, $name, $id ) = @_;
	my @tmp =
	  map { { 'id' => $_->id, 'name' => $_->name } }
	  $c->model('hapModel::Module')->search( { config => $c->session->{config}, $name => 1, id => { '!=', $id } } )->all;
	if ( $tmp[0] ) {
		$c->stash->{success} = \1;
	}
	else {
		$c->stash->{success} = \0;
	}
	$c->stash->{data} = \@tmp;
	$c->forward('View::JSON');
}

sub getFwOpts : Local {
	my ( $self, $c, $from, $id ) = @_;
	my $fwOpts;
	if ( $from eq "fromFirmware" ) {
		my $rs = $c->model('hapModel::Firmware')->search( id => $id )->first;
		$fwOpts = $rs->compileoptions;
	}
	else {
		my $rs = $c->model('hapModel::Module')->search( id => $id )->first;
		$fwOpts = $rs->firmwareoptions;
	}

	&setFirmwareFlags( $c, 'fwopt', $fwOpts );

	$c->stash->{success} = 'true';
	$c->forward('View::JSON');
}

sub setFirmwareFlags() {
	my $c      = shift;
	my $name   = shift;
	my $fwOpts = shift;
	$c->stash->{data}->{"$name/64/1"}    = 0;
	$c->stash->{data}->{"$name/64/2"}    = 0;
	$c->stash->{data}->{"$name/64/3"}    = 0;
	$c->stash->{data}->{"$name/16384/1"} = 0;
	$c->stash->{data}->{"$name/16384/2"} = 0;

	for ( my $i = 0 ; $i < 32 ; $i++ ) {

		if (   ( $fwOpts & ( 2**$i ) ) == 64
			&& ( $fwOpts & ( 2**( $i + 1 ) ) ) == 0 )
		{    # LCD 1Row
			$c->stash->{data}->{"$name/64/1"} = 1;
		}
		elsif (( $fwOpts & ( 2**$i ) ) == 0
			&& ( $fwOpts & ( 2**( $i + 1 ) ) ) == 128 )
		{    # LCD 2Row
			$c->stash->{data}->{"$name/64/2"} = 1;
		}
		elsif (( $fwOpts & ( 2**$i ) ) == 64
			&& ( $fwOpts & ( 2**( $i + 1 ) ) ) == 128 )
		{    # LCD 3Row
			$c->stash->{data}->{"$name/64/3"} = 1;
		}

		elsif (( $fwOpts & ( 2**$i ) ) == 16384
			&& ( $fwOpts & ( 2**( $i + 1 ) ) ) == 0 )
		{    # Rotary Encoder 1
			$c->stash->{data}->{"$name/16384/1"} = 1;
		}
		elsif (( $fwOpts & ( 2**$i ) ) == 0
			&& ( $fwOpts & ( 2**( $i + 1 ) ) ) == 32768 )
		{    # Rotary Encoder 2
			$c->stash->{data}->{"$name/16384/2"} = 1;
		}
		elsif ( $fwOpts & ( 2**$i ) ) {
			$c->stash->{data}->{ "$name/" . ( 2**$i ) } = 1;
		}
		else {
			$c->stash->{data}->{ "$name/" . ( 2**$i ) } = 0;
		}
	}
	return 0;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
