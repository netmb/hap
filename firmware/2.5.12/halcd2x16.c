////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                LCD 2x16                                             //
// Version:              1.0 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.02.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  10.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHALCD2X16

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <halcd2x16.h>
#include <hagui.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define LCDCCSpace 0x20
#define LCDCCPercent 0x25
#define LCDCCComma 0x2C
#define LCDCCMinus 0x2D
#define LCDCC0 0x30
#define LCDCCC 0x43
#define LCDCCGrad 0xDF

#define LCDMenueMarker 0xFC


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void LCDInit(void) {
  DOGMInit();
}

#ifdef COHAGUI
void LCDPutMenue(tGUIMenue *pMenue) {

  tByte i;
  tByte n;

  LCDClear();
  if(pMenue->N > 1)
    n = 2;
  else
    n = pMenue->N;
  for(i = 0; i < n; i++) {
    if(pMenue->Top + i == pMenue->Select) {
      LCDGotoXY(0, i);
      LCDPutChar(LCDMenueMarker);
    }
    else
      LCDGotoXY(1, i);
    LCDPutString(pMenue->E[pMenue->Top + i].Name);
  }
}

void LCDPutByte(tByte pByte) {

  tByte i;
  tByte tmp0;
  tByte tmp1;

  i = 100;
  tmp0 = pByte;
  while(i > 0) {
    tmp1 = tmp0 / i + LCDCC0;
    if(tmp1 == LCDCC0 && i > 1 && pByte < 100) tmp1 = LCDCCSpace;
    LCDPutChar(tmp1);
    tmp0 = tmp0 % i;
    i = i / 10;
  }
}

void LCDPutInt21(int pInt) {

  tByte tmp0;
  tByte tmp1;

  if(pInt < 0)
    LCDPutChar(LCDCCMinus);
  else
    LCDPutChar(LCDCCSpace);
  tmp0 = abs(pInt / 16);
  tmp1 = tmp0 / 10;
  if(tmp1 == 0)
    LCDPutChar(LCDCCSpace);
  else
    LCDPutChar(tmp1 + LCDCC0);
  tmp0 = tmp0 % 10;
  LCDPutChar(tmp0 + LCDCC0);
  LCDPutChar(LCDCCComma);
  tmp0 = pInt & 0x0F;
  LCDPutChar(tmp0 * 0.625 + 0.5 + LCDCC0);
}

void LCDPutOutCtrl(tGUIOutCtrl *pOutCtrl) {

  tByte i;

  LCDClear();
  LCDPutString(pOutCtrl->Name);
  if(pOutCtrl->State == GUIOCStateEdit) {
    LCDGotoXY(4, 1);
    LCDPutByte(pOutCtrl->ValueNew);
    LCDPutChar(LCDCCPercent);
  }
  LCDGotoXY(12, 1);
  if(pOutCtrl->Value == SMSCNOP)
    for(i = 0; i < 4; i++)
      LCDPutChar(LCDCCMinus);
  else {
    LCDPutByte(pOutCtrl->Value);
    LCDPutChar(LCDCCPercent);
  }
}

void LCDPutThermostatValue(int pValue) {

  tByte i;

  if(pValue == GUINOP)
    for(i = 0; i < 7; i++)
      LCDPutChar(LCDCCMinus);
  else {
    LCDPutInt21(pValue);
    LCDPutChar(LCDCCGrad);
    LCDPutChar(LCDCCC);
  }
}

void LCDPutThermostat(tGUIThermostat *pThermostat) {
  LCDClear();
  LCDPutString(pThermostat->Name);
  LCDGotoXY(1, 1);
  LCDPutThermostatValue(pThermostat->ValueNew);
  LCDGotoXY(9, 1);
  LCDPutThermostatValue(pThermostat->Value);
}
#endif

#endif
