////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                OWI (One-wire Interface)                             //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          10.08.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  10.08.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Basis Module ////////////////////////////////////////////////////////////////

#include <avr/interrupt.h>
#include <avr/io.h>
#include <hadelay.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <haowi.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

//#define OWIUseInternalPullup

#define OWIPort PORTA
#define OWIPin PINA
#define OWIDDR DDRA

#define OWIDelayOffsetCycles 13

#define OWIDelayAStdMode ((6   * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayBStdMode ((64  * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayCStdMode ((60  * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayDStdMode ((10  * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayEStdMode ((9   * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayFStdMode ((55  * DelayUS) - OWIDelayOffsetCycles)
//#define OWIDelayGStdMode ((0   * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayHStdMode ((480 * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayIStdMode ((70  * DelayUS) - OWIDelayOffsetCycles)
#define OWIDelayJStdMode ((410 * DelayUS) - OWIDelayOffsetCycles)

#define OWIROMRead 0x33
#define OWIROMSkip 0xCC
#define OWIROMMatch 0x55
#define OWIROMSearch 0xF0


////////////////////////////////////////////////////////////////////////////////
// Makros                                                                     //
////////////////////////////////////////////////////////////////////////////////

#define OWIPullBusLow(pMask) \
  OWIDDR |= pMask; \
  OWIPort &= ~pMask;

#ifdef OWIUseInternalPullup

#define OWIReleaseBus(pMask) \
  OWIDDR &= ~pMask; \
  OWIPort |= pMask;

#else

#define OWIReleaseBus(pMask) \
  OWIDDR &= ~pMask; \
  OWIPort &= ~pMask;

#endif


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void OWIInit(tByte pPins) {
  OWIReleaseBus(pPins);
  Delay(OWIDelayHStdMode);
}

void OWIWriteBit1(tByte pPins) {
  cli();
  OWIPullBusLow(pPins);
  Delay(OWIDelayAStdMode);
  OWIReleaseBus(pPins);
  Delay(OWIDelayBStdMode);
  sei();
}

void OWIWriteBit0(tByte pPins) {
  cli();
  OWIPullBusLow(pPins);
  Delay(OWIDelayCStdMode);
  OWIReleaseBus(pPins);
  Delay(OWIDelayDStdMode);
  sei();
}

tByte OWIReadBit(tByte pPins) {

  tByte BitsRead;

  cli();
  OWIPullBusLow(pPins);
  Delay(OWIDelayAStdMode);
  OWIReleaseBus(pPins);
  Delay(OWIDelayEStdMode);
  BitsRead = OWIPin & pPins;
  Delay(OWIDelayFStdMode);
  sei();
  return BitsRead;
}

tByte OWIDetectPresence(tByte pPins) {

  tByte PresenceDetected;

  cli();
  OWIPullBusLow(pPins);
  Delay(OWIDelayHStdMode);
  OWIReleaseBus(pPins);
  Delay(OWIDelayIStdMode);
  PresenceDetected = ~OWIPin & pPins;
  Delay(OWIDelayJStdMode);
  sei();
  return PresenceDetected;
}

void OWISendByte(tByte pData, tByte pPins) {

  tByte i;

  for(i = 0; i < 8; i++) {
    if(pData & 0x01)
      OWIWriteBit1(pPins);
    else
      OWIWriteBit0(pPins);
    pData >>= 1;
  }
}

tByte OWIReceiveByte(tByte pPin) {

  tByte Data;
  tByte i;

  Data = 0x00;
  for(i = 0; i < 8; i++) {
    Data >>= 1;
    if(OWIReadBit(pPin)) Data |= 0x80;
  }
  return Data;
}

void OWISkipROM(tByte pPins) {
  OWISendByte(OWIROMSkip, pPins);
}

