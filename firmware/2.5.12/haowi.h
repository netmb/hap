////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                OWI (One-wire Interface)                             //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          10.08.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  10.08.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAOWI
#define HAOWI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void OWIInit(tByte pPins);
tByte OWIDetectPresence(tByte pPins);
void OWISendByte(tByte pData, tByte pPins);
tByte OWIReceiveByte(tByte pPin);
void OWISkipROM(tByte pPins);


#endif
