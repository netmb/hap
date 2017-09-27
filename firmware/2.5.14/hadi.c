////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Digital Input                                        //
// Version:              1.0 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.03.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  23.10.2010                                           //
// Zuletzt geändert von: Carsten Wolff                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHADI

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <haowi.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hadi.h>

#ifdef COHADIDS1820
#include <hadids1820.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DISRatePrescale 1
#define DISRateDefault 60

#define DIDTDS18B20 0x01
#define DIDTDS18S20 0x02

#define DIVSCT 0x0A
#define DIVSCTValue 0x00


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  int Value;
  tWord SC;
  tByte Pin;
  tByte Addr;
  tByte SModul;
} tDIStatusElement;

typedef struct {
  tByte N;
  tDIStatusElement *E;
} tDIStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tDIC DIC;
tDIStatus DIS;
tByte DICounter;
tByte OWIBuses;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tDIC *DIGetConfPointer(void) {
  return &DIC;
}

void DISetConfDefaults(void) {

  tByte i;
  tByte j;

  for(i = 0; i < 8; i++) {
    DIC[i].SRate = DISRateDefault;
    DIC[i].Type = 0;
    for(j = 0; j < DITCount; j++) {
      DIC[i].T[j].Value = 0;
      DIC[i].T[j].Hyst = 0;
      DIC[i].T[j].Flags = 0;
    }
  }
}

inline void DISetConfSRate(tByte pPin, tWord pSRate) {
  DIC[pPin].SRate = pSRate;
}

inline void DISetConfType(tByte pPin, tByte pType) {
  DIC[pPin].Type = pType;
}

inline void DISetConfTValue(tByte pPin, tByte pT, int pValue) {
  DIC[pPin].T[pT].Value = pValue;
}

inline void DISetConfTHystFlags(tByte pPin, tByte pT, tByte pHyst, tByte pFlags) {
  DIC[pPin].T[pT].Hyst = pHyst;
  DIC[pPin].T[pT].Flags = pFlags;
}

void DIInit(void) {
  
  tByte i;
  tByte Index;

  DIS.N = KMMIInit(KMIODI, KMIODIMask);
  DIS.E = malloc(sizeof(tDIStatusElement) * DIS.N);
  OWIBuses = 0;
  for(i = 0; i < DIS.N; i++) {
    KMMIGetIOProp(&Index, 0, &DIS.E[i].Addr, &DIS.E[i].SModul);
    DIS.E[i].Pin = Index;
    DIS.E[i].Value = 0;
    DIS.E[i].SC = 0;
    OWIBuses |= 1 << Index;
  }
  DICounter = 0;
  OWIInit(OWIBuses);
}

void DISetValue(tByte pX, tByte pSelect, tWord pValue) {
  if(pSelect >> 4 == DIVSCT && (pSelect & 0x03) == 0)
    DISetConfTValue(pX, (pSelect >> 2) & 0x03, pValue);
}

inline void DICounterInc(void) {
  DICounter++;
}

void DISample(void) {

  tByte i;
  tByte j;
  int Value;
  tByte Hyst;
  tByte TFlags;
  tByte Pin;
  int tmp;

  if(DICounter >= DISRatePrescale) {
    DICounter = 0;
    for(i = 0; i < DIS.N; i++) {
      Pin = 1 << DIS.E[i].Pin;
      if(DIS.E[i].SC > 0) DIS.E[i].SC--;
      if(DIS.E[i].SC == 1 && OWIDetectPresence(Pin)) {
        OWISkipROM(Pin);
        switch(DIC[DIS.E[i].Pin].Type) {
#ifdef COHADIDS1820
          case DIDTDS18B20:
          case DIDTDS18S20:
            DIDS1820StartConversion(Pin);
            break;
#endif
        }
      }
      if(DIS.E[i].SC == 0) {
        if(OWIDetectPresence(Pin)) {
          OWISkipROM(Pin);
          switch(DIC[DIS.E[i].Pin].Type) {
#ifdef COHADIDS1820
            case DIDTDS18B20:
              DIDS1820ReadScratchpad(Pin);
              DIS.E[i].Value = OWIReceiveByte(Pin);
              DIS.E[i].Value |= (OWIReceiveByte(Pin) << 8);
              break;
            case DIDTDS18S20:
              DIDS1820ReadScratchpad(Pin);
              DIS.E[i].Value = OWIReceiveByte(Pin);
              DIS.E[i].Value |= (OWIReceiveByte(Pin) << 8);
              OWIReceiveByte(Pin);
              OWIReceiveByte(Pin);
              OWIReceiveByte(Pin);
              OWIReceiveByte(Pin);
              tmp = DIS.E[i].Value >> 1;
              tmp = tmp << 4;
              tmp -= 4;
              tmp += (16 - OWIReceiveByte(Pin));
              DIS.E[i].Value = tmp;
              break;
#endif
          }
        }
        for(j = 0; j < DITCount; j++) {
          Value = DIC[DIS.E[i].Pin].T[j].Value;
          Hyst = DIC[DIS.E[i].Pin].T[j].Hyst;
          TFlags = DIC[DIS.E[i].Pin].T[j].Flags;
          if((TFlags & 0x04) > 0) {
            if(DIS.E[i].Value < Value && !(TFlags & 0x01)) {
              TFlags |= 0x01;
              SMSendStatus(DIS.E[i].SModul, DIS.E[i].Addr, j | 0x40, 0);
            }
            if(DIS.E[i].Value >= Value + Hyst && (TFlags & 0x01)) {
              TFlags &= 0xFE;
              SMSendStatus(DIS.E[i].SModul, DIS.E[i].Addr, j, 0);
            }
          }
          if((TFlags & 0x08) > 0) {
            if(DIS.E[i].Value > Value && !(TFlags & 0x02)) {
              TFlags |= 0x02;
              SMSendStatus(DIS.E[i].SModul, DIS.E[i].Addr, j | 0xC0, 0);
            }
            if(DIS.E[i].Value <= Value - Hyst && (TFlags & 0x02)) {
              TFlags &= 0xFD;
              SMSendStatus(DIS.E[i].SModul, DIS.E[i].Addr, j | 0x80, 0);
            }
          }
          DIC[DIS.E[i].Pin].T[j].Flags = TFlags;
        }
        DIS.E[i].SC = DIC[DIS.E[i].Pin].SRate;
      }
    }
  }
}

int DIGetValue(tByte pX, tByte pSelect) {

  int Result;

  Result = 0xFFFF;
  if(pSelect == 0)
    Result = DIS.E[pX].Value;
  if(pSelect >> 4 == DIVSCT && (pSelect & 0x03) == 0)
    Result = DIC[pX].T[(pSelect >> 2) & 0x03].Value;
  return Result;
}

inline void DIDestroy(void) {
  free(DIS.E);
}


#endif
