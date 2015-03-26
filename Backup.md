# Erstellung eines Backup #

## 1. Erstellung des Backup ##
<br>Die Sicherung der mysql-Datenbank erfolgt mit mysqldumb, wobei hap.sql die Zieldatei ist:<br>
<pre><code>sudo mysqldump --databases hap -u root -p &gt; hap.sql<br>
</code></pre>
Sofern noch die hochgeladenen Bilder gesichert werden sollen, können diese so auf einem Datenträger gespeichert werden.<br>
<pre><code>sudo cp /opt/hap/var/static/images/*.* /media/.../images<br>
</code></pre>
<h2>2. Re-Import eines Backup</h2>
Die gesicherte Datei hap.sql kann so mit mysql wieder auf dem neuen System importiert werden.<br>
<pre><code> mysql &lt; hap.sql -u root -p<br>
</code></pre>
Die gespeicherten Bilder können über die HAP-Oberfläche oder so direkt importiert werden.<br>
<pre><code>sudo cp /media/.../images/*.* /opt/hap/var/static/images/<br>
sudo chown -R hap:hap /opt/hap <br>
</code></pre>

Browser Cache solle noch geleert werden, um alle Neuerungen in Bildern korrekt darzustellen.