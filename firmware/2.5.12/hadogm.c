////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                LCD EA DOGM                                          //
// Version:              1.1 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          01.02.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Basis Module ////////////////////////////////////////////////////////////////

#include <hadelay.h>
#include <hadogm.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tVPByte DOGMDataPort;
tVPByte DOGMDataReadPort;
tVPByte DOGMDataDDR;
tByte DOGMDataFirstPin;
tVPByte DOGMModePort;
tByte DOGMModeFirstPin;
tVPByte DOGMEnaPort;
tByte DOGMEnaPin;
tVPByte DOGMBLPort;
tByte DOGMBLPin;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void DOGMStartRW(void) {
  *DOGMEnaPort |= 1 << DOGMEnaPin;
  asm volatile ("nop");
  *DOGMEnaPort &= ~(1 << DOGMEnaPin);    
}

void DOGMWWB(void) {

  tByte tmp;
  
  *DOGMDataDDR &= ~(0x0F << DOGMDataFirstPin);
  *DOGMDataPort &= ~(0x0F << DOGMDataFirstPin);
  *DOGMModePort &= ~(0x03 << DOGMModeFirstPin);
  *DOGMModePort |= 1 << DOGMModeFirstPin;
  do {
    *DOGMEnaPort |= 1 << DOGMEnaPin;
    asm volatile ("nop");
    tmp = *DOGMDataReadPort & 0x08 << DOGMDataFirstPin;
    *DOGMEnaPort &= ~(1 << DOGMEnaPin);    
    DOGMStartRW();
  } while(tmp > 0);
  *DOGMDataDDR |= 0x0F << DOGMDataFirstPin;
}

void DOGMWrite(tByte pData) {
  *DOGMDataPort &= ~(0x0F << DOGMDataFirstPin);
  *DOGMDataPort |= (pData & 0xF0) >> (4 - DOGMDataFirstPin);
  DOGMStartRW();
  *DOGMDataPort &= ~(0x0F << DOGMDataFirstPin);
  *DOGMDataPort |= (pData & 0x0F) << DOGMDataFirstPin;
  DOGMStartRW();
}

void DOGMWriteInst(tByte pInst) {
  if(pInst != LCDInstNil) {
    DOGMWWB();
    *DOGMModePort &= ~(0x03 << DOGMModeFirstPin);
    DOGMWrite(pInst);
  }
}

void DOGMWriteData(tByte pData) {
  if(pData != LCDDataNil) {
    DOGMWWB();
    *DOGMModePort &= ~(0x03 << DOGMModeFirstPin);
    *DOGMModePort |= 0x02 << DOGMModeFirstPin;
    DOGMWrite(pData);
  }
}

void DOGMInit(void) {

  tByte i;
  tByte N;
  tByte Index;
  tByte Type;

  N = KMMIInit(KMIOLCD, KMIOLCDMask);
  for(i = 0; i < N; i++) {
    KMMIGetIOProp(&Index, &Type, 0, 0);
    switch(Type) {
      case KMIOLCDD0:
        DOGMDataPort = KMGetPortAddress(Index, 1);
        DOGMDataReadPort = KMGetPortAddress(Index, 0);
        DOGMDataDDR = KMGetDDRAddress(Index);
        DOGMDataFirstPin = Index & 0x07;
        break;
      case KMIOLCDRW:
        DOGMModePort = KMGetPortAddress(Index, 1);
        DOGMModeFirstPin = Index & 0x07;
        break;
      case KMIOLCDE:
        DOGMEnaPort = KMGetPortAddress(Index, 1);
        DOGMEnaPin = Index & 0x07;
        break;
      case KMIOLCDBL:
        DOGMBLPort = KMGetPortAddress(Index, 1);
        DOGMBLPin = Index & 0x07;
        break;
    }
    KMSetDDR(Index, 1);
  }
  if(N > 0) {
    for(i = 0; i < 10; i++) Delay(4 * DelayMS);
    *DOGMModePort &= ~(0x03 << DOGMModeFirstPin);
    *DOGMDataPort &= ~(0x0F << DOGMDataFirstPin);
    *DOGMDataPort |= 0x03 << DOGMDataFirstPin;
    DOGMStartRW();
    Delay(2 * DelayMS);
    DOGMStartRW();
    Delay(30 * DelayUS);
    DOGMStartRW();
    Delay(30 * DelayUS);
    *DOGMDataPort &= ~(0x01 << DOGMDataFirstPin);
    DOGMStartRW();
    DOGMWriteInst(0x29);
#ifdef COHALCD2X16
    DOGMWriteInst(0x1C);
#endif
#ifdef COHALCD3X16
    DOGMWriteInst(0x1D);
#endif
    DOGMWriteInst(0x50);
    DOGMWriteInst(0x6C);
    DOGMWriteInst(0x7C);
    DOGMWriteInst(0x0C);
    DOGMWriteInst(0x01);
    DOGMWriteInst(0x06);
  }
}

void LCDBL(tByte pValue) {
  if(pValue > 0)
    *DOGMBLPort = *DOGMBLPort | 1 << DOGMBLPin;  
  else
    *DOGMBLPort = *DOGMBLPort & ~(1 << DOGMBLPin);
}

void LCDPutString(tByte *pString) {

  tByte i;

  for(i = 1; i <= pString[0]; i++)
    DOGMWriteData(pString[i]);
}
