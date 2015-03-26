Will man einen Bewegungsmelder ohne Lastteil an einer HAP-CU betreiben, bietet sich der System-Sensor 180 WS180WW von Jung an.

Die Versorgungsspannung beträgt 12V bei einem Stromverbrauch von ca. 2 mA .  Der Ausgang ist als Open-Collector ausgelegt, allerdings in Reihenschaltung mit einer LED zur Signalisierung des Schaltvorgangs.

Überbrückt man diese auf der Anschlussplatine kann der Melder wie eine Reedkontakt in der CU konfiguriert werden.

> Wahrscheinlich lässt sich auch der Helligkeitssensor mit einem A/D-Eingang abfragen. Die genaue Beschaltung muss aber noch geklärt werden.

Anschlussbelegung des Klemmblocks:
```
+   12V 
-   GND 
S   Schaltausgang 
LX  Helligkeitssensor 
```

![http://hap.googlecode.com/svn/wiki/images/Jung_BW.jpg](http://hap.googlecode.com/svn/wiki/images/Jung_BW.jpg)
![http://hap.googlecode.com/svn/wiki/images/Platine.jpg](http://hap.googlecode.com/svn/wiki/images/Platine.jpg)