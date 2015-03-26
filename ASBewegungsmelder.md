# Bewegungsmelder schaltet Ausgang mit Zeitverzögerung #

## Ist ##

Ein Bewegungsmelder sowie eine Halogen-Lampe an einer HAP-Solid-State-Relaisstufe

## Soll ##

Beim Signal des Bewegungsmelders soll die Lampe sofort angehen. Wird keine Bewegung mehr detektiert wird die Lampe nach 30 Sekunden ausgeschaltet.

## Lösung ##
#### Bewegungsmelder mit Schließerkontakt: ####

http://hap.googlecode.com/svn/wiki/images/AC-Bewegungsmelder_NO.JPG

#### Bewegungsmelder mit Öffnerkontakt: ####

http://hap.googlecode.com/svn/wiki/images/AC-Bewegungsmelder.JPG

#### Der Bewegungsmelder ist als Logischer-Eingang mit folgenden Eigenschaften konfiguriert: ####

  * Rising Edge
  * Falling Edge
  * Activate Pullup
  * Disable Bouncing