////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Logic Input                                          //
// Version:              2.2 (3)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          24.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.02.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHALI

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hali.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define LIPrell 10
#define LIShort 50
#define LILong 150


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Value;
  tByte Poll;
  tWord PC;
  tVPByte Port;
  tByte Pin;
  tByte Prop;
  tByte Addr;
  tByte SModul;
} tLIStatusElement;

typedef struct {
  tByte N;
  tLIStatusElement *E;
} tLIStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tLIC LIC;
tLIStatus LIS;
tByte LISynchPoll;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tLIC *LIGetConfPointer(void) {
  return &LIC;
}

void LISetConfDefaults(void) {
  LIC.PrellC[0] = 0;
  LIC.PrellC[1] = LIPrell;
  LIC.PrellC[2] = LIShort;
  LIC.PrellC[3] = LILong;
}

inline void LISetConfPrellC(tByte pIndex, tWord pValue) {
  LIC.PrellC[pIndex] = pValue;
}

void LIInit(void) {
  
  tByte i;
  tByte Index;

  LISynchPoll = 0;
  LIS.N = KMMIInit(KMIOLI, KMIOLIMask);
  LIS.E = malloc(sizeof(tLIStatusElement) * LIS.N);
  for(i = 0; i < LIS.N; i++) {
    KMMIGetIOProp(&Index, &LIS.E[i].Prop, &LIS.E[i].Addr, &LIS.E[i].SModul);
    LIS.E[i].Port = KMGetPortAddress(Index, 0);
    LIS.E[i].Pin = Index & 0x07;
    LIS.E[i].Poll = *LIS.E[i].Port >> LIS.E[i].Pin & 0x01;
    LIS.E[i].Value = ~LIS.E[i].Poll << 7;
    LIS.E[i].PC = 0;
    if((LIS.E[i].Prop & KMIOLIPullUp) == 0)
      KMSetDDR(Index, 0);
    else
      KMSetDDR(Index, 2);
  }
}

inline void LISetSynchPoll(void) {
  LISynchPoll = 1;
}

void LIInputDetect(tByte pX, tByte pType) {
  LIS.E[pX].Value = ~LIS.E[pX].Poll << 7;
  LIS.E[pX].Value = (LIS.E[pX].Value & 0xF3) | pType;
  SMSendStatus(LIS.E[pX].SModul, LIS.E[pX].Addr, LIS.E[pX].Value, 0);
}

void LIPoll(void) {

  tByte i;

  if(LISynchPoll == 1) {
    for(i = 0; i < LIS.N; i++) {
      if(LIS.E[i].PC > 0) LIS.E[i].PC--;
      if((LIS.E[i].Poll & 0x01) != (*LIS.E[i].Port >> LIS.E[i].Pin & 0x01)) {
        if((LIS.E[i].Poll & 0x80) > 0) {
          LIS.E[i].Poll = LIS.E[i].Poll & 0x7F;
          if((LIS.E[i].Prop & KMIOLILong) == KMIOLILong && LIC.PrellC[3] - LIS.E[i].PC >= LIC.PrellC[2]) LIInputDetect(i, 0x08);
          else
            if((LIS.E[i].Prop & KMIOLILong) >= KMIOLIShort && LIC.PrellC[2] - LIS.E[i].PC >= LIC.PrellC[1]) LIInputDetect(i, 0x04);
        }
        if(LIS.E[i].Prop & KMIOLIForcePrell) {        
          LIS.E[i].PC = LIC.PrellC[1];
          LIS.E[i].Poll = LIS.E[i].Poll | 0x80;
        }
        if(((LIS.E[i].Poll & 0x01) == 0 && (LIS.E[i].Prop & KMIOLIRE) > 0) || ((LIS.E[i].Poll & 0x01) == 1 && (LIS.E[i].Prop & KMIOLIFE) > 0)) {
          LIS.E[i].PC = LIC.PrellC[LIS.E[i].Prop >> 2 & 0x03];
          LIS.E[i].Poll = LIS.E[i].Poll | 0x80;
        }
        LIS.E[i].Poll = LIS.E[i].Poll ^ 0x01;
      }
      if((LIS.E[i].Poll & 0x01) == (*LIS.E[i].Port >> LIS.E[i].Pin & 0x01) && (LIS.E[i].Poll & 0x80) > 0 && LIS.E[i].PC == 0) {
        LIS.E[i].Poll = LIS.E[i].Poll & 0x7F;
        LIInputDetect(i, LIS.E[i].Prop & 0x0C);
      }
    }
    LISynchPoll = 0;
  }
}

inline tByte LIGetValue(tByte pX) {
  return LIS.E[pX].Value;
}

inline void LIDestroy(void) {
  free(LIS.E);
}

#endif
