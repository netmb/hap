package hapConfig::hapSchema::AllAddresses;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table('dummy');
__PACKAGE__->add_columns(qw/address/);
__PACKAGE__->result_source_instance->name( \<<SQL);
(
SELECT static_address.address FROM static_address
LEFT JOIN device ON device.address = static_address.address
AND device.Config= ?
AND device.Module = ?
LEFT JOIN logicalinput ON logicalinput.address = static_address.address
AND logicalinput.Config= ?
AND logicalinput.Module = ?
LEFT JOIN analoginput ON analoginput.address = static_address.address
AND analoginput.Config = ?
AND analoginput.Module = ?
LEFT JOIN digitalinput ON digitalinput.address = static_address.address
AND digitalinput.Config= ?
AND digitalinput.Module = ?
LEFT JOIN abstractdevice ON abstractdevice.address = static_address.address
AND abstractdevice.Config= ?
AND abstractdevice.Module = ?
LEFT JOIN homematic ON homematic.address = static_address.address
AND homematic.Config= ?
AND homematic.Module = ?
WHERE device.address IS NULL
AND logicalinput.address IS NULL
AND analoginput.address IS NULL
AND digitalinput.address IS NULL
AND abstractdevice.address IS NULL
AND homematic.address IS NULL
ORDER BY static_address.address
)
SQL

1;
