Diese Anleitung soll die ersten Schritten vereinfachen.

**Vorraussetzungen zur Nutzung:**

  * Windows PC mit AVR-Studio & WinAVR
  * Ubuntu Desktop oder Server mit HAP installiert
  * 1-2 aufgebaute Controller-Units (CU)
  * Hterm (Terminalsoftware) für Linux/Windows
  * USB oder RS232 Interface zur CU

## 1.  Installation von Ubuntu 12.04 ##

In der Konsole mit sudo (siehe Installation im Detail):
```
sudo ./setup.sh
```

Nach der erfolgreichen Installation der HAPConfig sollte man vor dem Start noch definieren, wie die Kommunikation zwischen HAP-Server und den CU's erfolgen soll. Dazu muss die folgende Datei editiert werden:
```
cd /opt/hap/etc/
sudo gedit hap.yml
```
Sofern noch keine CU's vorhanden sind einfach die eigene Rechner IP verwenden, damit der Server ohne Fehler starten kann.
```
ServerCUConnection:
Type: 'Network'
	Host: 192.xxx.xxx.xxx 
Port: 4567
#ServerCUConnection:
#  Type: 'Serial'
#  Ports: [ '/dev/ttyUSB1' ]
```
Sofern CU's schon vorhanden sind kann man die Schnittstelle eintragen
```
#ServerCUConnection:
	#  Type: 'Network'
#  Host: 192.xxx.xxx.xxx 
#  Port: 4567
ServerCUConnection:
Type: 'Serial'
Ports: [ '/dev/ttyUSB1' ]    # hier die benutzte Schnittstelle eintragen!
```
Danach sollte der Start möglich sein. Dazu HAP neustarten via:
```
cd /etc/init.d
sudo ./hap-mp restart
sudo ./hap-configserver restart
```
Danach klappt der LOGIN via
```
HAPConfig :   http://192.xxx.xxx.xxx :8090
HAP-GUI    :  http://192.xxx.xxx.xxx :8090/GUI
```

  * User: hap
  * Password: password

## 2. Erstellung der Firmware (CU) ##

Vorab sollte man im HAPConfig über Tools->DownloadBootlader einen Bootloader pro CU exportieren, um diesen dann auf die CU zu flashen. Dies muss für jede CU einzeln erfolgen um eine eindeutige UID zu haben.

Die UID (6 Zeichen) selber steht im Bootloader bzw. im Namen:

HAPBootLoader-0F2C07.hex

Das direkte Importieren des Projekts klappte bei mir leider nicht in AVR, daher halfen folgende Schritte:

1. Erstellen eines neuen Projekts in AVR (MEGA32)

2. import **.h &**.c & Makefile

3. Anpassung der mv.h

Die Mindestanforderungen könnt ihr im Wiki finden. Hier meine Einstellungen für alle Controller-Units zum ersten Testen:
```
#define COHAES                    // EEPROM-Support                  (Bit  0 -  0)
// #define COHAER                // Externer Reset                      (Bit  1 -  1)
#define COHABZ                   // Buzzer                                 (Bit  2 -  2)
#define COHAFM                   // Funkmodul                            (Bit  3 -  3)
#define COHACB                   // CAN-Bus                               (Bit  4 -  4)
// #define COHAIR                // Infrarotschnittstelle                (Bit  5 -  5)
// #define COHALCD 2           // siehe oben                            (Bit  6 -  7)
 #define COHALI                   // Logischer Eingang                  (Bit  8 -  8)
 #define COHAAI                   // Analoger Eingang                   (Bit  9 -  9)
 #define COHADIDS1820       // Dallas Digitales Thermometer  (Bit 10 - 10)
 #define COHASW                 // Geschalteter Ausgang             (Bit 11 - 11)
 #define COHADM                 // Gedimmter Ausgang               (Bit 12 - 12)
// #define COHARS               // Rollladensteuerung                 (Bit 13 - 13)
// #define COHADG 2            // siehe oben                             (Bit 14 - 15)
// #define COHAGUI             // Bedienoberfl‰che                  (Bit 16 - 16)
 #define COHAAS                 // Autonome Steuerung               (Bit 17 - 17)
```
  * AN muss deaktiviert werden, wenn ihr nur 1 x CU habt! (COHACB)!

4. Kompilierung der Firmware in AVR-Studio

5. Fußes des Atmen setzen siehe WIKI
(SPIEN, BOOTSZ=1024, BODLEVEL=4V, BODEN, Ext HF 1k+ 4ms)

6. CHIP ERASE

7. Programmierung des Bootloaders aus der HAPConfig

8. Danach Programmierung der kompilierten Firmware _ohne Chip-Erase_ (sonst ist der Bootloader wieder weg)

9. Öffnen von Hterm mit 19200baud & Zeichen Dezimal

10. Nach dem Anschalten der CU sollte das Modul einen Zeitrequest senden und in HTerm erscheinen

```
	Hterm: 	0 0 255 123 0 0 0 0     ( 0 = 000 in HTerm)
```


## 3. Moduleinrichtung im Terminal ##

Jede CU-Platine hat eine Moduladresse bzw. eine UID. Die UID selber wird beim exportieren des Bootloaders aus der HAPConfig erstellt und muss für jede Platine einzeln generiert werden. Die Moduladresse ist jedoch frei wählbar von 0-239 und jede CU sollte eine eigene pro VLAN haben.
Die UID selber muss man dann neben der Programmierung durch den Bootloader auch noch einmal für jedes Modul (CU-Platine) in die HAPConfig per Hand eintragen werden. Ebenso muss man die selbst zugewiesene Moduladresse eintragen.

Um HTERM unter Ubuntu (wo auch HAP installiert ist) zu nutzen muss HAP in der Konsole erst gestoppt werden, damit die Schnittstelle frei ist:
```
cd /etc/init.d/
sudo ./hap-mp stop
sudo ./hap-configserver stop
```
Starten kann man HAP im Anschluss nach der Nutzung von Hterm wieder mit:
```
cd /etc/init.d/
sudo ./hap-mp start
sudo ./hap-configserver start
```
Hier ein Bespiel für eine Basiseinrichtung einer CU nach dem flashen der kompilierten Firmware (neue Platine, Moduladresse =0):

Dieses kann man direkt in Hterm mit Type (DEC) eingeben und die CU sollte jeweils ein Feedback geben.

Das Protokoll ist :
```
	VLAN  SOURCE  DESTINATION  MTYPE  DEVICE  V0  V1   V2
```
> xxx = neue Werte
```
Moduladresse setzen (ab hier Modul)      0 0     0    76   5   xxx  0   0
CCU-Adresse einrichten			0 0 Modul 76   6   xxx  0   0
Bridge-Mode (1=on , 0=off)			0 0 Modul 76  10  xxx   0   0
Startmodus      			                 0 0 Modul 76   4   217  0   0			
EE_Konfig speichern				0 0 Modul 76   8    0     0   0
Reset	(full) 						0 0 Modul 76   2    0     0   0
```

Der Startmodus, um die neue Konfiguration zu laden muss 217 sein. Brigdemode müssen die Platinen haben, die Daten durchleiten sollen (z.B. CU-EG) Die CCU-Moduladresse ist für alle CU in meinem Fall 99 siehe Kapitel 4.

Parallel ist es ebenfalls möglich mit Hilfe der UID & des MagicPaket die Moduladresse zu setzen, sofern man mehr als eine neue CU angeschlossen hat.

Übersicht der wichtigsten Befehle:

Moduladresse:
> VLAN SOURCE DESTINATION 76 5 Modul 0 0
Reset:
> VLAN SOURCE DESTINATION 76 2 0 0 0
CCU def.:
> VLAN SOURCE DESTINATION 76 6 CCU 0 0
EE\_save:
> VLAN SOURCE DESTINATION 76 8 0 0 0
EE\_load\_Startmodus:
> VLAN SOURCE DESTINATION 76 4 217 0 0
SW\_Version:
> VLAN SOURCE DESTINATION 76 28 0 0 0


## 4. Moduleinrichtung im HAPConfig ##

Im folgenden soll nur das Prinzip gezeigt werden. VLAN ist dabei immer 0.

CCU      :     Server-HAP      		:  UID = 00 00 00  , Moduladresse=99
CU-EG   :    CU-Erdgeschoss   	:  UID = 0F 22 E5  , Moduladresse=100
OG        :     CU-1.Obergeschoss    :  UID = 0F 2C 07  , Moduladresse=101

> CCU  →SERIELL→   CU-EG  →CAN→  OG

Wie bereits beschrieben ist die UID=00 00 00 für die CCU. Die CCU ist virtuell und damit nur die Verbindung GUI

&lt;-&gt;

 CU. Die Schnittstelle von PC zu den restlichen Units bildet eine CU (CU-EG). Alle weiteren CU's im CAN haben kein Häkchen bei CCU oder CU unter Server-Settings.

HAPConfig benötigt zum programmieren ebenfalls noch die unveränderte Firmware von der Homepage als zip. Diese muss man zuvor noch mit Tools – File Upload einbinden.

# CCU Beispiel #
![http://hap.googlecode.com/svn/wiki/images/Beispiel-CCU.png](http://hap.googlecode.com/svn/wiki/images/Beispiel-CCU.png)

# CU-EG Beispiel #
![http://hap.googlecode.com/svn/wiki/images/Beispiel-CU-EG.png](http://hap.googlecode.com/svn/wiki/images/Beispiel-CU-EG.png)

# CU-OG Beispiel #
![http://hap.googlecode.com/svn/wiki/images/Beispiel-OG.png](http://hap.googlecode.com/svn/wiki/images/Beispiel-OG.png)