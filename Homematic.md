# Einbindung von Homematic-Komponenten #

Ab der SVN-Version (>= 276) ist es möglich, Homematic-Komponenten in das HAP-System einzubinden (ich habe mich hier am Code vom fhem-Projekt bedient :-)).
Hierzu wird ein HMLAN-Interface benötigt, welches im Netzwerk eingebunden wird. Der HAP-Message-Processor (hap-mp.pl) kommunziert dann mit den Homematic-Komponenten über das HMLAN-Interface.

# Konfiguration #

Zur Aktivierung des HMLAN-Interfaces in der HAP-Umgebung sind folgende Einträge in der hap.yml-Datei (opt/hap/etc/) zu ergänzen:

```
Homematic:
  HmLanId : '1C65B8'
  HmLanIp: 192.168.165.49
  HmLanPort: 1000
  HmSecKey: 'Sicherheitsschlüssel falls vergeben, sonst leer lassen'
  HmVirtualId: 'ABCDEF'
```
Die Parameter sind dann den eigenen Gegebenheiten anzupassen. Die entsprechenden Werte lassen sich mit der Windows-Konfigurations-Software des HMLAN-Interface herausfinden bzw. setzen.

Wichtig ist: Die AES-Encryption auf LAN-Seite muss in der Windows-Software deaktiviert werden, sonst kann der Message-Processor die Datagramme des HMLAN nicht interpretieren.

Aktuell werden folgende Homematic-Komponenten unterstützt:

  * Bewegungsmelder innen
  * Fenster-Drehgriffkontakt
  * Reed-Kontakt innen
  * Aufputz 2x Taster
  * Zwischensteckdose (Schalter)

Die Einbindung weitere Homematic-Komponenten sollte aber problemlos machbar sein, da hierfür nur der Homematic-Parser angepasst werden muss.

# Einbindung der Homematic-Komponenten #

Zunächst muss die jeweilige Homematic-Komponete mit dem HMLAN-Interface "verheiratet" werden. Hierzu wird die Homematic-Komponente über die Windows-Software einmalig angelernt.

Alternativ kann mit dem Befehl "hmpair" welches man direkt über eine Telnet-Session zum Messageprocessor (telnet localhost 7891) eingibt, die Homematic-Komponente an den HMLAN gebunden werden. Nach Eingabe des hmpair-Befehls muss man den Setup/Config-Knopf auf der jeweiligen Homematic-Komponente drücken (Gerät fängt an zu blinken). Nach wenige Sekunden hört das Blinken auf und die Bindung sollte erfolgt sein.

Nachdem die Komponente angelernt wurde, kann sie über die HAP-Weboberfläche unter dem Menüpunkt "Homematic" eingebunden werden.

Es empfiehlt sich für die Homematic-Komponenten ein Dummy-HAP-Modul anzulegen und unterhalb von diesem Modul dann die einzelnen Homematic-Komponenten anzulegen.

Danach ist eine Kommunikation auch über das HAP-System möglich.

# Kommunikation #
Aus HAP-Sicht verhält sich eine Homematic-Komponente wie ein HAP-Device. Es kann also ganz normal mit einem SET und QUERY-Befehl angesprochen werden. Wenn ein Notify-Modul für die Komponente definiert ist, dann erfolgt auch der Versand einer Status-Meldung (Message-Type 16).