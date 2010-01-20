use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'hapConfig' }
BEGIN { use_ok 'hapConfig::Controller::Log' }

ok( request('/log')->is_success, 'Request should succeed' );


