Für detaillierte Ausgaben sollte man die Server-Dienste im Vordergrund starten. Insbesondere der HAP-Message-Processor kann so wertvolle Informationen liefern, da hier alle HAP-Datenpakete angezeigt werden.

Die jeweiligen Dienste lassen sich wie folgt im Vordergrund starten:

Zunächst den laufenden Prozess stoppen:
```
/etc/init.d/hap-mp stop
oder
/etc/init.d/hap-scheduler stop
oder
/etc/init.d/hap-configserver stop
```
Dann den jeweiligen Dienst im Vordergrund starten:
```
/opt/hap/bin/hap-mp.pl 
oder
/opt/hap/bin/hap-scheduler.pl
oder
/opt/hap/bin/hap-configserver.pl
```

Sollten in der HAP-Config-GUI vermeintliche Fehler auftauchen, so können Sie die Debug-Version der Oberfläche mit /debug aufrufen:

Aus

http://ihr-server:8090

wird dann

http://ihr-server:8090/debug

Der Javascript-Code der GUI liegt nun im "Klartext" im Browser vor und kann z.B. Firebug analysiert werden.