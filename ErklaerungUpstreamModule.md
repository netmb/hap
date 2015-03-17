Mit folgenden drei Bildern lässt sich die Upstream-Thematik recht gut erklären.

"Target-Module" steht jeweils für das Ziel-Modul, auf welches die neue Konfiguration eingespielt werden soll.

Das jeweilige Upstream-Module ist immer das nächstliegende Modul, welches als Bridge konfiguriert wurde.

Upstream-Inteface ist immer die Schnittstelle, mit der die Ziel-CU an das Bridge-Modul angebunden ist.

![http://hap.googlecode.com/svn/wiki/images/Upstream01.png](http://hap.googlecode.com/svn/wiki/images/Upstream01.png)
![http://hap.googlecode.com/svn/wiki/images/Upstream02.png](http://hap.googlecode.com/svn/wiki/images/Upstream02.png)
![http://hap.googlecode.com/svn/wiki/images/Upstream03.png](http://hap.googlecode.com/svn/wiki/images/Upstream03.png)

Einen Spezialfall bildet die Server-CU in folgender Abbildung. Hier muss als Upstream-Module der Server konfiguriert werden und als Upstream-Interface "Serial" ausgewählt werden.

![http://hap.googlecode.com/svn/wiki/images/Upstream04.png](http://hap.googlecode.com/svn/wiki/images/Upstream04.png)