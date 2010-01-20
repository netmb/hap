package hapConfig::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
  {
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
      hapConfig->path_to( 'root', 'src' ),
      hapConfig->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS => 'config/main',
    ## Ben Remove Wrapper headers
    ##WRAPPER     => 'site/wrapper',
    ERROR       => 'error.tt2',         
    TIMER       => 0
  }
);

=head1 NAME

hapConfig::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<hapConfig>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

