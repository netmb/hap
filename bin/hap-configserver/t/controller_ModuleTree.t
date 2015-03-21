use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'hapConfig' }
BEGIN { use_ok 'hapConfig::Controller::ModuleTree' }

ok( request('/moduletree')->is_success, 'Request should succeed' );


