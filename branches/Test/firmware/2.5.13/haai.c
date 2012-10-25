////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Analog Input                                         //
// Version:              2.2 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          26.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAAI

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <avr/io.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <haai.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define AISRatePrescale 10
#define AISRateDefault 600

#define AIVSCT 0x0A
#define AIVSCTValue 0x00


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord Value;
  tWord SC;
  tVPByte Port;
  tByte Pin;
  tByte Addr;
  tByte SModul;
} tAIStatusElement;

typedef struct {
  tByte N;
  tAIStatusElement *E;
} tAIStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tAIC AIC;
tAIStatus AIS;
tByte AICounter;
tByte AIActConv;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tAIC *AIGetConfPointer(void) {
  return &AIC;
}

void AISetConfDefaults(void) {

  tByte i;
  tByte j;

  for(i = 0; i < 8; i++) {
    AIC[i].SRate = AISRateDefault;
    for(j = 0; j < AITCount; j++) {
      AIC[i].T[j].Value = 0;
      AIC[i].T[j].Hyst = 0;
      AIC[i].T[j].Flags = 0;
    }
  }
}

inline void AISetConfSRate(tByte pPin, tWord pSRate) {
  AIC[pPin].SRate = pSRate;
}

inline void AISetConfTValue(tByte pPin, tByte pT, tWord pValue) {
  AIC[pPin].T[pT].Value = pValue;
}

inline void AISetConfTHystFlags(tByte pPin, tByte pT, tByte pHyst, tByte pFlags) {
  AIC[pPin].T[pT].Hyst = pHyst;
  AIC[pPin].T[pT].Flags = pFlags;
}

void AIInit(void) {
  
  tByte i;
  tByte Index;

  AIS.N = KMMIInit(KMIOAI, KMIOAIMask);
  AIS.E = malloc(sizeof(tAIStatusElement) * AIS.N);
  for(i = 0; i < AIS.N; i++) {
    KMMIGetIOProp(&Index, 0, &AIS.E[i].Addr, &AIS.E[i].SModul);
    AIS.E[i].Port = KMGetPortAddress(Index, 0);
    AIS.E[i].Pin = Index;
    AIS.E[i].Value = 0;
    AIS.E[i].SC = 0;
    KMSetDDR(Index, 0);
  }
  AICounter = 0;
  AIActConv = 0xFF;
  ADMUX = 0xC0;
  if(AIS.N > 0) ADCSRA = 0x87;
}

void AISetValue(tByte pX, tByte pSelect, tWord pValue) {
  if(pSelect >> 4 == AIVSCT && (pSelect & 0x03) == 0)
    AISetConfTValue(pX, (pSelect >> 2) & 0x03, pValue);
}

inline void AICounterInc(void) {
  AICounter++;
}

void AISample(void) {

  tByte i;
  tByte j;
  tWord Value;
  tByte Hyst;
  tByte TFlags;

  if(AICounter >= AISRatePrescale) {
    AICounter = 0;
    for(i = 0; i < AIS.N; i++)
      if(AIS.E[i].SC > 0) AIS.E[i].SC--;
  }
  if(AIActConv < 0xFF && (ADCSRA & 1 << ADSC) == 0) {
    AIS.E[AIActConv].Value = 0;
    AIS.E[AIActConv].Value = ADCL << 2;
    AIS.E[AIActConv].Value |= ADCH << 10;
    for(j = 0; j < AITCount; j++) {
      Value = AIC[AIS.E[AIActConv].Pin].T[j].Value;
      Hyst = AIC[AIS.E[AIActConv].Pin].T[j].Hyst;
      TFlags = AIC[AIS.E[AIActConv].Pin].T[j].Flags;
      if((TFlags & 0x04) > 0) {
        if(AIS.E[AIActConv].Value < Value && !(TFlags & 0x01)) {
          TFlags |= 0x01;
          SMSendStatus(AIS.E[AIActConv].SModul, AIS.E[AIActConv].Addr, j | 0x40, 0);
        }
        if(AIS.E[AIActConv].Value >= Value + Hyst && (TFlags & 0x01)) {
          TFlags &= 0xFE;
          SMSendStatus(AIS.E[AIActConv].SModul, AIS.E[AIActConv].Addr, j, 0);
        }
      }
      if((TFlags & 0x08) > 0) {
        if(AIS.E[AIActConv].Value > Value && !(TFlags & 0x02)) {
          TFlags |= 0x02;
          SMSendStatus(AIS.E[AIActConv].SModul, AIS.E[AIActConv].Addr, j | 0xC0, 0);
        }
        if(AIS.E[AIActConv].Value <= Value - Hyst && (TFlags & 0x02)) {
          TFlags &= 0xFD;
          SMSendStatus(AIS.E[AIActConv].SModul, AIS.E[AIActConv].Addr, j | 0x80, 0);
        }
      }
      AIC[AIS.E[AIActConv].Pin].T[j].Flags = TFlags;
    }
  }
  if(AIActConv == 0xFF || (ADCSRA & 1 << ADSC) == 0) {
    for(i = AIActConv + 1; i < AIS.N; i++)
      if(AIS.E[i].SC == 0) break;
    if(i < AIS.N) {
      AIS.E[i].SC = AIC[AIS.E[i].Pin].SRate;
      ADMUX &= 0xF8;
      ADMUX |= AIS.E[i].Pin;
      ADCSRA |= 1 << ADSC;
      AIActConv = i;
    }
    else
      AIActConv = 0xFF;
  }
}

tWord AIGetValue(tByte pX, tByte pSelect) {

  tWord Result;

  Result = 0xFFFF;
  if(pSelect == 0)
    Result = AIS.E[pX].Value;
  if(pSelect >> 4 == AIVSCT && (pSelect & 0x03) == 0)
    Result = AIC[pX].T[(pSelect >> 2) & 0x03].Value;
  return Result;
}

inline void AIDestroy(void) {
  free(AIS.E);
}

#endif
