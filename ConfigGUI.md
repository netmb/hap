# Config-GUI #

Über die Config-GUI wird das gesamte HAP-System konfiguriert. Hier werden also Control-Units, Geräte (Switche, Dimmer), Analoge Eingänge, Digitale Eingänge usw. angelegt und parametriert. Zudem wird hier die Web-GUI mit simplem drag&drop konfiguriert. Die Oberfläche ist Multi-User und Multi-Config fähig und läuft vollständig im Browser.

Die nachfolgenden Bilder und Videos (hohe Auflösung wählen) geben einen groben Überblick über den Funktionsumfang.

<a href='http://www.youtube.com/watch?feature=player_embedded&v=OOx_1fLpYV8' target='_blank'><img src='http://img.youtube.com/vi/OOx_1fLpYV8/0.jpg' width='720' height=500 /></a>
<a href='http://www.youtube.com/watch?feature=player_embedded&v=wIt4vWM1NIo' target='_blank'><img src='http://img.youtube.com/vi/wIt4vWM1NIo/0.jpg' width='720' height=500 /></a>


Etwas zur Technik:

Die Applikation besteht aus einer Frontend und Backend-Komponente. Die Frontend-Komponente (also das, was man im Browser sieht) ist vollständig in Javascript geschrieben und verwendet das ExtJS-Framework. Die Backend-Komponente basiert auf dem Perl-MVC-Framework Catalyst. Die Kommunikation zwischen Frontend und Backend erfolgt über AJAX. Als Datenformat wird JSON verwendet.

![http://hap.googlecode.com/svn/wiki/images/gui-module.png](http://hap.googlecode.com/svn/wiki/images/gui-module.png)
![http://hap.googlecode.com/svn/wiki/images/gui-as.png](http://hap.googlecode.com/svn/wiki/images/gui-as.png)