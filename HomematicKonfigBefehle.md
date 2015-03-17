#Homematic Konfig-Befehle

# Befehlsübersicht #

Nachfolgend aufgeführte Befehl können direkt via telnet an den Message-Processor abgesetzt werden (telnet localhost 7891):

  * hmpair
> > Hiermit können neue Geräte an den HMLAN-Adapter angelernt werden.
> > Hierzu ist der Befehl abzusetzen und anschliessend das entsprechende Gerät in den Config-Modus zu bringen (grünes blinken, welches dann schneller grün blinkt).

  * hmdevice 123456 channel 1 devicepair ABCDEF channel 1
> > Der Kanal 1 der Homematic-Komponente mit der 6-stelligen ID 123456 soll mit dem Kanal 1 der Komponente ABCDEF gepairt werden.
> > ABCDEF ist hierbei ein virtuelles Device, welches nichts anderes tut, als ACK-Befehle an den Sender zu schicken, so dass dieser den Empfang der von ihm gesendeten Nachricht bestätigt bekommt und somit die  Status-LED auch grün wird.

  * hmdevice 123456 factoryreset
> > Die Komponente mit der 6-stellingen ID 123456 wird in den Werkzustand zurückgesetzt.

  * hmdevice 123456 unpair
> > Die Komponente mit der 6-stellingen ID 123456 wird vom HMLAN-Adapter abgelernt.

