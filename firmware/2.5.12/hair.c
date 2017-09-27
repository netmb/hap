////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Infrarot Fernbedienung                               //
// Version:              2.1 (3)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  20.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAIR

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#include <hair.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define IRIRRC5Time 1.778e-3        // 1.778msec
#define IRPulseMin (tByte)(CPUFrequenz / 512 * IRIRRC5Time * 0.4 + 0.5)
#define IRPulseHalf (tByte)(CPUFrequenz / 512 * IRIRRC5Time * 0.8 + 0.5)
#define IRPulseMax (tByte)(CPUFrequenz / 512 * IRIRRC5Time * 1.2 + 0.5)

#define IRCTimeOut 800

#define IRDevAddrDefault 0


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord Key;
  tByte Change;
} tIRKeyExchange;

typedef struct {
  tByte Modul;
  tWord Timeout;
  tByte Action;
} tIRCodeLearn;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tIRC IRC;
tByte IRRC5Bit;                                // bit value
tByte IRRC5Time;                            // count bit time
tWord IRRC5Tmp;                                // shift bits in
tByte IRToggle;                                // Erkennung Toggle-Bit
tSMIRKeyCodeComplete IRKeyCodeComplete;        // Tastenfolge
tByte IRCodeIndex;                            // Index fuer Code-Array
tIRKeyExchange IRKeyExchange;
tVPByte IRPort;
tByte IRPin;
tWord IRCounter;
tIRCodeLearn IRCodeLearn;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tIRC *IRGetConfPointer(void) {
  return &IRC;
}

void IRSetConfDefaults(void) {

  tByte i;

  IRC.IRDevAddr = IRDevAddrDefault;
  for(i = 0; i < (1 << IRCodeSize); i++) IRC.IRTranslate[i] = i;
}

inline void IRSetConf(tByte pDevAddr, tByte pIndex, tByte pTranslate) {
  IRC.IRDevAddr = pDevAddr;
  IRC.IRTranslate[pIndex] = pTranslate;
}

void IRInit(void) {

  tByte i;
  tByte Index;
  tByte N;
  
  N = KMMIInit(KMIOIR, KMIOIRMask);
  for(i = 0; i < N; i++) {
    KMMIGetIOProp(&Index, 0, 0, 0);
    IRPort = KMGetPortAddress(Index, 0);
    IRPin = Index & 0x07;
    KMSetDDR(Index, 0);
  }
  IRKeyExchange.Key = 0;
  IRKeyExchange.Change = 0;
  IRCounter = 0;
  IRCodeLearn.Timeout = 0;
  IRCodeLearn.Action = 1 << IRCodeSize;
}

inline void IRCodeLearnInit(tByte pModul, tWord pTimeout, tByte pAction) {
  IRCodeLearn.Modul = pModul;
  IRCodeLearn.Timeout = pTimeout;
  IRCodeLearn.Action = pAction;
}

inline void IRSynch(void) {
  if(IRCounter == 0)
    IRCodeIndex = 0;
  else
    IRCounter--;
  if(IRCodeLearn.Timeout > 0) IRCodeLearn.Timeout--;
}

void IRPutKey(void) {

  tByte i;                            // Schleifenzaehler
  tByte KeyCode;                    // Einzelne Taste

  if(IRKeyExchange.Change == 1) {
    IRKeyExchange.Change = 0;
#ifdef COHABZ
      BZBuzzer(BZAck, BZBLIRButton);
#endif
    if(IRCodeLearn.Action < (1 << IRCodeSize)) {
      IRC.IRDevAddr = IRKeyExchange.Key >> 6 & 0x1F;
      i = ((IRKeyExchange.Key & 0x3F) | (~IRKeyExchange.Key >> 6 & 0x40)) & ~(0xFF << IRCodeSize);
      IRC.IRTranslate[i] = IRCodeLearn.Action;
#ifdef COHABZ
      BZBuzzer(BZAck, BZBLIRLearnAck);
#endif
      SMSendIRLearnReady(IRCodeLearn.Modul, SMMTypeConfigIRLearnAck, IRC.IRDevAddr, i, IRCodeLearn.Action);
      IRCodeLearn.Action = 1 << IRCodeSize;
    }
    else {
      KeyCode = IRC.IRTranslate[((IRKeyExchange.Key & 0x3F) | (~IRKeyExchange.Key >> 6 & 0x40)) & ~(0xFF << IRCodeSize)];
      if((IRKeyExchange.Key >> 11 & 1) != IRToggle) {
        IRToggle = IRKeyExchange.Key >> 11 & 1;
        if(IRCodeIndex == 0 && (KeyCode == IRKCPlus || KeyCode == IRKCMinus)) {
          IRKeyCodeComplete.Code[0] = KeyCode;
          for(i = 1; i < 10; i++) IRKeyCodeComplete.Code[i] = 0;
          IRKeyCodeComplete.Length = 1;
          SMIRReceive(IRKeyCodeComplete);
        }
        else {
          if(KeyCode == IRKCEnter || KeyCode == IRKCPlus || KeyCode == IRKCMinus) {
            for(i = IRCodeIndex; i < 10; i++) IRKeyCodeComplete.Code[i] = 0;
            IRKeyCodeComplete.Length = IRCodeIndex;
            IRCodeIndex = 0;
            SMIRReceive(IRKeyCodeComplete);
          }
          else {
            if(IRCodeIndex >= 10) {
              IRCodeIndex = 0;
#ifdef COHABZ
              BZBuzzer(BZError, BZBLIRError);
#endif
            }
            else {
              if(IRCodeIndex == 0) IRCounter = IRCTimeOut;
              IRKeyCodeComplete.Code[IRCodeIndex] = KeyCode;
              IRCodeIndex++;
            }
          }
        }
      }
      else
        if(IRCodeIndex == 0 && (KeyCode == IRKCPlus || KeyCode == IRKCMinus)) {
          IRKeyCodeComplete.Code[0] = KeyCode;
          for(i = 1; i < 10; i++) IRKeyCodeComplete.Code[i] = 0;
          IRKeyCodeComplete.Length = 1;
          SMIRReceive(IRKeyCodeComplete);
        }
    }
  }
  else
    if(IRCodeLearn.Timeout == 0 && IRCodeLearn.Action < (1 << IRCodeSize)) {
      IRCodeLearn.Action = 1 << IRCodeSize;
#ifdef COHABZ
      BZBuzzer(BZError, BZBLIRError);
#endif
      SMSendIRLearnReady(IRCodeLearn.Modul, SMMTypeConfigIRLearnErr, 0, 0, IRCodeLearn.Action);
    }
}

void IRSample(void) {

  tWord tmp;                                    // for faster access

  tmp = IRRC5Tmp;
  if(++IRRC5Time > IRPulseMax) {                // count pulse time
    if(!(tmp & 0x4000) && tmp & 0x2000 && ((tmp >> 6 & 0x1F) == IRC.IRDevAddr || IRCodeLearn.Action < (1 << IRCodeSize))) {        // only if 14 bits received
      IRKeyExchange.Key = tmp;
      IRKeyExchange.Change = 1;
    }
    tmp = 0;
  }
  if((IRRC5Bit ^ *IRPort) & 1 << IRPin) {        // change detect
    IRRC5Bit = ~IRRC5Bit;                        // 0x00 -> 0xFF -> 0x00
    if(IRRC5Time < IRPulseMin)                    // to short
      tmp = 0;
    if(!tmp || IRRC5Time > IRPulseHalf) {        // start or long pulse time
      if(!(tmp & 0x4000))                        // not to many bits
        tmp <<= 1;                                // shift
      if(!(IRRC5Bit & 1 << IRPin))                // inverted bit
        tmp |= 1;                                // insert new bit
      IRRC5Time = 0;                            // count next pulse time
    }
  }
  IRRC5Tmp = tmp;
}

#endif
