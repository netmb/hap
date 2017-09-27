////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Switch                                               //
// Version:              2.1 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHASW

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hasw.h>


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Value;
  tVPByte Port;
  tByte Pin;
  tByte Addr;
  tByte SModul;  
} tSWStatusElement;

typedef struct {
  tByte N;
  tSWStatusElement *E;
} tSWStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tSWStatus SWS;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void SWInit(void) {
  
  tByte i;
  tByte Index;

  SWS.N = KMMIInit(KMIOSW, KMIOSWMask);
  SWS.E = malloc(sizeof(tSWStatusElement) * SWS.N);
  for(i = 0; i < SWS.N; i++) {
    KMMIGetIOProp(&Index, 0, &SWS.E[i].Addr, &SWS.E[i].SModul);
    SWS.E[i].Port = KMGetPortAddress(Index, 1);
    SWS.E[i].Pin = Index & 0x07;
    SWS.E[i].Value = 0;
    KMSetDDR(Index, 1);
  }
}

inline tByte SWGetValue(tByte pX) {
  return SWS.E[pX].Value;
}

void SWSetValue(tByte pX, tByte pValue) {
  SWS.E[pX].Value = pValue;
  if(pValue > 0)
    *SWS.E[pX].Port = *SWS.E[pX].Port | 1 << SWS.E[pX].Pin;  
  else
    *SWS.E[pX].Port = *SWS.E[pX].Port & ~(1 << SWS.E[pX].Pin);
  SMSendStatus(SWS.E[pX].SModul, SWS.E[pX].Addr, pValue, 0);    
}

inline void SWDestroy(void) {
  free(SWS.E);
}

#endif
