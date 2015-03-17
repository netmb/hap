Folgende Einstellungen sind nötig um ein LCD-Display mit HAP anzusteuern:

Diese Devices müssen angelegt und die der Hardware enstsprechenden Portpins zugewiesen werden.

LCD\_D0, LCD\_D1, LCD\_D2, LCD\_D3, LCD\_E, LCD\_RS, LCD\_RW, LCD\_Backlight (wenn vorhanden)

Für den Encoder sind noch drei Logical Inputs nötig:

LCD\_A, LCD\_B, LCD\_KNOB

IMHO ist noch ein Fehler in der GUI, wenn man bei der Konfiguration des Eingangs als Template "Rotary encoder Push Button" anwählt, wird bei den Options "Short Activation" vorbelegt.
Richtig ist aber "Long Activation".