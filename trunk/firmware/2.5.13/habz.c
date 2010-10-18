////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Buzzer                                               //
// Version:              2.1 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  21.01.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHABZ

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <habz.h>


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tBZC BZC;
tWord BZCounter;                            // Timer fuer Buzzer
tVPByte BZPort;
tByte BZPin;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tBZC *BZGetConfPointer(void) {
  return &BZC;
}

inline void BZSetConfDefaults(void) {
  BZC.BuzzerLevel = 0xFFFF;
}

inline void BZSetConfBuzzerLevel(tWord pBuzzerLevel) {
  BZC.BuzzerLevel = pBuzzerLevel;
}

void BZInit(void) {

  tByte i;
  tByte Index;
  tByte N;
  
  N = KMMIInit(KMIOBZ, KMIOBZMask);
  for(i = 0; i < N; i++) {
    KMMIGetIOProp(&Index, 0, 0, 0);
    BZPort = KMGetPortAddress(Index, 1);
    BZPin = Index & 0x07;
    KMSetDDR(Index, 1);
  }
  BZCounter = 0;
}

void BZBuzzer(tByte pTime, tByte pLevel) {
  if((BZC.BuzzerLevel & 1 << pLevel) > 0) {
    BZCounter = pTime * 10;
    *BZPort = *BZPort | 1 << BZPin;        // Buzzer einschalten
  }
}

void BZControl(void) {
  if(BZCounter == 0)
    *BZPort = *BZPort & ~(1 << BZPin);        // Buzzer ausschalten
  else
    BZCounter--;
}

#endif
