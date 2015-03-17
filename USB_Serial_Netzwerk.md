# USB/Serial über Netzwerk (Anbindung Server-CU) #

In der Regel ist die Server-CU direkt über eine Serielle- oder USB-Verbindung an den Server gekoppelt.

In manchen Konstellation ist dies jedoch nicht möglich. Für diese Fälle unterstützt der HAP-Messageprocessor  (ab 0.9.32) auch eine Anbindung der Server-CU via eines Netzwerk-Sockets.

Wie sich der HAP-Messageprocessor mit der Server-CU verbindet, wird über die Konfigurationsdatei hap.yml im Verzeichnis /opt/hap/etc festgelegt.

Entfernen Sie die entsprechenden Kommentarzeichen (#) vor der gewünschten Verbindungsart und fügen Sie die Kommentarzeichen vor der nicht erwünschten Verbindung ein.
```
ServerCUConnection:                                                  
  Type: 'Network'                                                  
  Host: 192.168.165.1                                                
  Port: 4567                                                         
#ServerCUConnection:                                                  
#  Type: 'Serial'                                                   
#  Ports: [ '/dev/ttyUSB0', '/dev/ttyUSB1' ]
```
In obigen Fall erfolgt die Verbindung zur Server-CU über die IP-Adresse **192.168.165.1** und dem Port **4567**.


Damit die geschilderte Konstellation auch funktioniert, muss die Server-CU natürlich auch über das Netzwerk erreichbar sein.

So könnte die Server-CU direkt mit einem XPort gekoppelt sein, oder eine entfernte Maschine übernimmt die Umsetung von Serial/USB zu TCP/UDP.

Für Linux könnte so ein Dienst wie folgt aussehen:
```
#!/bin/bash                                                         
serialPorts="/dev/ttyUSB0 /dev/ttyUSB1"                            
while (true); do                                                    
  for port in $serialPorts; do                                      
    echo "" > $port 2> /dev/null                                    
    if [ $? == "0" ]; then                                         
      socat TCP-LISTEN:4567 $port,raw,b19200 2> /dev/null fi
  done                                                             
  sleep 1;                                                          
done
```
Im obigen Script wird versucht eine Verbindung auf den USB-Ports **/dev/ttyUSB0** und **/dev/ttyUSB1** aufzubauen (der FTDI-Treiber ändert gerne mal seine Ports...). Ist dies erfolgreich, so erfolgt die eigentliche Umsetzung mit Hilfe von socat.