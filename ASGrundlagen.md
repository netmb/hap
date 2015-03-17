## Wie funktioniert die Autonome Steuerung? ##

Die Firmware der Control-Unit durchläuft alle 10ms eine Schleife, in der alle AS-Objekte nach einer definierten Reihenfolge durchlaufen werden und anhand der Eingangswerte die jeweiligen Ausgangswerte berechnet werden.

Wird z.B. ein Taster betätigt und dieser Wert innerhalb einer AS-Sequenz mit einem "Input-passive"-Objekt verwertet, so ist in einem Durchlauf der AS-Sequenz der Wert dieses Eingangs z.B. 132 und im nächsten Durchlauf (10ms später) wieder 0.

Eine AS-Sequenz wird also nicht (!) nur bei einem Ereignis "angestossen", sondern wird permanent durchlaufen.

## Wie wird die Reihenfolge der AS-Objekte definiert? ##

Die Reihenfolge der AS-Objekte innerhalb einer Sequenz wird durch die Position der Objekte auf der X-Achse bestimmt. Je größer also die X-Position des Objektes ist, desto weiter "hinten" wird das Objekt in der Sequenz berechnet.

Wenn Sie eine Sequenz in der Config-GUI designen, fangen sie also links mit einem Eingang an und hören rechts mit dem Ausgang auf.

## Was passiert wenn der zentrale Server (CCU) nicht mehr erreichbar ist? ##

Gar nichts. Die jeweiligen AS-Sequenzen laufen völlig autonom auf den jeweiligen Control-Units.

## Wie viele Sequenzen können pro Control-Unit angelegt werden? ##

Nicht die Anzahl der Sequenzen ist maßgebend, sondern die Anzahl der Objekte. Im Auslieferungszustand können bis zu 63 AS-Objekte verwendet werden.