Ab der SVN-Version >= 64 ist der Scheduler um ein Datenbank-Cleanup-Script ergänzt worden.
Hintergrund:

Die Log- und Status-Tabelle füllen sich relativ schnell, so dass ein löschen von Einträgen, welche älter als X-Tage sind, sinnvoll ist.

Der folgende Screenshot zeigt wie das Script im Scheduler verwendet werden kann. In diesem Beispiel erfolgt wöchentlich um 22:00 ein Datenbank-Cleanup von Log-Einträgen, welche älter als 2 Tage sind und von Status-EInträgen, welche älter als 90 Tage sind.

Das Script kann natürlich auch von der Kommando-Zeile verwendet werden.

![http://hap.googlecode.com/svn/wiki/images/Hap-dbcleanup.png](http://hap.googlecode.com/svn/wiki/images/Hap-dbcleanup.png)