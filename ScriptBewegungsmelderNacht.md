# Bewegungsmelder für Beleuchtung nach Sonnenuntergang aktiv schalten #

## Ist ##

Ein Bewegungsmelder wurde im Garten montiert und soll die Beleuchtung der Terrasse steuern. Ein Helligkeitssensor ist noch nicht vorhanden.

## Soll ##

Ein Bewegungsmelder für die Terrassenbeleuchtung soll nur nach Sonnenuntergang aktiv sein. Als Besonderheit wird der Sonnenauf- u. untergang von dem Server berechnet und dann als Status an die CU gemeldet. Dort kann der Status in der Autonomen-Steuerung ausgelesen werden.

## Lösung ##
### Programm ###

Das Programm rscalc2 aus dem Wetterstationsforum berechnet nach Längen- und Breitengrad des Wohnorts die Uhrzeit für den Sonnenuntergang des aktuellen Tages.
Das Programm muss selber kompiliert werden und nach /opt/hap/var/scripts kopiert werden. Die Optionen für make stehen im Kopf der Sourcen.

http://wetter.looplab.org/source/rscalc2.c

### Server Konfiguration ###

Cronjob anlegen der jeden Tag um 0 Uhr das Skript 'suntimer' ausführt

```
crontab –e
0 0 * * * /opt/hap/var/scripts/suntimer
```

Skript: suntimer

```
#!/bin/bash
SR=$(/opt/hap/var/scripts/rscalc2 51.5 6.9 `date +"%:::z"` -sr)
at -f /opt/hap/var/scripts/suntimer_off -v $SR

SS=$(/opt/hap/var/scripts/rscalc2 51.5 6.9 `date +"%:::z"` -ss)
at -f /opt/hap/var/scripts/suntimer_on -v $SS
```

Das Skript berechnet die Zeit des Sonnenaufgangs und legt einen Timer zur einmaligen Ausführung des Skript 'suntimer\_off' an. Entsprechend wird der Timer für den Sonnenuntergang für das Skript 'suntimer\_on' gesetzt.


Die Parameter 51.5 und 6.9 stehen für den Längen- u. Breitengrad und müssen für den eigenen Wohnort angepasst werden.
Die beiden Skripte setzen den Status eines Switch-Device auf einer CU. Dieses wird für einen freien Port-Pin per Config-GUI konfiguriert.

Skript: suntimer\_off

```
#!/bin/bash
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 204 set device 10 value 0"
```


Skript: suntimer\_on

```
#!/bin/bash
/opt/hap/bin/helper/hap-sendcmd2.pl "destination 204 set device 10 value 100"
```


### CU Konfiguration ###

Auf der CU wird ein Switch-Device konfiguriert das praktisch nur dazu dient vom Server Ein- oder Ausgeschaltet zu werden. Der dazugehörige Port wird extern nicht beschaltet.
Eventuell sollte man darüber nachdenken auf der CU virtuelle Ports anzulegen die nicht mit realen Port-Pins verknüpft sind. Es soll ja lediglich der Status in der CU abgelegt werden.

Anschließend wird die AS-Sequenz für den Beleuchtung angelegt.
Das Licht wird bei Bewegung für 120 Sek. eingeschaltet, wenn gleichzeitig der Status des Suntimers "Ein" ist.
Dies Funktioniert weil der Status des Switch-Device sich über die Konfiguration als Input in der AS-Sequenz einfach abfragen lässt.
Das Status-Output-Device sorgt dafür dass im Logfile nicht jede einzelne Bewegung abgespeichert wird, sondern nur in einem Intervall von mindestens 120 Sek. Das Input-Device des Bewegungsmelders wird deshalb so konfiguriert das keine Statusmeldung gesendet wird.

![http://hap.googlecode.com/svn/wiki/images/Bewegungsmelder.jpg](http://hap.googlecode.com/svn/wiki/images/Bewegungsmelder.jpg)
Über diese Vorgehensweise lassen sich alle erdenklichen Ergebnisse eines Server-Skripts mit der Autonomen-Steuerung verarbeiten.