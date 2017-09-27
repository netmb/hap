////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Drehgeber STEC                                       //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.02.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  20.02.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HADGSTEC
#define HADGSTEC


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void DGInit(void);
void DGSpeedDec(void);
void DGProcessEvent(tByte pModul, tByte pDevice, tByte pEvent);
inline void DGDestroy(void);


#endif
