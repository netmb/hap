# Subversion #

Vorbereitungen:
```
apt-get install subversion
wget http://packages.netmb.net/PublicKey
apt-key add PublicKey
echo "deb http://packages.netmb.net/ubuntu ./" >> /etc/apt/sources.list
apt-get update
```
Notwendige Pakete installieren:
```
apt-get install perl mysql-server avr-libc gcc-avr binutils-avr make libcatalyst-perl libcatalyst-view-tt-perl libjson-xs-perl libpoe-perl libcatalyst-modules-extra-perl libcatalyst-modules-perl \
libimage-size-perl libarchive-zip-perl libset-crontab-perl libschedule-cron-perl libdevice-serialport-perl libparams-util-perl libcatalyst-plugin-authentication-store-dbic-perl libpoe-component-easydbi-perl libschedule-cron-events-perl
```
SVN checkout:
```
cd /opt
svn checkout http://hap.googlecode.com/svn/trunk/ hap-read-only
```
Datenbank anlegen:
```
mysql < /opt/hap/etc/hap.sql -u root -p
```
<br>
<h2>Detailanleitung für ein Upgrade eines bestehenden HAP unter Ubuntu 9.10 bzw. 10.04</h2>
Zunächst müssen alle HAP-Prozesse gestoppt werden (mp, configserver, scheduler)<br>
<pre><code>cd /etc/init.d<br>
sudo ./hap-mp stop<br>
sudo ./hap-configserver stop<br>
sudo ./hap-scheduler stop<br>
</code></pre>
Um die neue Version nutzen zu können muss Catalyst upgedated werden.<br>
<pre><code>sudo apt-get install build-essential<br>
sudo PERL_MM_USE_DEFAULT=1 cpan Catalyst::Runtime Catalyst::Devel<br>
</code></pre>
Danach erfolgt die Installation von Subversion und der notwendigen Perl-Bibliotheken.<br>
<pre><code>sudo apt-get install subversion<br>
sudo apt-get update<br>
sudo apt-get install perl mysql-server avr-libc gcc-avr binutils-avr make libcatalyst-perl libcatalyst-view-tt-perl libjson-xs-perl libpoe-perl libcatalyst-modules-extra-perl libcatalyst-modules-perl libimage-size-perl libarchive-zip-perl libset-crontab-perl libschedule-cron-perl libdevice-serialport-perl libparams-util-perl libcatalyst-plugin-authentication-store-dbic-perl libpoe-component-easydbi-perl libschedule-cron-events-perl<br>
</code></pre>
Das SVN checkout selber lädt das gesamte hap Verzeichniss runter, das anschließend über das bestehende <b>/opt/hap</b> geschrieben werden muss.<br>
<pre><code>cd /opt<br>
sudo svn checkout http://hap.googlecode.com/svn/trunk/ hap-read-only<br>
</code></pre>
Die heruntergeladenen Dateien müssen jetzt im Orignalverzeichnis überschrieben werden. Dabei bleiben die spezifischen Benutzerdaten wie Bilder, genutzte Firmware usw. unverändert.<br>
Variante 1 (wenn graphische Benutzeroberfläche zur Verfügung steht - z.B. Ubuntu-Desktop):<br>
<pre><code>sudo nautilus<br>
</code></pre>
<blockquote>-><b>hap-read-only</b> nach <b>/opt/hap</b> überschrieben</blockquote>

Variante 2 (wenn keine graphische Benutzeroberfläche zur Verfügung steht - z.B. Ubuntu-Server):<br>
<pre><code>cd hap-read-only<br>
sudo cp -rf * ../hap<br>
</code></pre>
Danach müssen die Rechte noch angepasst werden<br>
<pre><code>sudo chown -R hap:hap /opt/hap<br>
</code></pre>
und die Inhalte von <b>/opt/hab/etc/init.d</b> über die besteheneden Dateien in <b>/etc/init.d</b> geschrieben werden.<br>
<br>
Variante Ubuntu-Desktop:<br>
<pre><code>sudo nautilus <br>
</code></pre>
<blockquote>-> (3 Dateien) <b>/opt/hab/etc/init.d</b> Inhalt nach <b>/etc/init.d/</b></blockquote>

Variante Ubuntu-Server:<br>
<pre><code>cd /opt/hap/etc/init.d<br>
sudo cp -rf * /etc/init.d<br>
</code></pre>
Auch diese müssen noch die richtigen Rechte bekommen:<br>
<pre><code>sudo chown -R hap:hap /etc/init.d/hap-mp<br>
sudo chown -R hap:hap /etc/init.d/hap-scheduler<br>
sudo chown -R hap:hap /etc/init.d/hap-configserver<br>
</code></pre>
Danach erfolgt der Datenbankimport um die neuen Funktionen nutzen zu können. Dabei wird nicht die aktuelle Datenbank überschrieben. Lediglich das Password wird auf password zurückgesetzt und kann nach der Anmeldung wieder geändert werden.<br>
<pre><code>mysql &lt; /opt/hap/etc/hap.sql -u root -p<br>
</code></pre>
Nach dem Update müssen noch die Parameter in der hap.yml <a href='USB_Serial_Netzwerk.md'>Wiki Beschreibung Hap.yml</a> angepasst werden und HAP erneut gestartet werden.<br>
<pre><code>sudo ./hap-scheduler start<br>
sudo ./hap-configserver start<br>
sudo ./hap-mp start<br>
</code></pre>

Browser Cache solle noch geleert werden, um alle Neuerungen korrekt darzustellen.