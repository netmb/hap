////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                TWI (Two-wire Serial Interface)                      //
// Version:              1.0 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          15.03.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  04.04.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HATWI
#define HATWI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

// Bitpositionen im Adressbyte
#define TWIRWBitPos  0
#define TWIAddrBitsPos  1

// General TWI Master staus codes                      
#define TWIStart 0x08
#define TWIRepStart 0x10
#define TWIArbLost 0x38

// TWI Master Transmitter staus codes                      
#define TWIMTXAdrAck 0x18
#define TWIMTXAdrNAck 0x20
#define TWIMTXDataAck 0x28
#define TWIMTXDataNAck 0x30

// TWI Master Receiver staus codes  
#define TWIMRXAdrAck 0x40
#define TWIMRXAdrNAck 0x48
#define TWIMRXDataAck 0x50
#define TWIMRXDataNAck 0x58

// TWI Slave Transmitter staus codes
#define TWISTXAdrAck 0xA8
#define TWISTXAdrAckMArbLost 0xB0
#define TWISTXDataAck 0xB8
#define TWISTXDataNAck 0xC0
#define TWISTXDataAckLastByte 0xC8

// TWI Slave Receiver staus codes
#define TWISRXAdrAck 0x60
#define TWISRXAdrAckMArbLost 0x68
#define TWISRXGenAck 0x70
#define TWISRXGenAckMArbLost 0x78
#define TWISRXAdrDataAck 0x80
#define TWISRXAdrDataNAck 0x88
#define TWISRXGenDataAck 0x90
#define TWISRXGenDataNAck 0x98
#define TWISRXStopRestart 0xA0

// TWI Miscellaneous status codes
#define TWINoStatus 0xF8
#define TWIBusError 0x00


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void TWIInit(tByte pBufLen);
inline tByte TWIBusy(void);
inline tByte TWITransOK(void);
tByte TWIGetStatus(void);
inline void TWISetBufPtr(tByte pPtr);
inline void TWIFillBufferAtIndex(tByte pIndex, tByte pData);
void TWIFillBuffer(tByte *pData, tByte pDataLen);
inline void TWISuppressStopSignal(void);
void TWIStartNormal(tByte pMsgLen);
void TWIStartWithData(tByte *pMsg, tByte pMsgLen);
inline tByte TWIGetDataFromIndex(tByte pIndex);
tByte TWIGetData(tByte *pMsg, tByte pMsgLen);
inline void TWIDestroy(void);


#endif
