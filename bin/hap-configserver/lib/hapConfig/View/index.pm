package hapConfig::View::index;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
  TEMPLATE_EXTENSION => '.tt2',
  CATALYST_VAR       => 'Catalyst',                                                                     
  INCLUDE_PATH       => [ hapConfig->path_to( 'root', 'src' ), hapConfig->path_to( 'root', 'lib' ) ],
  PRE_PROCESS        => 'config/main',
  ##WRAPPER      => 'site/wrapper',
  ERROR => 'error.tt2',
  TIMER => 0
);

=head1 NAME

hapConfig::View::index - TT View for hapConfig

=head1 DESCRIPTION

TT View for hapConfig. 

=head1 AUTHOR

=head1 SEE ALSO

L<hapConfig>

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
