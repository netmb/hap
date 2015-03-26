# Rollos nach Sonnenuntergang in Stellung Nacht fahren #

## Ist ##

Das Makro zum Schließen der Rollos des Ober- u. Dachgeschosses wird manuell gestartet.

## Soll ##

Die Rollos sollen automatisch zur berechneten Sonnenuntergangszeit geschlossen werden.
## Lösung ##
### Programm ###

Das Programm rscalc2 aus dem Wetterstationsforum berechnet nach Längen- und Breitengrad des Wohnorts die Uhrzeit für den Sonnenuntergang des aktuellen Tages.
Das Programm muss selber kompiliert werden und nach /opt/hap/var/scripts kopiert werden. Die Optionen für make stehen im Kopf der Sourcen.

http://wetter.looplab.org/source/rscalc2.c

### Konfiguration ###

Cronjob anlegen der jeden Tag um 0 Uhr das Skript 'set\_sunset\_rollo\_down' ausführt

```
crontab –e 0 0 * * * /opt/hap/var/scripts/set_sunset_rollo_down 
```

### Skript: set\_sunset\_rollo\_down ###


```
#!/bin/bash
# Uhrzeit der kompletten Dunkelheit
SSCT=$(/opt/hap/var/scripts/rscalc2 51.5 6.9 `date +"%:::z"` -ssct)
at -f /opt/hap/var/macro/48.ROLLOS_OG_DG_NACHT -v $SSCT 
```

Das Skript berechnet die Zeit des Sonnenuntergangs und legt einen Timer zur einmaligen Ausführung des Makros zum schließen der Rollos an.
Die Parameter 51.5 und 6.9 stehen für den Längen- u. Breitengrad und müssen für den eigenen Wohnort angepasst werden.
Das Makro wird mit der HAP-Config-GUI angelegt und ist dann auch für AS-Steuerungen benutzbar.

Makro: 48.ROLLOS\_OG\_DG\_NACHT

```
#!/bin/bash
# Rollladen OG/DG auf Nacht verfahren
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 211 set device 151 value 70" #SZ1
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 211 set device 152 value 70" #SZ2
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 211 set device 153 value 100" #HW
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 211 set device 150 value 55" #KD1
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 210 set device 153 value 41" #KD2
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 210 set device 150 value 65" #BD1
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 210 set device 151 value 65" #BD2
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 210 set device 152 value 100" #AZ
```

<**destination**> ist die jeweilige Nummer der CU, <**device**> die Adresse des Rollladen-Device und <**value**> legt die Position des Rollos fest.