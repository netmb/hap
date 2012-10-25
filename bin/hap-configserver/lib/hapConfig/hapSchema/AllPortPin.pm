package hapConfig::hapSchema::AllPortPin;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table('dummy');
__PACKAGE__->add_columns(qw/portpin/);
__PACKAGE__->result_source_instance->name( \<<SQL);
(
SELECT CONCAT(static_portpin.port, "-", static_portpin.pin) as portpin FROM static_portpin
LEFT JOIN device ON device.Port = static_portpin.Port
AND device.Pin = static_portpin.Pin
AND device.Config= ?
AND device.Module = ?
LEFT JOIN logicalinput ON logicalinput.Port = static_portpin.Port
AND logicalinput.Pin = static_portpin.Pin
AND logicalinput.Config= ?
AND logicalinput.Module = ?
LEFT JOIN analoginput ON analoginput.Port = static_portpin.Pin
AND analoginput.Pin = static_portpin.Pin
AND analoginput.Config = ?
AND analoginput.Module = ?
LEFT JOIN digitalinput ON digitalinput.Port = static_portpin.Port
AND digitalinput.Pin = static_portpin.Pin
AND digitalinput.Config= ?
AND digitalinput.Module = ?
WHERE device.Port IS NULL 
AND logicalinput.Port IS NULL
AND analoginput.Port IS NULL
AND digitalinput.Port IS NULL
ORDER BY CONCAT(static_portpin.port, "-", static_portpin.pin)
)
SQL

1;
