# Auf-/Ab-Taster steuert Rollladen #

## Ist ##

Ein Auf-/Ab-Wandeinbau-Taster sowie ein Rollladen-Rohrmotor an einer HAP-Relais-Stufe.

## Soll ##

Beim kurzen Drücken auf die Ab-Taste soll der Rollladen vollständen herab fahren. Entsprechend soll der Rollladen bei kurzem Drücken der Auf-Taste vollständig nach oben fahren. Ein erneutes kurzes Drücken während der Fahrt soll die Fahrt sofort stoppen. Welche Taste hierbei gedrückt wird, spielt keine Rolle.

## Lösung ##

![http://hap.googlecode.com/svn/wiki/images/ASRolllo.png](http://hap.googlecode.com/svn/wiki/images/ASRolllo.png)

#### Die jeweiligen Taster sind als Logische-Eingänge mit folgenden Eigenschaften konfiguriert: ####

  * Falling Edge
  * Short Activation
  * Activate Pullup
  * Force Debounce

#### Der Rollladen Ausgang ist als Abstraktes Modul "Shutter" konfiguriert. Die beiden zum "Shutter" assoziierten "Devices" sind normale "Switche": ####

![http://hap.googlecode.com/svn/wiki/images/Rollladen.png](http://hap.googlecode.com/svn/wiki/images/Rollladen.png)