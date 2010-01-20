package hapConfig::Controller::Bootloader;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Time::Local;

=head1 NAME

hapConfig::Controller::Bootloader - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched hapConfig::Controller::Bootloader in Bootloader.');
}

sub get : Local {
	my ( $self, $c ) = @_;
	my $baseHex    = '047FFC0000';
	my $startMin   = 0;
	my $startHour  = 0;
	my $startMonth = 1;
	my $startDay   = 1;
	my $startYear  = 2008;
	my $currentMin = sprintf( "%.0f", ( time - timelocal( 0, $startMin, $startHour, $startDay, $startMonth - 1, $startYear ) ) / 60 );

	my $rs = $c->model('hapModel::StaticBootloaderid')->search()->first;
	if ($rs) {
		my $bl = $rs->bootloaderid;
		if ( $bl >= $currentMin ) {
			$bl++;
			$currentMin = $bl;
		}
		else {
			$bl = $currentMin;
		}
		$rs->update( { bootloaderid => $bl } );
	}    
	else {
		$c->model('hapModel::StaticBootloaderid')->create( { bootloaderid => $currentMin } );
	}

	my $minSinceThen = sprintf( "%06x", $currentMin );    #in hex (6 digits)
	$baseHex .= $minSinceThen;

	# sum bytes
	my $sum = 0;
	for ( my $i = 0 ; $i < length($baseHex) ; $i += 2 ) {
		$sum += hex( substr( $baseHex, $i, 2 ) );
	}

	# 2er Kompliment
	$sum = ~$sum % 256;                                   # sum modulo 256 and invert
	if ( $sum != 255 ) {
		$sum += 1;
	}

	# attach checksum
	$baseHex .= sprintf( "%02x", $sum );

	open( FWIN, "<" . $c->config->{Bootloader} );
	my $i         = 0;
	my @lines     = <FWIN>;
	my $lineCount = @lines;
	my $content;
	foreach (@lines) {
		if ( $i == ( $lineCount - 2 ) ) {
			$content .= ":" . uc($baseHex) . "\n";
		}
		$content .= $_;
		$i++;
	}
	close FWIN;

	$c->stash->{template} = 'main/bootloader.tt2';

	if ( $c->forward('hapConfig::View::TT') ) {
		$c->response->content_type('text/plain');
		$c->response->header( 'Content-Disposition', "attachment; filename=HAPBootLoader-" . uc( substr( $baseHex, 10, 6 ) ) . ".hex" );
		$c->response->body($content);
	}
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
