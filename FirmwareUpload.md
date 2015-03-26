Die Config-GUI wird ohne Firmware für die Control-Units geliefert.  Daher muss zunächst eine Firmware hochgeladen werden:

Entscheidend hierbei ist, dass die Namenskonvention für die Firmware-Datei eingehalten wird !:
```
ha-2-5-10-20090115.zip

2  = Major-Version
5  = Minor-Version
10 = Sub-Version
20090115 = 15.01.2009
```

Das Root-Verzeichnis des Zip-Files muss einen Order "ha25" enthalten, indem die Quelldateien vorgehalten werden.
Idealerweise verwendet man nur Firmware-Files welche über die HAP-Homepage bezogen wurden.