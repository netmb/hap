////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                TWI (Two-wire Serial Interface)                      //
// Version:              1.0 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          15.03.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  12.02.2009                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <avr/interrupt.h>
#include <avr/io.h>

#include <hatwi.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define TWITWBR 0x0C


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tByte *TWIBuffer;
tByte TWIBufLen;
tByte TWIBufPtr;
tByte TWIMsgLen;
tByte TWIMsgPtr;
tByte TWISuppressStopSig;
tByte TWITransStatus;
tByte TWIStatus;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void TWIInit(tByte pBufLen) {
  TWIBufLen = pBufLen;
  TWIBuffer = malloc(TWIBufLen);
  TWIBufPtr = 0;
  TWIMsgLen = 0;
  TWIMsgPtr = 0;
  TWISuppressStopSig = 0;
  TWITransStatus = 0;
  TWIStatus = TWINoStatus;
  TWBR = TWITWBR;
  TWDR = 0xFF;
  TWCR = 1 << TWEN;
}

inline tByte TWIBusy(void) {
  return TWCR & (1 << TWIE);
}

inline tByte TWITransOK(void) {
  return TWITransStatus;
}

tByte TWIGetStatus(void) {
  while(TWIBusy());
  return TWIStatus;
}

inline void TWISetBufPtr(tByte pPtr) {
  TWIBufPtr = pPtr;
}

inline void TWIFillBufferAtIndex(tByte pIndex, tByte pData) {
  TWIBuffer[pIndex] = pData;
}

void TWIFillBuffer(tByte *pData, tByte pDataLen) {

  tByte i;
  
  for(i = 0; i < pDataLen; i++) {
    TWIBuffer[TWIBufPtr] = pData[i];
    TWIBufPtr++;
    TWIBufPtr %= TWIBufLen;
  }
}

inline void TWISuppressStopSignal(void) {
  TWISuppressStopSig = 1;
}

void TWIStartNormal(tByte pMsgLen) {
  while(TWIBusy());
  if(pMsgLen > 0) TWIMsgLen = pMsgLen;
  TWITransStatus = 0;
  TWIStatus = TWINoStatus;
  TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT) | (1 << TWSTA);
}

void TWIStartWithData(tByte *pMsg, tByte pMsgLen) {

  tByte i;
  
  while(TWIBusy());
  TWIMsgLen = pMsgLen;
  TWIBuffer[0] = pMsg[0];
  if(!(TWIBuffer[0] & (1 << TWIRWBitPos)))
    for(i = 1; i < TWIMsgLen; i++ ) TWIBuffer[i] = pMsg[i];
  TWITransStatus = 0;
  TWIStatus = TWINoStatus;
  TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT) | (1 << TWSTA);
}

inline tByte TWIGetDataFromIndex(tByte pIndex) {
  return TWIBuffer[pIndex];
}

tByte TWIGetData(tByte *pMsg, tByte pMsgLen) {

  tByte i;
  
  while(TWIBusy());
  if(TWITransStatus)
    for(i = 0; i < pMsgLen; i++)
      pMsg[i] = TWIBuffer[i];
  return TWITransStatus;
}

SIGNAL (TWI_vect) {
  switch(TWSR) {
    case TWIStart:
    case TWIRepStart:
      TWIMsgPtr = 0;
    case TWIMTXAdrAck:
    case TWIMTXDataAck:
      if(TWIMsgPtr < TWIMsgLen) {
        TWDR = TWIBuffer[TWIMsgPtr++];
        TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT);
      }
      else {
        TWITransStatus = 1;
        if(TWISuppressStopSig)
          TWISuppressStopSig = 0;
        else
          TWCR = (1 << TWEN) | (1 << TWINT) | (1 << TWSTO);
      }
      break;
    case TWIMRXDataAck:
      TWIBuffer[TWIMsgPtr++] = TWDR;
    case TWIMRXAdrAck:
      if(TWIMsgPtr < TWIMsgLen - 1)
        TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT) | (1 << TWEA);
      else
        TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT);
      break;
    case TWIMRXDataNAck:
      TWIBuffer[TWIMsgPtr] = TWDR;
      TWITransStatus = 1;
      TWCR = (1 << TWEN) | (1 << TWINT) | (1 << TWSTO);
      break;
    case TWIArbLost:
      TWCR = (1 << TWEN) | (1 << TWIE) | (1 << TWINT) | (1 << TWSTA);
      break;
    case TWIMTXAdrNAck:
    case TWIMRXAdrNAck:
    case TWIMTXDataNAck:
    case TWIBusError:
    default:
      TWIStatus = TWSR;
      TWCR = (1 << TWEN);
  }
}

inline void TWIDestroy(void) {
  free(TWIBuffer);
}
