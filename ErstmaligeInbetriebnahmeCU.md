Wenn eine neue Control-Unit (CU) in das HAP-System eingebunden werden soll, so sind hier einige Besonderheiten zu beachten:

Die neue CU muss einmalig mit einem Bootloader und einer Firmware (!) geflasht werden (mittels eines externen Programmers). Der Bootloader sollte hierbei unbedingt über die Web-GUI heruntergeladen werden, da hier in den Bootloader eine eindeutige ID kodiert wird.

Siehe auch: Funktionsweise des Bootloaders

Danach muss eine Firmware eingespielt werden, welche mindestens folgende Compile-Options aktiviert hat:
  * EEProm-Support
  * CAN-Bus
  * Funkmodul
  * Buzzer

Ist keine Funkanbindung geplant, kann natürlich die Funk-Komponente weg gelassen werden. Gleiches gilt für die CAN-Komponente.

ACHTUNG: Handelt es sich um die Server-CU so ist in jedem Fall das Funk-Modul zu aktivieren.

Diese Optionen können in der mv.h-Datei im jeweiligen Firmware-Archiv geändert werden.

Die folgende Darstellung zeigt die richtigen Einstellungen in der mv.h:
```
#define COHAES                // EEPROM-Support                    (Bit  0 -  0)
//#define COHAER                // Externer Reset                    (Bit  1 -  1)
#define COHABZ                // Buzzer                            (Bit  2 -  2)
#define COHAFM                // Funkmodul                         (Bit  3 -  3)
#define COHACB                // CAN-Bus                           (Bit  4 -  4)
//#define COHAIR                // Infrarotschnittstelle             (Bit  5 -  5)
//#define COHALCD 2             // siehe oben                        (Bit  6 -  7)
//#define COHALI                // Logischer Eingang                 (Bit  8 -  8)
//#define COHAAI                // Analoger Eingang                  (Bit  9 -  9)
//#define COHADIDS1820          // Dallas Digitales Thermometer      (Bit 10 - 10)
//#define COHASW                // Geschalteter Ausgang              (Bit 11 - 11)
//#define COHADM                // Gedimmter Ausgang                 (Bit 12 - 12)
//#define COHARS                // Rollladensteuerung                (Bit 13 - 13)
//#define COHADG 2              // siehe oben                        (Bit 14 - 15)
//#define COHAGUI               // Bedienoberfl‰che                  (Bit 16 - 16)
//#define COHAAS                // Autonome Steuerung                (Bit 17 - 17)
```

Bei Bedarf können natürlich auch weitere Komponenten aktiviert werden. Es ist jedoch zu beachten, dass nicht alle Komponenten aktiviert werden können, da hierfür der Speicher der CU nicht ausreicht.

Später werden o.g. Einstellungen über die Web-Oberfläche modifiziert.

Sind die o.g. Einstellungen getätigt, so muss die Firmware kompiliert werden und auf die CU transferiert werden.

**WICHTIG**:

Unbedingt darauf achten, dass beim Einspielen der Firmware die Einstellung "Clear-Device" im Programmier-Tool deaktiviert ist, da sonst der zuvor eingespielte Bootloader wieder gelöscht wird. Bietet das eingesetzte Programmier-Tool keine solche Einstellung (wie z.B. PonyProg), so ist wie unter Flashen mit PonyProg vorzugehen

Nach dem Flash-Vorgang kann die neue CU in das HAP-System eingebunden (physikalisch einbinden und in der Web-GUI anlegen).

**ANMERKUNG**:

Wenn die CU-Firmware einen Release-Status erreicht hat, wird eine vorgefertigte Firmware auch über die Web-GUI zu beziehen sein, so dass die Modifikation der mv.h mit dem anschliessenden Compile-Vorgang entfällt.