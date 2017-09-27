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


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHARS

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#include <haam.h>
#include <hars.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define RSTimerPrescale 20

#define RSStatusStill 0x00
#define RSStatusUp 0x01
#define RSStatusDown 0x02
#define RSControlFlag 0x80

#define RSMaxTimeTol 1.1

#define RSTypeImpSteuer 1
#define RSImpLengthC 3


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tAMProp *CP;
  tByte Value;
  tByte ValueNew;
  tByte Counter;
  tByte Status;
  signed char ImpSteuerUpC;
  signed char ImpSteuerDownC;
} tRSStatusElement;

typedef struct {
  tByte N;
  tRSStatusElement *E;
} tRSStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tRSStatus RSS;
tByte RSCounter;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void RSInit(void) {
  
  tByte i;

  RSS.N = AMMIInit(KMAMRS, KMAMRSMask);
  RSS.E = malloc(sizeof(tRSStatusElement) * RSS.N);
  for(i = 0; i < RSS.N; i++) {
    RSS.E[i].CP = AMMIGetMProp();
    RSS.E[i].Value = 0;
    RSS.E[i].ValueNew = 0;
    RSS.E[i].Counter = 0;
    RSS.E[i].Status = RSStatusStill;
    RSS.E[i].ImpSteuerUpC = -1;
    RSS.E[i].ImpSteuerDownC = -1;
  }
  RSCounter = 0;
}

void RSSetValue(tByte pX, tByte pValue) {
  if((RSS.E[pX].Status & 0x03) == RSStatusStill) {
    if(RSS.E[pX].Value > pValue || pValue == 0) {
      if(pValue == 0)
        RSS.E[pX].Counter = RSS.E[pX].CP->RS.MaxTime * RSMaxTimeTol;
      else
        RSS.E[pX].Counter = (RSS.E[pX].Value - pValue) * RSS.E[pX].CP->RS.MaxTime / 100;
      RSS.E[pX].Status = (RSS.E[pX].Status & 0xFC) | RSStatusUp;
      if((RSS.E[pX].CP->RS.Type & RSTypeImpSteuer) == RSTypeImpSteuer)
        RSS.E[pX].ImpSteuerUpC = RSImpLengthC;
      SMSetOutput(RSS.E[pX].CP->RS.OPUp.Modul, RSS.E[pX].CP->RS.OPUp.Addr, 100, 0, 0);
    }
    if(RSS.E[pX].Value < pValue || pValue == 100) {
      if(pValue == 100)
        RSS.E[pX].Counter = RSS.E[pX].CP->RS.MaxTime * RSMaxTimeTol;
      else
        RSS.E[pX].Counter = (pValue - RSS.E[pX].Value) * RSS.E[pX].CP->RS.MaxTime / 100;
      RSS.E[pX].Status = (RSS.E[pX].Status & 0xFC) | RSStatusDown;
      if((RSS.E[pX].CP->RS.Type & RSTypeImpSteuer) == RSTypeImpSteuer)
        RSS.E[pX].ImpSteuerDownC = RSImpLengthC;
      SMSetOutput(RSS.E[pX].CP->RS.OPDown.Modul, RSS.E[pX].CP->RS.OPDown.Addr, 100, 0, 0);
    }
    RSS.E[pX].ValueNew = pValue;
    SMSendStatus(RSS.E[pX].CP->SModul, RSS.E[pX].CP->Addr, pValue, 0);
  }
  else
    SMSendProtErr(SMPECDeviceBusy, RSS.E[pX].CP->Addr, 0, 0);
}

void RSControlInvert(tByte pX) {
  if(RSS.E[pX].Status & 0x03)
    RSControlStop(pX);
  else
    if(RSGetValue(pX) > 0)
      RSSetValue(pX, 0);
    else
      RSSetValue(pX, 100);
}

void RSControlUp(tByte pX) {
  if(RSS.E[pX].Status & 0x03)
    RSControlStop(pX);
  else
    RSSetValue(pX, 0);
}

void RSControlDown(tByte pX) {
  if(RSS.E[pX].Status & 0x03)
    RSControlStop(pX);
  else
    RSSetValue(pX, 100);
}

void RSControlStop(tByte pX) {
  RSS.E[pX].Counter = 0;
  RSS.E[pX].ValueNew = RSS.E[pX].Value;
  SMSendStatus(RSS.E[pX].CP->SModul, RSS.E[pX].CP->Addr, RSGetValue(pX), 0);
}

void RSControlStart(tByte pX) {
  if(RSS.E[pX].Status & RSControlFlag)
    RSControlDown(pX);
  else
    RSControlUp(pX);
  RSS.E[pX].Status ^= RSControlFlag;
}

inline tByte RSGetValue(tByte pX) {
  return RSS.E[pX].Value;
}

inline void RSCounterInc(void) {
  RSCounter++;
}

void RSControl(void) {

  tByte i;

  if(RSCounter >= RSTimerPrescale) {
    RSCounter = 0;
    for(i = 0; i < RSS.N; i++) {
      if(RSS.E[i].ImpSteuerUpC >= 0) RSS.E[i].ImpSteuerUpC--;
      if(RSS.E[i].ImpSteuerUpC == 0)
        SMSetOutput(RSS.E[i].CP->RS.OPUp.Modul, RSS.E[i].CP->RS.OPUp.Addr, 0, 0, 0);
      if(RSS.E[i].ImpSteuerDownC >= 0) RSS.E[i].ImpSteuerDownC--;
      if(RSS.E[i].ImpSteuerDownC == 0)
        SMSetOutput(RSS.E[i].CP->RS.OPDown.Modul, RSS.E[i].CP->RS.OPDown.Addr, 0, 0, 0);
      if(RSS.E[i].Counter > 0) {
        RSS.E[i].Counter--;
        if((RSS.E[i].Status & 0x03) == RSStatusUp)
          RSS.E[i].Value = RSS.E[i].Counter * 100 / RSS.E[i].CP->RS.MaxTime + RSS.E[i].ValueNew;
        if((RSS.E[i].Status & 0x03) == RSStatusDown)
          RSS.E[i].Value = RSS.E[i].ValueNew - RSS.E[i].Counter * 100 / RSS.E[i].CP->RS.MaxTime;
      }
      else {
        if((RSS.E[i].Status & 0x03) == RSStatusUp) {
          RSS.E[i].Status = (RSS.E[i].Status & 0xFC) | RSStatusStill;
          if((RSS.E[i].CP->RS.Type & RSTypeImpSteuer) == RSTypeImpSteuer) {
            RSS.E[i].ImpSteuerUpC = RSImpLengthC;
            SMSetOutput(RSS.E[i].CP->RS.OPUp.Modul, RSS.E[i].CP->RS.OPUp.Addr, 100, 0, 0);
          }
          else
            SMSetOutput(RSS.E[i].CP->RS.OPUp.Modul, RSS.E[i].CP->RS.OPUp.Addr, 0, 0, 0);
        }
        if((RSS.E[i].Status & 0x03) == RSStatusDown) {
          RSS.E[i].Status = (RSS.E[i].Status & 0xFC) | RSStatusStill;
          if((RSS.E[i].CP->RS.Type & RSTypeImpSteuer) == RSTypeImpSteuer) {
            RSS.E[i].ImpSteuerDownC = RSImpLengthC;
            SMSetOutput(RSS.E[i].CP->RS.OPDown.Modul, RSS.E[i].CP->RS.OPDown.Addr, 100, 0, 0);
          }
          else
            SMSetOutput(RSS.E[i].CP->RS.OPDown.Modul, RSS.E[i].CP->RS.OPDown.Addr, 0, 0, 0);
        }
        RSS.E[i].Value = RSS.E[i].ValueNew;
      }
    }
  }
}

inline void RSDestroy(void) {
  free(RSS.E);
}

#endif
