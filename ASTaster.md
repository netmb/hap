# Taster schaltet Ausgang #



## Ist ##

Ein normaler Wand-Einbautaster sowie eine Hochvolt-Halogen-Lampe an einer HAP-Dimmerstufe


## Soll ##

Beim kurzen Drücken des Tasters soll die Lampe an bzw. aus gehen. Wird der Taster gedrückt gehalten, so soll der Dimmvorgang beginnen. Wird der Taster losgelassen und erneut lange gedrückt, so soll der Dimmvorgang in umgekehrter Richtung starten.


## Lösung ##

> ![http://hap.googlecode.com/svn/wiki/images/ASTaster.png](http://hap.googlecode.com/svn/wiki/images/ASTaster.png)

#### Der "Taster Flur" ist als Logischer-Eingang mit folgenden Eigenschaften konfiguriert: ####

  * Falling Edge
  * Short Activation
  * Activate Pullup
  * Force Debounce

#### Die "Logical-Input-Defaults" auf diesem Modul sind wie folgt konfiguriert: ####

  * Debounced: 10 (1/100s)
  * Short-Activation: 50 (1/100s)
  * Long-Activation: 150 (1/100s)