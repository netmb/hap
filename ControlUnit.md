# Control Unit #

Die Control-Unit 3.0 (CU) stellt den integralen Bestandteil des HAP-Projektes dar. Auf der  CU sind folgende Kernkomponenten vorhanden:
  * ATMega32 @12MHz
  * MCP2515 (CAN-Controller)
  * PCA80C250 (CAN-Bus-Treiber)
  * CFT50 (Low-Drop-Spannungsregler, max. 500mA)
  * EEProm 24C256 (Firmware-Zwischenspeicher)
  * EEProm 24C64 (zusätzlicher Konfigurationsspeicher)

Die Maße wurde so gewählt (44mmx45mm), dass die CU problemlos in eine Standard-Unterputzdose passt.

![http://hap.googlecode.com/svn/wiki/images/cu3render.jpg](http://hap.googlecode.com/svn/wiki/images/cu3render.jpg)
![http://hap.googlecode.com/svn/wiki/images/cu-brd.png](http://hap.googlecode.com/svn/wiki/images/cu-brd.png)

Weiterhin wurde alle Anschlüsse auf Stiftleisten herausgeführt, so dass die CU auch in anderen Projekten einfach verwendet werden kann, indem sie auf eine Buchsenleiste aufgesteckt wird.

Für eine Hutschieneninstallation existiert eine Adapterplatine, welche alle Anschlüsse der CU auf Schraubklemmen herausführt.
Das Hutschienengehäuse ist ein 6TE-Standardgehäuse, welches problemlos über die bekannten Distributoren bezogen werden kann.

![http://hap.googlecode.com/svn/wiki/images/cu3offen.jpg](http://hap.googlecode.com/svn/wiki/images/cu3offen.jpg)
![http://hap.googlecode.com/svn/wiki/images/CUa.jpg](http://hap.googlecode.com/svn/wiki/images/CUa.jpg)

Alternativ gibt es dank Uwe Bleile nun auch eine "einsteigerfreundliche" Version, welche fast gänzlich ohne SMD-Bauteile auskommt und zudem auch noch einseitig ist, so dass man diese Version problemlos selber herstellen kann:


![http://hap.googlecode.com/svn/wiki/images/cudil-komplett.jpg](http://hap.googlecode.com/svn/wiki/images/cudil-komplett.jpg)
![http://hap.googlecode.com/svn/wiki/images/cudil-platine.jpg](http://hap.googlecode.com/svn/wiki/images/cudil-platine.jpg)