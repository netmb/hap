# Introduction #

Kurzer Bash Script zur Überwachung der USB Verbindung und bei Problemen Restart von HAP.

# Details #
```
#! /bin/bash

result=$(/opt/hap/bin/helper/hap-sendcmd2.pl "destination 105 query device 150")
echo "$result"
stringZ="${result:1:3}"

case "$stringZ"  in
"ERR")
echo "restart"
/etc/init.d/hap-mp restart
;;
"ACK")
echo "Running"
;;
*)
echo "Unknown result: " $stringZ
esac
```