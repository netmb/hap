# Introduction #

Ziel ist es die Raspberry-PI CAM in HAP zu integrieren via MJPG stream-server.

# Details #

1. Installation mjpg-streamer - siehe  http://wiki.ubuntuusers.de/MJPG-Streamer

2. Installation PI CAM - siehe  http://www.raspberrypi.org/camera

3. Erstellung in /etc/init.d der Datei mjpg\_stream

4. sudo chmod 0775 mjpg\_stream

Im Beispiel-Skript anzupassen:
  1. /mnt/vmtmpfs ist der Pfad, wo das Bild abgelegt wird. Hier Nutzung einer Ramdisc (zu empfehlen um die SD zu schonen!)
  1. /home/pi/mjpeg/mjpg-streamer-code-182/mjpg-streamer/mjpg\_streamer ersetzen durch das Verzeichnis, je nachdem wo mjpg-streamer installiert ist (Pfad ist notwendig beim Autostart!)

```
#!/bin/sh
# /etc/init.d/mjpg_stream

### BEGIN INIT INFO
# Provides:          mjpg_stream
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: MJPG - Stream
# Description:       MJPG - Stream
### END INIT INFO

start()
{
  echo "Start mjpg-stream"
  /usr/bin/raspistill --nopreview -w 640 -h 480  -ex auto -q 5 -o /mnt/vmtmpfs/pic.jpg -tl 100 -t 0 -th 0:0:0 &
  /home/pi/mjpeg/mjpg-streamer-code-182/mjpg-streamer/mjpg_streamer -i "/usr/local/lib/input_file.so -f /mnt/vmtmpfs -n pic.jpg -d 5" -o "/usr/local/lib/output_http.so -w /usr/local/www" &
}

stop()
{
  echo "Stop mjpg-stream"
  kill -9 $(pidof mjpg_streamer) >/dev/null 2>&1
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
   stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    ;;
esac

exit 0
```

Danach in den Autostart laden in /etc/init.d:

```
sudo update-rd.d mjpg-stream defaults
sudo reboot
```

Einbindung als Bild In der GUI via Container:

```
<img src="http://192.168.1.2:8080/?action=snapshot" width="640" height="480"/>
```

Bsp. zum anlegen einer RamDisc:
```
sudo apt-get install tmpfs
```

In der Datei/etc/fstab am Ende einfügen (size an Bildgrösse anpassen):
```
tmpfs /mnt/vmtmpfs tmpfs defaults,size=8M 0 0
```