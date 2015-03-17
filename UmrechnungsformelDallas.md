Folgende Formel im "Formula"-Feld beim Digitalen-Eingang für den Dallas DS18S20 eintragen:
```
if (X >= 2048) { return((~X+1 & 65535)*-0.0625); } else { return (X*0.0625);}
```

Wenn Bit 11 (2048) gesetzt ist, dann handelt es sich um negative Werte. in diesem Fall wird ein 2er-Kompliment vom Ausgangswert  gebildet und auf einen 16-Bit-Wert gekürzt ( & 65535). Jedes gesetze Bit entspricht 0.0625.

Wird auf der GUI die Darstellung der Temperatur in 0,1°-Schritten gewünscht, so kann folgende, erweiterte Formel eingesetzt werden:
```
if (X >= 2048) { return(int((~X+1 & 65535)*-0.625-0.5)/10); } else { return (int(X*0.625+0.5)/10);}
```