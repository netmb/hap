# Script zum automatischen Starten von Firefox /eines Script nach dem Start vom HAP-mp.pl #

# Ist #

# Soll #

Browser soll automatisch nach dem Start des Rechner im Fullscreen starten wenn hap-mp.pl gestartet wurde, um keine Fehlermeldung bei noch nicht Verfügbarkeit von HAP zu bekommen.
Parallel startet ein Script zur Abfrage der CU Daten als update.

# Lösung #

Bzgl. Firefox muss das Fullscreen Plugin installiert werden. Darin kann man unter den Einstellen das Starten im Fullscreen aktivieren.

Script:

```
#! /bin/bash
while [ "$(pidof hap-mp.pl | tr -d '0123456789' | wc -c)" -lt "1" ]
do
sleep 5
done


# HAP-mp.pl running now"
# Start here the update script after hap-mp.pl is loaded 
sleep 2
cd /opt/hap/var/scripts
./update.pl
# Start Firefox
sleep 2
firefox
exit 0
```

Beispiel für "update.pl"

```
#!/usr/bin/perl -w
# Read from CU 100 the status of Address 80
system( "/opt/hap/bin/helper/hap-sendcmd2.pl", "destination 100 query device 80");
```