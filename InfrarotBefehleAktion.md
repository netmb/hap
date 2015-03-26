Über den Eintrag "Remote Control Mapping" lassen sie die gelernten IR-Tasten einer Aktion zuordnen.
Als Aktionsziele stehen entweder Geräte im HAP-Kontext, Makros, oder Abstrakte-Module (Rollladen) zur Verfügung.

Die Tasten 0 bis 9 sind hierbei den Makros (Hotkeys) vorbehalten, während alle zweistelligen Tastenkombinationen von 10 bis 99 entweder einem Gerät oder einem Abstrakten-Modul zugeordnet werden können.
Ein Beispiel:

![http://hap.googlecode.com/svn/wiki/images/RemoteControlMapping.png](http://hap.googlecode.com/svn/wiki/images/RemoteControlMapping.png)

Die hier gezeigte Zuordnung sorgt dafür, dass wenn nun die Tasten **"1 0 Enter"** auf der Fernbedienung eingeben werden, die Deckenbeleuchtung im Flur ein/ausgeschaltet wird. Ist das Ziel eine Dimmerstufe so kann z.B. über **"1 0 0 3 0 Enter"** die Helligkeit auf 30% geregelt werden. Gleiches erreicht man über **"1 0 3 Enter"** (die Kurzform).
Folgendes Beispiel sorgt dafür, dass bei **"1 Enter"** das Makro-Script "SwitchOnDevice" ausgeführt wird:

![http://hap.googlecode.com/svn/wiki/images/RemoteControlMapping1.png](http://hap.googlecode.com/svn/wiki/images/RemoteControlMapping1.png)

Als dritte Möglichkeit lassen sich auch Makros über Ihre eindeutige Makro-Nummer (1 bis 65535) direkt starten. Hierzu ist auf der Fernbedienung folgendes einzugeben: **"Makro 4711 Enter"**. In diesem Fall wird das Makro-Script mit der Makro-Nummer 4711 ausgeführt.
Makros und Ihre entsprechenden eindeutigen Nummern lassen sich im Menü unter "Manage" => "Manage Macros" anlegen:

![http://hap.googlecode.com/svn/wiki/images/MakroEditor.png](http://hap.googlecode.com/svn/wiki/images/MakroEditor.png)