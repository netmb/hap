Nach der Installation des Deb-Paketes befindet sich das ganze "HAP-System" im Verzeichnis /opt/hap.
Hier die wichtigsten Verzeichnisse und Dateien:

  * ./bin/hap-mp.pl - Message Processor
  * ./bin/hap-scheduler.pl - Scheduler
  * ./bin/hap-cmd.pl - Konsolentool (HAP-Shell)
  * ./bin/hap-configserver.pl - Wrapper-Script für die Web-Config-GUI (verweist auf ./bin/hap-configserver/scripts/hapconfig\_server.pl)
  * ./bin/hap-configserver/ - Web-Config-GUI. Hierbei handelt es sich um eine Catalyst Applikation.
  * ./bin/helper - Hier befinden sich diverse Scripte, welche über den Scheduler aufgerufen werden.
  * ./bin/helper/hap-configbuilder.pl - Generiert eine Modulkonfiguration
  * ./bin/helper/hap-flashfirmware.pl - Firmwaretransfer zu den Modulen
  * ./bin/helper/hap-lcdguibuilder.pl - Generiert und transferiert die LCD-GUI-Datei für entsprechende Module
  * ./bin/helper/hap-sendcmd.pl - Dieses Script erwartet ein HAP-Command als Parameter, welches es dann ausführt.
  * ./bin/helper/hap-sendcmd2.pl - Dieses Script ist die schlanke Variante von hap-sendcmd.pl (besser geeignet für Scripte (Makros...))
  * ./bin/helper/hap-showmodules.pl - Dieses Script zeigt die Zuordnung von Datenbank-ID zur Modul-Adresse für jedes Modul innerhalb der laufenden Konfiguration
  * ./etc/hap.yml - Zentrale Konfigurationsdatei. Diese YAML-Datei wird über das Init.pm-Modul eingelesen und als Perl-Object ($c) in den meisten HAP-Programmen zur Verfügung gestellt.
  * ./var - Diverses
  * ./var/bootloader - Hier liegt der aktuelle HAP-Bootloader. An dieser Datei sollten keine Veränderungen vorgenommen werden.