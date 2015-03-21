package hapConfig::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

__PACKAGE__->config(
  'View::JSON' => {
    allow_callback => 1,      # defaults to 0
    callback_param => 'cb'    # defaults to 'callback'
  },
  CATALYST_VAR => 'Catalyst',
  INCLUDE_PATH => [ hapConfig->path_to( 'root', 'src' ), hapConfig->path_to( 'root', 'lib' ) ],
  PRE_PROCESS  => 'config/main',
  ERROR        => 'error.tt2',
  TIMER        => 0
);

sub encode_json {
  my ( $self, $c, $data ) = @_;
  my $encoder = JSON::XS->new->utf8(0);
  $encoder->encode($data);
}    


=head1 NAME

hapConfig::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<hapConfig>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
