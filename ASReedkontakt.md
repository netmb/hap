# Reedkontakt schaltet Ausgang #

## Ist ##

Reed-Kontakt an einem Türrahmen montiert. Lampe an einer HAP-Dimmerstufe

## Soll ##

Beim Öffnen der Tür soll umgehend die Lampe in diesem Raum angehen. Beim Schliessen der Tür soll die Lampe wieder ausgehen.

## Lösung ##

![http://hap.googlecode.com/svn/wiki/images/ASReadKontakt.png](http://hap.googlecode.com/svn/wiki/images/ASReadKontakt.png)

#### Der Reed-Kontakt ist als Logischer-Eingang mit folgenden Eigenschaften konfiguriert: ####

  * Rising Edge
  * Falling Edge
  * Activate Pullup
  * Disable Bouncing
  * Force Debounce
