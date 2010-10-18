////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Funk                                                 //
// Version:              2.2 (3)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  12.02.2009                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAFM

// Basis Module ////////////////////////////////////////////////////////////////

#include <avr/interrupt.h>
#include <avr/io.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hafm.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define FMUARTBaudRate 19200
#define FMUARTBaudSelect (CPUFrequenz / (FMUARTBaudRate * 16L) - 1)

#define FMMTimeOut (CPUFrequenz * FMMLength / 720000)

#define FMEFOff 0x00
#define FMEFOn 0x01
#define FMEFOnFLID 0x03


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef union {
  tByte Array[FMMLength];            // Message als Array behandeln
  struct {                            // Message als Struktur behandeln
    tByte FLANID;
    tMData Data;
  } Code;
} tFMMessage;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tFMC FMC;
tFMMessage FMMessageRec;                    // Empfangen einer Nachricht
tByte FMArrayIndex;                            // Index fuer Nachrichten-Array
tWord FMCounter;                            // Timer fuer Nachrichtenlaenge


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tFMC *FMGetConfPointer(void) {
  return &FMC;
}

void FMSetConfDefaults(void) {

  tByte i;

  FMC.FLANID = 0;
  FMC.EncFlags = FMEFOff;
  for(i = 0; i < FMMLength; i++) FMC.EncKey[i] = 0;
  for(i = 0; i < FMRangeExtCount; i++) FMC.RangeExt[i] = 0;
}

inline void FMSetConfFLANID(tByte pFLANID) {
  FMC.FLANID = pFLANID;
}

inline void FMSetConfEncFlags(tByte pEncFlags) {
  FMC.EncFlags = pEncFlags;
}

inline void FMSetConfEncKey(tByte pIndex, tByte pKey) {
  FMC.EncKey[pIndex] = pKey;
}

inline void FMSetConfRangeExt(tByte pIndex, tByte pExt) {
  FMC.RangeExt[pIndex] = pExt;
}

void FMInit(void) {
  FMArrayIndex = 0;
  UCSRB = 0x98;                        // RXCIE (Receive Int enabled, TXEN, RXEN)
  UBRRL = FMUARTBaudSelect;            // Baudrate einstellen
  UCSRC = 0x86;                        // URSEL im UCSRC Register setzten
  FMCounter = 0;
}

inline void FMSynch(void) {
  if(FMCounter == 0)
    FMArrayIndex = 0;
  else
    FMCounter--;
}

void FMPutChar(tByte pC) {
  while((UCSRA & 1 << UDRE) == 0) {}
  UDR = pC;
}

void FMTransmit(tByte pInt, const tMData *pData) {

  tByte i;

  if(pInt == SMIntIDFM || ((pInt & ~SMIntIDInvertMask) != SMIntIDFM && (pInt & SMIntIDInvertMask)) || (pInt & SMIntIDNumberMask) == SMIntIDNumberBroadcast) {
    if(FMC.EncFlags == FMEFOnFLID)
      FMPutChar(FMC.FLANID ^ FMC.EncKey[0]);
    else
      FMPutChar(FMC.FLANID);
    if(FMC.EncFlags > FMEFOff)
      for(i = 0; i < MDataLength; i++)
        FMPutChar(pData->Array[i] ^ FMC.EncKey[i + 1]);
    else
      for(i = 0; i < MDataLength; i++)
        FMPutChar(pData->Array[i]);
  }
}

ISR(USART_RXC_vect) {

  tByte i;

  while ((UCSRA & (1 << RXC)) == 0) {}
  FMMessageRec.Array[FMArrayIndex] = UDR;
  if(FMArrayIndex == 0) {
    if(FMC.EncFlags == FMEFOnFLID) FMMessageRec.Array[0] ^= FMC.EncKey[0];
  }
  else
    if(FMC.EncFlags > FMEFOff) FMMessageRec.Array[FMArrayIndex] ^= FMC.EncKey[FMArrayIndex];
  FMArrayIndex++;
  if(FMArrayIndex == FMMLength) {
    if(FMMessageRec.Code.FLANID == FMC.FLANID) {
      SMRecBufAdd(SMIntIDFM, &FMMessageRec.Code.Data);
      for(i = 0; i < FMRangeExtCount; i++)
        if(FMC.RangeExt[i] > 0 && (FMMessageRec.Code.Data.Code.Source == FMC.RangeExt[i] || FMMessageRec.Code.Data.Code.Dest == FMC.RangeExt[i] || FMMessageRec.Code.Data.Code.Dest == SMMABroadcast)) {
          if(FMMessageRec.Code.Data.Code.Dest == SMMABroadcast && FMMessageRec.Code.Data.Code.Source != FMC.RangeExt[i]) FMMessageRec.Code.Data.Code.Dest = FMC.RangeExt[i];
          FMTransmit(SMIntIDFM, &FMMessageRec.Code.Data);
        }
    }
    FMArrayIndex = 0;
  }
  else if(FMArrayIndex == 1) FMCounter = FMMTimeOut;
}

#endif
