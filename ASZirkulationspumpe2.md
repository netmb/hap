#Bedarfsorientierte Warmwasser-Zirkulation

# Ist #

Die Warmwasser-Zirkulation erfolgt in einem bestimmten Zeitraum (Heizungs-Zeitprogramm) und wird durch einfaches ein-ausschalten in einem Intervall von 10min bereitgestellt.

# Soll #

Die Warmwasser-Zirkulation soll bedarfsorientiert zur Verfügung gestellt werden. Dies bedeutet, dass bei einer Bewegungsdetektion bzw. Tür öffnen/schliessen die Warmwasserpumpe starten soll.

Zudem soll die Pumpe nur so lange laufen, bis das Warmwasser in der Zirkulationsleitung einen bestimmten Wert erreicht hat.  Ebenso soll die Freigabe für die Pumpe erst erfolgen, wenn eine bestimmte Warmwassertemperatur in der Zirkulationsleitung unterschritten wurde.

Weiterhin soll die Pumpe im Zeitraum von 23:00 bis 05:00 Uhr nicht anlaufen.

# Lösung #

Im Badezimmer wurde ein Homematic-Funk-Bewegungsmelder installiert. Im Gäste-WC wurde an der Tür ein Homematic-Funk-Reed-Kontakt installiert.  An der Zirkulationsleitung wurde in Pumpennähe ein Digitaler-Eingang mit einem Dallas-Temperatur-Sensor über HAP angebunden.

Auf einer CU, welche über eine Relais-Stufe die Zirkulationspumpe steuert wurde folgende Autonome-Steuerung konfiguriert:

![http://hap.googlecode.com/svn/wiki/images/AS-Zirkulation2.png](http://hap.googlecode.com/svn/wiki/images/AS-Zirkulation2.png)

Der Bewegungsmelder senden einen Status 132 bei Detektion. Der Reed-Kontakt einen Status 0, wenn die Tür geschlossen wird.

Der digitale Eingang mit Dallas-Temperatursensor ist wie folgt konfiguriert:

![http://hap.googlecode.com/svn/wiki/images/Sensor-Zirkulation.png](http://hap.googlecode.com/svn/wiki/images/Sensor-Zirkulation.png)

Bei Unterschreitung von XX Grad wird der Triggerstatus 64 abgesetzt, bei Überschreitung der Triggerstatus 193. Durch die Bitweise-Und-Verknüpfung wird das Flip-Flop "eingeschaltet", wenn der Triggerwert 64 (Unterschreitung) und eine Bewegung oder ein Tür-schliessen detektiert wurden.

Ist der Triggerstatus 193 so wird das Flip-Flop zurückgesetzt . Zudem wird das Flip-Flop zurückgesetzt, wenn der Timer aktiv ist (zwischen 23:00 und 05:00 Uhr) bzw. das Flip-Flop am Ausgang für 5min aktiv war (Switch-on delay).

Somit wird verhindert, dass die Pumpe zum Dauerläufer wird, wenn die Trigger-Überschreitung nicht erfolgt (Warmwasser ist nicht warm genug).