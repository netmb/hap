# Zeit- und temperaturgesteuerte Warmwasser-Zirkulationspumpe #

## Ist ##

Eine Zirkulationspumpe wurde in die Warmwasser-Zirkulationsleitung einer Heizungsanlage eingebaut. Die Pumpe besitzt keine Regelung.

## Soll ##

Die Pumpe soll nur im Betrieb sein, wenn auch Personen im Haus anwesend sind. Zudem soll die Pumpe nur so lange laufen, bis über die Zirkulationsleitung warmes Wasser zurück in den Warmwasserbehälter fliesst.

# Lösung: #

## Hardware ##

Die Pumpe wird an einen Relais-Ausgang angeschlossen. Zudem wird ein Dallas 18S20-Temperatursensor an der Warmwasser-Zirkulationsleitung befestigt.

## Konfiguration ##

Der Temperatursensor wird mit zwei Triggern versehen:

32°C = Bei Unterschreitung wird ein Trigger als Statusmeldung versendet. 40°C = Bei Überschreitung wird ein Trigger als Statusmeldung versendet.

Achtung: Die Statusmeldungen müssen als Ziel die CU enthalten, auf der auch die Autonome-Steuerung läuft (Notify-Feld).

![http://hap.googlecode.com/svn/wiki/images/Digitaler-Eingang-DS18S20-Trigger.png](http://hap.googlecode.com/svn/wiki/images/Digitaler-Eingang-DS18S20-Trigger.png)

## Autonome Steuerung ##

#### Folgendes Zeitschema ist gewünscht: ####


  * Mo.-Fr. : 05:00 bis 07:30

  * Mo.: 12:00 bis 22:00

  * Di.: 16:00 bis 22:00

  * Mi.: 07:31 bis 22:00

  * Do.: 16:00 bis 22:00

  * Fr.: 07:31 bis 22:00

  * Sa.: 07:00 bis 22:00

  * So.: 07:00 bis 22:00


Die Sequenz der AS sieht dann so aus:

![http://hap.googlecode.com/svn/wiki/images/AS-Zirkulation.png](http://hap.googlecode.com/svn/wiki/images/AS-Zirkulation.png)

Auf der linken Seiten finden sich die jeweiligen Timer (7x Timer-wöchentlich (je ein Wochentag) und 1x Timer täglich (Mo.-Fr.)). Als Startzeit wird dann z.B. für Montag 12:00 Uhr gewählt und ein Intervall von 10 Stunden.

Die Timer werden dann über Oder-Verknüpfungen (ein oder mehrere Timer müssen aktiv sein, damit was passiert) zusammengeführt.

Unten links wird über einen passiven Eingang die Statusmeldung der Trigger abgefangen und dann jeweils in einen Vergleich geschickt (Bei Trigger-Unterschreitung wird 64 gesendet, bei Überschreitung 193). Die Triggerwerte lassen sich entweder per Hand berechnen, oder man lässt den Message-Processor im Vordergrund laufen und schaut, welche Werte tatsächlich versendet werden.

Über die Bitweise-UND-Verknüpfung wird dann überprüft, ob ein Timer und der untere Trigger aktiv sind. Wenn dem so ist, wird über das Flip-Flop der Ausgang und somit die Zirkulationspumpe eingeschaltet. Wird also ein Trigger bei Unterschreitung ausgelöst, aber kein Timer ist aktiv, so passiert nichts. Soweit so gut.

Das Verhalten beim Ausschalten der Zirkulationspumpe muss jedoch etwas anders sein:

Die Pumpe muss auch ohne aktiven Timer ausgeschaltet werden können. Sonst könnte es passieren, dass die Pumpe eingeschaltet ist (weil Timer und Trigger aktiv waren). Beim Ausschalten der Timer evt. jedoch nicht mehr aktiv ist und somit die Pumpe einfach weiterlaufen würde.

Um dies zu verhindern wird der Ausschalttrigger einfach auf den priorisierten Eingang des Flip-Flops gelegt, welches somit auch ohne aktiven Timer den Ausgang deaktiviert.

Das korrekte Regelverhalten lässt sich dann schön anhand eines Diagramms nachvollziehen:

![http://hap.googlecode.com/svn/wiki/images/Zirkulation-Diagramm.png](http://hap.googlecode.com/svn/wiki/images/Zirkulation-Diagramm.png)