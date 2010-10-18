////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                SPI (Serial Peripheral Interface)                    //
// Version:              1.0 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  16.02.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Basis Module ////////////////////////////////////////////////////////////////

#include <avr/io.h>

#include <haspi.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tVPByte SPIPort;
tByte SPISS;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline void SPISetSSHigh(void) {
  *SPIPort |= (1 << SPISS);
}

inline void SPISetSSLow(void) {
  *SPIPort &= ~(1 << SPISS);
}

void SPIInit(void) {

  tByte Index;
  tByte N;
  
  N = KMMIInit(KMIOSPISS, KMIOSPISSMask);
  KMMIGetIOProp(&Index, 0, 0, 0);
  SPIPort = KMGetPortAddress(Index, 1);
  SPISS = Index & 0x07;
  KMSetDDR(Index, 1);
  N = KMMIInit(KMIOSPIMOSI, KMIOSPIMOSIMask);
  KMMIGetIOProp(&Index, 0, 0, 0);
  KMSetDDR(Index, 1);
  N = KMMIInit(KMIOSPIMISO, KMIOSPIMISOMask);
  KMMIGetIOProp(&Index, 0, 0, 0);
  KMSetDDR(Index, 0);
  N = KMMIInit(KMIOSPISCK, KMIOSPISCKMask);
  KMMIGetIOProp(&Index, 0, 0, 0);
  KMSetDDR(Index, 1);
  SPISetSSHigh();
  SPCR = (1 << SPE) | (1 << MSTR) | (1 << SPR0);  
}

tByte SPIRead(void) {
  SPDR = 0x00;
  while(!(SPSR & (1 << SPIF)));
  return SPDR;
}

void SPIWrite(tByte pC) {
  SPDR = pC;
  while(!(SPSR & (1 << SPIF)));
}
