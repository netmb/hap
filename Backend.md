# Backend #

Neben der hier gezeigten Config- und Web-GUI sind noch weitere Komponenten vorhanden, welche im Hintergrund laufen und den eigentlichen Übergang zum HAP-System realisieren.

Die Installation dieser Komponenten erfolgt zusammen mit der Config-/Web-GUI. Die Zielplattform ist ein Debian-Linux. Das Installationspaket wird als Deb-Paket angeboten.

Alle Komponenten laufen problemlos in einer virtuellen Maschine.

Zurück zu den Backend-Komponenten:

Die Schnittstelle zwischen Config-/Web-GUI zur HAP-Installation wird über den HAP-Messageprocessor (hap-mp.pl) realisiert. Dieser Dienst besitzt zum einen eine TCP-Schnittstelle (telnet) und auf der "anderen Seite" eine USB-Anbindung.  Interagiert die Config-/Web-GUI also mit dem HAP-System, so verwendet die GUI die TCP-Schnittstelle. Die Daten werden dann vom Message-Processor verarbeitet und auf die USB-Schnittstelle übertragen.

Der Message-Processor besitzt zudem eine Schnittstelle zur MySQL-Datenbank, so dass alle Status-/Config-Änderungen direkt abgefragt/übermittelt werden.

Zudem existiert ein Scheduler-Dienst, welcher über eine TCP-Schnittstelle entsprechende Aufgaben entgegenimmt und dies zur angeforderten Zeit ausführt. Wer den Cron-Dienst unter Linux kennt, weis was hier gemeint ist. Es können sowohl einmalige Ereignisse (z.B. die Programmierung einer Control-Unit) als auch wiederkehrende Ereignisse übergeben werden (z.B. Abfrage eines Wertes alle 15min).