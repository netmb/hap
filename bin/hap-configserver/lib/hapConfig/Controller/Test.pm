package hapConfig::Controller::Test;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Test - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'main/test.tt2';
}

sub getNodes : Local {
	my ( $self, $c ) = @_;
	my @rc    = $c->model('hapModel::GuiTypes')->search( type => "HAP.Chart" )->first;
	my $chart = JSON::XS->new->utf8(0)->decode( $rc[0]->display );

	#	my $chart;
	#foreach (@$display) {
	#	my %cur = %$_;
	#	my $treeObj =
	#	foreach my $key ( keys %cur ) {
	#		$c->log->debug( $key . "\n" );
	#
	#	}
	#}
	$c->stash->{'data'} = $chart;
	$c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
