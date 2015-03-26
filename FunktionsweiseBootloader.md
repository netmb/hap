# Funktionsweise des Bootloaders #

Vorab ein paar grundsätzliche Aussagen:

  * Der Bootloader sorgt einzig dafür, dass nach einem Firmware-Transfer die neue Firmware aus dem externen EEProm der Control-Unit in den Flash-Speicher des Atmel-Controllers geschrieben wird.

  * Der Bootloader alleine interagiert nicht mit dem HAP-System und kann auch nicht über Funk bzw. CAN angesprochen werden.

  * Der Bootloader weiss nichts von seiner eindeutigen ID und der Bootloader kann auch nicht über diese ID angesprochen werden.


## Funktionsweise eines Firmware-Transfers via CAN/Funk (über die Web-GUI) ##

Die aktuelle Firmware auf der Ziel-CU empfängt die Firmware-Datei über den CAN-Bus/Funk und transferiert diese in das externe EEProm. Nach Beendigung des Transfers wird ein Flag in der CU gesetzt. Anschliessend wird die CU neu gestartet.

Der Bootloader sieht anhand des gesetzten Flags, dass eine neue Firmware-Version vorliegt und transferiert nun die Firmware-Daten aus dem externen EEProm in den Flash-Speicher des Atmel-Controllers.
Nach Fertigstellung startet die CU mit der neuen Firmware.

Somit erklärt sich auch, dass bei Erstinbetriebnahme einer CU vorab der Bootloader UND eine Firmware aufgespielt werden müssen (die Hauptarbeit des Firmware-Flash-Vorgangs über CAN/Funk wird ja von der laufenden Firmware übernommen...)

## Funktionsweise der eindeutigen ID (UID), welche die CU über den Bootloader "erhält" ##

Der Bootloader selber, kann nichts mit der UID anfangen. In der Bootloader-Datei (welche über die Web-GUI herunter geladen werden kann) wird lediglich eine eindeutige ID in Form von 3 Bytes an einer bestimmten Adresse einkodiert. Die laufende Firmware (!) greift dann auf diese spezielle Speicheradresse zu und kann die UID auslesen. Die UID wird demnach nur in dem Bereich wo auch der Bootloader liegt, hinterlegt, so dass er nicht bei einem Firmware-Transfer überschrieben wird.

Mit anderen Worten:
Wird eine Bootloader-Datei herunter geladen, wird an die eigentliche Bootloader-Datei eine UID "angehängt", so dass die UID in einem Speicherbereich vorgehalten wird, der nicht überschrieben wird...