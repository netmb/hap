////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Dimmer                                               //
// Version:              2.2 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  23.01.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HADM
#define HADM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline void DMSetControlDelay(tByte pDelay);
inline void DMSetZD(tWord pDelay);
void DMInit(void);
void DMSetValue(tByte pX, tByte pPHW, tWord pDelay);
tByte DMIncValue(tByte pX);
tByte DMDecValue(tByte pX);
void DMControlInvert(tByte pX);
void DMControlUp(tByte pX);
void DMControlDown(tByte pX);
void DMControlStop(tByte pX);
void DMControlStart(tByte pX);
tByte DMGetValue(tByte pX);
void DMRegulate(void);
inline void DMSynch(void);
inline void DMDestroy(void);


#endif
