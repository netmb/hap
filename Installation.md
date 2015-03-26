## Installation ##

Nach der Installation von Ubuntu-Server 11.10 oder 12.04 (Debian sollte ebenfalls problemlos funktionieren), führt man folgende Kommandos auf der Konsole aus:

```
wget http://hap.googlecode.com/files/setup.sh
chmod 755 setup.sh
./setup.sh
```

Das Setup-Script führt alle notwendigen Schritte für die Installation von HAP aus. Sollte aus irgendeinem Grund einer der im Setup-Script aufgeführten Schritte fehlschlagen, so kann das Script einfach erneut gestartet werden.

Wenn alles problemlos installiert wurde, sollte man sich nach 5-10min über folgende Seite am HAP-Frontend anmelden können:

http://ihr-server:8090

Zudem sollte man kontrollieren, ob alle HAP-Dienste ordnungsgemäß gestartet sind:
```
ps aux
```
```
hap       6084  9.8  5.7  39904 29712 ?        S    17:53   0:01 /usr/bin/perl /opt/hap/bin/hap-configserver.pl -f
hap       6098  3.2  2.4  17024 12636 ?        S    17:53   0:00 /usr/bin/perl /opt/hap/bin/hap-scheduler.pl
hap       6101  0.1  2.2  16984 11396 ?        S    17:53   0:00 /opt/hap/bin/hap-scheduler.pl POE::Component::EasyDBI::SubProcess pinged at Sun Mar 15 17:53:44 2009
hap       6114 16.0  2.9  19248 14932 ?        S    17:53   0:00 /usr/bin/perl /opt/hap/bin/hap-mp.pl
hap       6117  0.0  2.6  19380 13620 ?        S    17:53   0:00 /opt/hap/bin/hap-mp.pl POE::Component::EasyDBI::SubProcess connected at Sun Mar 15 17:53:50 2009
```


Wenn am Server keine CU via Serial/USB angeschlossen ist, so wird im HAP-Frontend folgende Meldung auftauchen:

_Can't connect to Message-Processor._

Wenn man sich nur mal ein wenig umschauen möchte, kann man diesen Fehler umgehen, indem man in der Datei /opt/hap/etc/hap.yml folgende Änderung vornimmt:

Von:
```
#ServerCUConnection:
#  Type: 'Network'
#  Host: 192.168.165.1
#  Port: 4567
ServerCUConnection:
  Type: 'Serial'
  Ports: [ '/dev/ttyUSB0', '/dev/ttyUSB1' ]
```
Zu:
```
ServerCUConnection:
  Type: 'Network'
  Host: 192.168.165.1
  Port: 4567
#ServerCUConnection:
#  Type: 'Serial'
#  Ports: [ '/dev/ttyUSB0', '/dev/ttyUSB1' ]
```
Nach dem speichern muss noch der der HAP-MessageProcessor neugestartet werden:
```
/etc/init.d/hap-mp restart 
```


Ubuntu 12.04: Sofern es Probleme mit den Rechten des Nutzers HAP gibt (USB funktionierte nicht), bitte HAP in folgende Nutzergruppe hinzufügen:
```
sudo adduser benutzername dialout
```