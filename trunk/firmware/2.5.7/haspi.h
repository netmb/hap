////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                SPI (Serial Peripheral Interface)                    //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt ge�ndert am:  03.02.2006                                           //
// Zuletzt ge�ndert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HASPI
#define HASPI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline void SPISetSSHigh(void);
inline void SPISetSSLow(void);
void SPIInit(void);
tByte SPIRead(void);
void SPIWrite(tByte pC);


#endif
