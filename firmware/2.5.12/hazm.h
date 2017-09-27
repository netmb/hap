////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Zeit (Uhr)                                           //
// Version:              2.1 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  21.01.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAZM
#define HAZM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void ZMInit(void);
inline void ZMSetTime(tByte pDay, tByte pHour, tByte pMinute, tByte pSecond, tByte pHundredth);
inline tByte ZMGetDay(void);
inline tByte ZMGetHour(void);
inline tByte ZMGetMinute(void);
inline tByte ZMGetSecond(void);
inline tByte ZMGetHundredth(void);


#endif
