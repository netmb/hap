////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Rollladensteuerung                                   //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          11.01.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  11.01.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HARS
#define HARS


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void RSInit(void);
void RSSetValue(tByte pX, tByte pValue);
void RSControlInvert(tByte pX);
void RSControlUp(tByte pX);
void RSControlDown(tByte pX);
void RSControlStop(tByte pX);
void RSControlStart(tByte pX);
inline tByte RSGetValue(tByte pX);
inline void RSCounterInc(void);
void RSControl(void);
inline void RSDestroy(void);


#endif
