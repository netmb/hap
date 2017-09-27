////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Steuerung                                            //
// Version:              2.5 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  08.05.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>

#include <hatwi.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hazm.h>
#include <hasm.h>
#include <haso.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#ifdef COHAFM
#include <hafm.h>
#endif

#ifdef COHACB
#include <hacb.h>
#endif

#ifdef COHAIR
#include <hair.h>
#endif

#ifdef COHALCD2X16
#include <halcd2x16.h>
#endif

#ifdef COHALCD3X16
#include <halcd3x16.h>
#endif

#ifdef COHALI
#include <hali.h>
#endif

#ifdef COHAAI
#include <haai.h>
#endif

#ifdef COHADI
#include <hadi.h>
#endif

#ifdef COHASW
#include <hasw.h>
#endif

#ifdef COHADM
#include <hadm.h>
#endif

#ifdef COHAAM
#include <haam.h>
#endif

#ifdef COHARS
#include <hars.h>
#endif

#ifdef COHADGPEC11
#include <hadgpec11.h>
#endif

#ifdef COHADGSTEC
#include <hadgstec.h>
#endif

#ifdef COHAGUI
#include <hagui.h>
#endif

#ifdef COHAAS
#include <haas.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define SMResetDetect 46875
#define SMMCGDefault 0x8000 
#define SMRecBufLenDefault 4
#define SMAckTimeout 8
#define SMQueryTimeout 8

#define SMCCSystemReset 1
#define SMCCSystemFullReset 2
#define SMCCConfigReset 3
#define SMCCSetStartMode 4
#define SMCCSetModulAddress 5
#define SMCCSetCCUAddress 6
#define SMCCSetTimeServer 7
#define SMCCSaveConfig 8
#define SMCCLoadConfig 9
#define SMCCSetBridgeMode 10
#define SMCCSetREAddresses 11
#define SMCCSetFLANID 12
#define SMCCSetMCG 13
#define SMCCSetEncFlags 14
#define SMCCSetEncKey 15
#define SMCCSetBuzzerLevel 16
#define SMCCSetCLANID 18
#define SMCCSSGetFlash 24
#define SMCCSSSetSize 27
#define SMCCSSGetVersion 28
#define SMCCSSGetCO 30
#define SMCCSetLIPrell 32
#define SMCCSetDMControlDelay 36
#define SMCCSetDMZD 37
#define SMCCSetAIProp 64
#define SMCCSetAIPropMask 0xE0
#define SMCCSetAIPropT 64
#define SMCCSetAIPropTMask 0xF0 
#define SMCCSetAIPropSR 80
#define SMCCSetSMRecBufLength 96
#define SMCCSetDIProp 128
#define SMCCSetDIPropMask 0xE0
#define SMCCSetDIPropT 128
#define SMCCSetDIPropTMask 0xF0 
#define SMCCSetDIPropSR 144
#define SMCCSetDIPropType 145

#define SMCPStartProt 0
#define SMCPEndProt 1
#define SMCPStartPage 16

#define SMPTNoProt 0
#define SMPTSWDownload 16
#define SMPTGUICfgDownload 32

#define SMTWIBufLen 67

#define SMEEPROM256WriteAdr 0xA0
#define SMEEPROM256ReadAdr 0xA1
#define SMEEPROM256PageSize 64
#define SMEEPROM64WriteAdr 0xA8
#define SMEEPROM64ReadAdr 0xA9
#define SMEEPROM64PageSize 32

#define SMSSFlashed 0xFF
#define SMSSNotFlashed 0x00

#define SMHWAddressPointer 0x7FFC


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Int;
  tMData Data;
} tSMMessage;

typedef struct {
  tByte ExpectAck;
  tByte Controller;
  tByte Timeout;
  tMData MData;
} tSMExtSteuerStatus;

typedef struct {
  tByte ExpectAnswer;
  tByte Enquirer;
  tByte Timeout;
  tByte Modul;
  tByte Device;
} tSMExtQueryStatus;

#ifdef COHAIR
typedef struct {
  tByte Modul;
  tByte Device;
} tSMDevLastChange;
#endif


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tSMC SMC;
#ifdef COHAER
tWord SMResetCounter;
#endif
tSMMessage *SMRecBuf;
tByte SMRecBufFirst;
tByte SMRecBufLast;
tByte SMProtType;
tByte SMPTSWDLPacketCounter;
tByte SMPTSWDLChecksum[4];
tSMExtSteuerStatus SMExtSteuerStatus;
tSMExtQueryStatus SMExtQueryStatus;
#ifdef COHAIR
tSMDevLastChange SMDevLastChange;
#endif


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void SMSystemReset(void) {
  cli();
  TWIDestroy();
  SMDestroy();
#ifdef COHALI
  LIDestroy();
#endif
#ifdef COHAAI
  AIDestroy();
#endif
#ifdef COHADI
  DIDestroy();
#endif
#ifdef COHASW
  SWDestroy();
#endif
#ifdef COHADM
  DMDestroy();
#endif
#ifdef COHARS
  RSDestroy();
#endif
#ifdef COHADG
  DGDestroy();
#endif
#ifdef COHAAS
  ASDestroy();
#endif
  TIMSK = 0x00;
  TWIInit(SMTWIBufLen);
  ZMInit();
  SMInit();
#ifdef COHABZ
  BZInit();
#endif
#ifdef COHAFM
  FMInit();
#endif
#ifdef COHACB
  CBInit();
#endif
#ifdef COHAIR
  IRInit();
#endif
#ifdef COHALCD
  LCDInit();
#endif
#ifdef COHALI
  LIInit();
#endif
#ifdef COHAAI
  AIInit();
#endif
#ifdef COHADI
  DIInit();
#endif
  SOInit();
#ifdef COHASW
  SWInit();
#endif
#ifdef COHADM
  DMInit();
#endif
#ifdef COHARS
  RSInit();
#endif
#ifdef COHADG
  DGInit();
#endif
#ifdef COHAAS
  ASInit();
#endif
  sei();
#ifdef COHAGUI
  GUIInit();
#endif
  SMSendZMSynchReq();
}

void SMConfigReset(void) {
  KMSetStartMode(0);
  KMSaveConfigStartMode();
  KMInit();
  SMSystemReset();
}

#ifdef COHAER
void SMResetExt(void) {
  if(SMResetCounter >= SMResetDetect) {
#ifdef COHABZ
    BZBuzzer(BZPanic, BZBLSystem);
#endif
    SMConfigReset();
  }
}
#endif

inline tSMC *SMGetConfPointer(void) {
  return &SMC;
}

void SMSetConfDefaults(void) {
  SMC.ModulAddress = 0;
  SMC.MulticastGroups = SMMCGDefault;
  SMC.CCUAddress = 255;
  SMC.RecBufferLength = SMRecBufLenDefault;
  SMC.BridgeMode = 0;
  SMC.TimeServer = 0;
#ifdef COHAIR

  tByte i;

  for(i = 0; i < 100; i++) {
    SMC.IRAddr[i].Modul = 0;
    SMC.IRAddr[i].Addr = 0;
  }
  for(i = 0; i < 10; i++)
    SMC.IRHotKeys[i] = 0;
#endif
}

void SMInit(void) {

  tByte i;

  TWIInit(SMTWIBufLen);
#ifdef COHAER
  SMResetCounter = 0;
#endif
  SMRecBuf = malloc(sizeof(tSMMessage) * SMC.RecBufferLength);
  SMRecBufFirst = 255;
  SMRecBufLast = 0;
  SMProtType = SMPTNoProt;
  SMExtSteuerStatus.ExpectAck = 0;
  SMExtSteuerStatus.Timeout = 0;
  for(i = 0; i < MDataLength; i++)
    SMExtSteuerStatus.MData.Array[i] = 0;
  SMExtQueryStatus.ExpectAnswer = 0;
  SMExtQueryStatus.Enquirer = 0;
  SMExtQueryStatus.Timeout = 0;
  SMExtQueryStatus.Modul = 0;
  SMExtQueryStatus.Device = 0;
#ifdef COHAIR
  SMDevLastChange.Modul = 0;
  SMDevLastChange.Device = 0;  
#endif
}

inline tByte SMGetModulAddress(void) {
  return SMC.ModulAddress;
}

inline tByte SMGetBridgeMode(void) {
  return SMC.BridgeMode;
}

#ifdef COHAER
inline void SMResetCounterInc(void) {
  SMResetCounter++;
}

inline void SMResetCounterReset(void) {
  SMResetCounter = 0;
}
#endif

inline void SMExtSteuerStatusTimeoutDec(void) {
  if(SMExtSteuerStatus.Timeout > 0) SMExtSteuerStatus.Timeout--;
}

inline void SMExtQueryStatusTimeoutDec(void) {
  if(SMExtQueryStatus.Timeout > 0) SMExtQueryStatus.Timeout--;
}

inline tByte SMIsMCGMember(tByte pAddr) {
  return ((pAddr & SMMAMulticast) == SMMAMulticast && ((1 << (pAddr & ~SMMAMulticast)) & SMC.MulticastGroups) > 0);
}

void SMRecBufAdd(tByte pInt, const tMData *pData) {
  if(SMRecBufLast != SMRecBufFirst) {
    SMRecBuf[SMRecBufLast].Int = pInt;
    SMRecBuf[SMRecBufLast].Data = *pData;
    if(SMRecBufFirst == 255) SMRecBufFirst = SMRecBufLast;
    SMRecBufLast++;
    SMRecBufLast %= SMC.RecBufferLength;
  }
}

void SMSendMessage(tByte pInt, const tMData *pData) {
  if(pInt & SMIntIDInvertMask || (pInt & SMIntIDMediumMask) == SMIntIDMediumBroadcast) {
#ifdef COHAFM
    FMTransmit(pInt, pData);
#endif
#ifdef COHACB
    CBTransMessage(pInt, pData);
#endif
  }
  else
    switch(pInt & SMIntIDMediumMask) {
      case SMIntIDFM:
#ifdef COHAFM
        FMTransmit(pInt, pData);
#endif
        break;
      case SMIntIDCB:
#ifdef COHACB
        CBTransMessage(pInt, pData);
#endif
        break;
    }
}

void SMSendStatus(tByte pModul, tByte pAddr, tWord pValue, tByte pExt) {

  tMData TmpMData;

  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = pModul;
  TmpMData.Code.MType = SMMTypeStatus;
  TmpMData.Code.Device = pAddr;
  TmpMData.Code.Value0 = pValue;
  TmpMData.Code.Value1 = pValue >> 8;;
  TmpMData.Code.Value2 = pExt;
  if(pModul > 0) {
    if(pModul != SMC.ModulAddress)
      SMSendMessage(SMIntIDBroadcast, &TmpMData);
    if(pModul == SMC.ModulAddress || SMIsMCGMember(pModul))
      SMRecBufAdd(SMIntIDLB, &TmpMData);
  }
}

void SMSendZMSynchReq(void) {

  tMData TmpMData;
  
  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = SMMABroadcast;
  TmpMData.Code.MType = SMMTypeTCSynchReq;
  TmpMData.Code.Device = 0;
  TmpMData.Code.Value0 = 0;
  TmpMData.Code.Value1 = 0;
  TmpMData.Code.Value2 = 0;
  SMSendMessage(SMIntIDBroadcast, &TmpMData);
}

void SMSendMakro(tWord pMakro) {

  tMData TmpMData;
  
  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = SMMABroadcast;
  TmpMData.Code.MType = SMMTypeMakro;
  TmpMData.Code.Device = 0;
  TmpMData.Code.Value0 = pMakro;
  TmpMData.Code.Value1 = pMakro >> 8;
  TmpMData.Code.Value2 = 0;
#ifdef COHAAS
  ASRecStatusMess(SMC.ModulAddress, TmpMData.Code.Value1, TmpMData.Code.Value0, 0);
#endif
  SMSendMessage(SMIntIDBroadcast, &TmpMData);
}

#ifdef COHAIR
void SMSendIRLearnReady(tByte pModul, tByte pMType, tByte pDevAddr, tByte pIndex, tByte pTranslate) {

  tMData TmpMData;
  
  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = pModul;
  TmpMData.Code.MType = pMType;
  TmpMData.Code.Device = pIndex;
  TmpMData.Code.Value0 = pTranslate;
  TmpMData.Code.Value1 = pDevAddr;
  TmpMData.Code.Value2 = 0;

  SMSendMessage(SMIntIDBroadcast, &TmpMData);
}
#endif

void SMSendLocalSetErr(tByte pDevice, tByte pHW, tWord pDelay) {

  tMData TmpMData;
  
  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = SMC.ModulAddress;
  TmpMData.Code.MType = SMMTypeSetErr;
  TmpMData.Code.Device = pDevice;
  TmpMData.Code.Value0 = pHW;
  TmpMData.Code.Value1 = pDelay;
  TmpMData.Code.Value2 = pDelay >> 8;

  SMSendMessage(SMIntIDBroadcast, &TmpMData);
}

void SMSendProtErr(tByte pCode, tByte pValue0, tByte pValue1, tByte pValue2) {

  tMData TmpMData;
  
  TmpMData.Code.Source = SMC.ModulAddress;
  TmpMData.Code.Dest = SMC.CCUAddress;
  TmpMData.Code.MType = SMMTypeProtErr;
  TmpMData.Code.Device = pCode;
  TmpMData.Code.Value0 = pValue0;
  TmpMData.Code.Value1 = pValue1;
  TmpMData.Code.Value2 = pValue2;

  SMSendMessage(SMIntIDBroadcast, &TmpMData);
}

void SMGetInput(tByte pEnquirer, tByte pModul, tByte pDevice, tByte pSelect, tMDataCode *pMData) {

  tMData TmpMData;
  tByte DevIndex;
  tWord Result;

  if(pModul != SMC.ModulAddress) {
    TmpMData.Code.Source = SMC.ModulAddress;
    TmpMData.Code.Dest = pModul;
    TmpMData.Code.MType = SMMTypeQuery;
    TmpMData.Code.Device = pDevice;
    TmpMData.Code.Value0 = 0;
    TmpMData.Code.Value1 = 0;
    TmpMData.Code.Value2 = pSelect;
    SMExtQueryStatus.ExpectAnswer = 1;
    SMExtQueryStatus.Enquirer = pEnquirer;
    SMExtQueryStatus.Timeout = SMQueryTimeout;
    SMExtQueryStatus.Modul = pModul;
    SMExtQueryStatus.Device = pDevice;
    SMSendMessage(SMIntIDBroadcast, &TmpMData);
  }
  else {
    Result = 0;
    DevIndex = KMGetDevIndex(pDevice);
    if(DevIndex != 255) {
      if(DevIndex < 0x80) {
#ifdef COHALI
        if((KMGetDevType(DevIndex) & KMIOLIMask) == KMIOLI)
          Result = LIGetValue(KMGetDevNumber(DevIndex, KMIOLIMask));
#endif
#ifdef COHAAI
        if((KMGetDevType(DevIndex) & KMIOAIMask) == KMIOAI) {
          Result = AIGetValue(KMGetDevNumber(DevIndex, KMIOAIMask), pSelect);
          if(!(pMData || pEnquirer == SMEnquirerGUI))
            Result = Result >> 4;
        }
#endif
#ifdef COHADI
        if((KMGetDevType(DevIndex) & KMIODIMask) == KMIODI) {
          Result = DIGetValue(KMGetDevNumber(DevIndex, KMIODIMask), pSelect);
          if(!(pMData || pEnquirer == SMEnquirerGUI))
            Result = Result >> 4;
        }
#endif
#ifdef COHASW
        if((KMGetDevType(DevIndex) & KMIOSWMask) == KMIOSW)
          Result = SWGetValue(KMGetDevNumber(DevIndex, KMIOSWMask));
#endif
#ifdef COHADM
        if((KMGetDevType(DevIndex) & KMIODMMask) == KMIODM)
          Result = DMGetValue(KMGetDevNumber(DevIndex, KMIODMMask));
#endif
      }
      else {
#ifdef COHARS
        if((AMGetDevType(DevIndex & 0x7F) & KMAMRSMask) == KMAMRS)
          Result = RSGetValue(KMGetDevNumber(DevIndex, KMAMRSMask));
#endif
      }
    }
    if(pMData == 0) {
#ifdef COHAGUI
      if(pEnquirer == SMEnquirerGUI) GUIRecieveValue(pSelect, Result);
#endif
#ifdef COHAAS
      ASSetStatusElementValue(pEnquirer, Result);
#endif
    }
    else {
      pMData->MType = SMMTypeQueryAck;
      pMData->Value0 = Result & 0xFF;
      pMData->Value1 = Result >> 8;
    }
  }
}

void SMSetOutput(tByte pModul, tByte pDevice, tByte pHW, tWord pDelay, tMDataCode *pMData) {

  tMData TmpMData;
  tByte DevIndex;
#ifdef COHAAI
  tByte DevNumber;
#else
#ifdef COHADI
  tByte DevNumber;
#else
#ifdef COHASW
  tByte DevNumber;
#else
#ifdef COHADM
  tByte DevNumber;
#else
#ifdef COHARS
  tByte DevNumber;
#endif
#endif
#endif
#endif
#endif

  if((pModul == 0 && pDevice == 0) || pModul == SMMABroadcast)
    SMSendLocalSetErr(pDevice, pHW, pDelay);
  else
    if(pModul != SMC.ModulAddress) {
      TmpMData.Code.Source = SMC.ModulAddress;
      TmpMData.Code.Dest = pModul;
      TmpMData.Code.MType = SMMTypeSet;
      TmpMData.Code.Device = pDevice;
      TmpMData.Code.Value0 = pHW;
      TmpMData.Code.Value1 = pDelay;
      TmpMData.Code.Value2 = pDelay >> 8;
      SMExtSteuerStatus.ExpectAck = 1;
      SMExtSteuerStatus.Controller = (tWord)pMData;
      SMExtSteuerStatus.MData = TmpMData;
      SMExtSteuerStatus.MData.Code.Source = pModul;
      SMExtSteuerStatus.MData.Code.Dest = SMC.ModulAddress;
      SMExtSteuerStatus.MData.Code.MType = SMMTypeSet;
      SMExtSteuerStatus.Timeout = SMAckTimeout;
      SMSendMessage(SMIntIDBroadcast, &TmpMData);
    }
    else {
      DevIndex = KMGetDevIndex(pDevice);
#ifdef COHAAI
      if((KMGetDevType(DevIndex) & KMIOAIMask) == KMIOAI) {
        DevNumber = KMGetDevNumber(DevIndex, KMIOAIMask);
        if((tWord)pMData > SMControllerEnd)
          pMData->MType = SMMTypeSetAck;
        AISetValue(DevNumber, pHW, pDelay);
      }
#endif
#ifdef COHADI
      if((KMGetDevType(DevIndex) & KMIODIMask) == KMIODI) {
        DevNumber = KMGetDevNumber(DevIndex, KMIODIMask);
        if((tWord)pMData > SMControllerEnd)
          pMData->MType = SMMTypeSetAck;
        DISetValue(DevNumber, pHW, pDelay);
      }
#endif
      if((pHW > 100 && pHW < SMSCIndexLow) || pHW > SMSCIndexHigh || pDelay > 6500)
        if((tWord)pMData <= SMControllerEnd)
          SMSendLocalSetErr(pDevice, pHW, pDelay);
        else
          pMData->MType = SMMTypeSetErr;
      else {
        if(DevIndex == 255)
          SMSendLocalSetErr(pDevice, pHW, pDelay);
        else
          if((DevIndex & 0x80) == 0) {
            if((KMGetDevType(DevIndex) & KMIOSWMask) == KMIOSW) {
#ifdef COHASW
              DevNumber = KMGetDevNumber(DevIndex, KMIOSWMask);
              if((tWord)pMData > SMControllerEnd)
                pMData->MType = SMMTypeSetAck;
              if(pHW == SMSCStatusInvert)
                if(SWGetValue(DevNumber) > 0)
                  SWSetValue(DevNumber, 0);
                else
                  SWSetValue(DevNumber, 100);
              else
                if(pHW <= 100)
                  SWSetValue(DevNumber, pHW);
#endif
            }
            else
              if((KMGetDevType(DevIndex) & KMIODMMask) == KMIODM) {
#ifdef COHADM
                DevNumber = KMGetDevNumber(DevIndex, KMIODMMask);
                if((tWord)pMData > SMControllerEnd)
                  pMData->MType = SMMTypeSetAck;
                switch(pHW) {
                  case SMSCStatusInvert:
                    DMControlInvert(DevNumber);
                    break;
                  case SMSCPlus:
                    TmpMData.Code.Value0 = DMIncValue(DevNumber);
                    break;
                  case SMSCMinus:
                    TmpMData.Code.Value0 = DMDecValue(DevNumber);
                    break;
                  case SMSCControlUp:
                    DMControlUp(DevNumber);
                    break;
                  case SMSCControlDown:
                    DMControlDown(DevNumber);
                    break;
                  case SMSCControlStop:
                    DMControlStop(DevNumber);
                    break;
                  case SMSCControlStart:
                    DMControlStart(DevNumber);
                    break;
                  default:
                    if(pHW <= 100) DMSetValue(DevNumber, pHW, pDelay);
                }
#endif
              }
              else
                SMSendLocalSetErr(pDevice, pHW, pDelay);
          }
#ifdef COHAAM
          else
            if((AMGetDevType(DevIndex & 0x7F) & KMAMRSMask) == KMAMRS) {
#ifdef COHARS
              DevNumber = KMGetDevNumber(DevIndex, KMAMRSMask);
              if((tWord)pMData > SMControllerEnd)
                pMData->MType = SMMTypeSetAck;
              switch(pHW) {
                case SMSCStatusInvert:
                  RSControlInvert(DevNumber);
                  break;
                case SMSCControlUp:
                  RSControlUp(DevNumber);
                  break;
                case SMSCControlDown:
                  RSControlDown(DevNumber);
                  break;
                case SMSCControlStop:
                  RSControlStop(DevNumber);
                  break;
                case SMSCControlStart:
                  RSControlStart(DevNumber);
                  break;
                default:
                  if(pHW <= 100) RSSetValue(DevNumber, pHW);
              }
#endif
            }
            else
              if((AMGetDevType(DevIndex & 0x7F) & KMAMGUIMask) == KMAMGUI) {
#ifdef COHAGUI
                if((tWord)pMData > SMControllerEnd)
                  pMData->MType = SMMTypeSetAck;
                GUISetEvent(pHW, pDelay);
#endif
              }
#endif
        TmpMData.Code.Device = pDevice;
        if(pHW != SMSCPlus && pHW != SMSCMinus) TmpMData.Code.Value0 = pHW;
      }
    }
}

void SMProcessMess(void) {

  tByte i;
  tMDataCode *MData;
  tMData TmpMData;
#ifdef COHAES
  tMData TmpESMData;
#endif
  tByte Flag;
  tByte p;

  if(SMRecBufFirst != 255) {
    MData = &SMRecBuf[SMRecBufFirst].Data.Code;
    if(SMC.BridgeMode && MData->Dest != SMC.ModulAddress)
      SMSendMessage(SMRecBuf[SMRecBufFirst].Int | SMIntIDInvert, &SMRecBuf[SMRecBufFirst].Data);
    if(MData->Dest == SMC.ModulAddress || SMIsMCGMember(MData->Dest)) {
      if((MData->MType & 0x83) == 0) {
        TmpMData.Code = *MData;
        switch(MData->MType) {
          case SMMTypeSet:
            SMSetOutput(SMC.ModulAddress, MData->Device, MData->Value0, MData->Value1 + MData->Value2 * 256, &TmpMData.Code);
            break;
          case SMMTypeQuery:
            SMGetInput(0, SMC.ModulAddress, MData->Device, MData->Value2, &TmpMData.Code);
            break;
          case SMMTypeStatus:
#ifdef COHADG
            DGProcessEvent(MData->Source, MData->Device, MData->Value0);
#endif
#ifdef COHAAS
            ASRecStatusMess(MData->Source, MData->Device, BytesToWord(MData->Value0, MData->Value1), MData->Value2);
#endif
            break;
          case SMMTypeMakro:
#ifdef COHAAS
            ASRecStatusMess(MData->Source, MData->Value1, MData->Value0, 0);
#endif
            break;
#ifdef COHAES
          case SMMTypeEEPROM:
            if((MData->Device & 0xFE) == SMEEPROM256WriteAdr || (MData->Device & 0xFE) == SMEEPROM64WriteAdr) {
              if(MData->Device & 0x01) {
                TWIFillBufferAtIndex(0, MData->Device & 0xFE);
                TWIFillBufferAtIndex(1, MData->Value1);
                TWIFillBufferAtIndex(2, MData->Value0);
                TWISuppressStopSignal();
                TWIStartNormal(3);
                while(TWIBusy());
                TWIFillBufferAtIndex(0, MData->Device);
                TWIStartNormal(MData->Value2 + 1);
                while(TWIBusy());
                TmpESMData.Code.Source = SMC.ModulAddress;
                TmpESMData.Code.Dest = MData->Source;
                TmpESMData.Code.MType = SMMTypeEEPROMAck;
                i = 1;
                while(i <= MData->Value2) {
                  TmpESMData.Code.Device = TWIGetDataFromIndex(i++);
                  TmpESMData.Code.Value0 = TWIGetDataFromIndex(i++);
                  TmpESMData.Code.Value1 = TWIGetDataFromIndex(i++);
                  TmpESMData.Code.Value2 = TWIGetDataFromIndex(i++);
                  SMSendMessage(SMRecBuf[SMRecBufFirst].Int, &TmpESMData);
                }
                TmpMData.Code.MType = SMMTypeEEPROMAck;
              }
              else
                TmpMData.Code.MType = SMMTypeEEPROMErr;
            }
            else
              TmpMData.Code.MType = SMMTypeEEPROMErr;
            break;
#endif
          case SMMTypeControlProt:
            switch(MData->Device) {
              case SMCPStartProt:
                if(SMProtType == SMPTNoProt) {
                  SMProtType = MData->Value0;
                  TmpMData.Code.MType = SMMTypeControlProtAck;
                }
                else
                  TmpMData.Code.MType = SMMTypeControlProtErr;
                break;
              case SMCPEndProt:
                if(SMProtType != SMPTNoProt) {
                  TmpMData.Code.MType = SMMTypeControlProtAck;
                  if(SMProtType == SMPTSWDownload) KMSSSetFlash(SMSSNotFlashed);
                  SMProtType = SMPTNoProt;
                }
                else
                  TmpMData.Code.MType = SMMTypeControlProtErr;
                break;
              case SMCPStartPage:
                if(SMProtType == SMPTSWDownload || SMProtType == SMPTGUICfgDownload) {
                  TWIFillBufferAtIndex(0, MData->Value0);
                  TWIFillBufferAtIndex(1, MData->Value2);
                  TWIFillBufferAtIndex(2, MData->Value1);
                  TWISetBufPtr(3);
                  SMPTSWDLPacketCounter = 0;
                  SMPTSWDLChecksum[0] = MData->Device;
                  SMPTSWDLChecksum[1] = MData->Value0;
                  SMPTSWDLChecksum[2] = MData->Value1;
                  SMPTSWDLChecksum[3] = MData->Value2;
                }
                break;
            }
            break;
          case SMMTypeRawData:
            switch(SMProtType) {
              case SMPTSWDownload:
              case SMPTGUICfgDownload:
                SMPTSWDLChecksum[0] += MData->Device;
                SMPTSWDLChecksum[1] += MData->Value0;
                SMPTSWDLChecksum[2] += MData->Value1;
                SMPTSWDLChecksum[3] += MData->Value2;
                if((SMPTSWDLPacketCounter < 16 && SMProtType == SMPTSWDownload) || (SMPTSWDLPacketCounter < 8 && SMProtType == SMPTGUICfgDownload)) {
                  TWIFillBuffer(&MData->Device, 4);
                  SMPTSWDLPacketCounter++;
                }
                else
                  if(SMPTSWDLChecksum[0] | SMPTSWDLChecksum[1] | SMPTSWDLChecksum[2] | SMPTSWDLChecksum[3])
                    TmpMData.Code.MType = SMMTypeRawDataErr;
                  else {
                    if(SMProtType == SMPTSWDownload)
                      TWIStartNormal(67);
                    else
                      TWIStartNormal(35);
                    TmpMData.Code.MType = SMMTypeRawDataAck;
                  }
                break;
            }
            break;
          case SMMTypeConfigIO:
            KMSetIO(MData->Device, MData->Value0, MData->Value1);
            TmpMData.Code.MType = SMMTypeConfigIOAck;
            break;
#ifdef COHAIR
          case SMMTypeConfigIRAddr:
            SMC.IRAddr[MData->Device].Modul = MData->Value0;
            SMC.IRAddr[MData->Device].Addr = MData->Value1;
            TmpMData.Code.MType = SMMTypeConfigIRAddrAck;
            break;
          case SMMTypeConfigIRHotKeys:
            SMC.IRHotKeys[MData->Device] = MData->Value0 + MData->Value1 * 256;
            TmpMData.Code.MType = SMMTypeConfigIRHotKeysAck;
            break;
#endif
          case SMMTypeControl:
            switch(MData->Device) {
              case SMCCSetStartMode:
                KMSetStartMode(MData->Value0);
                break;
              case SMCCSetCCUAddress:
                SMC.CCUAddress = MData->Value0;
                break;
              case SMCCSetTimeServer:
                SMC.TimeServer = MData->Value0;
                break;
              case SMCCSaveConfig:
                KMSaveConfig();
                break;
              case SMCCLoadConfig:
                KMLoadConfig();
                break;
#ifdef COHAFM
              case SMCCSetREAddresses:
                FMSetConfRangeExt(MData->Value0, MData->Value1);
                break;
#endif
              case SMCCSetMCG:
                SMC.MulticastGroups = BytesToWord(MData->Value0, MData->Value1);
                break;
#ifdef COHAFM
              case SMCCSetEncKey:
                FMSetConfEncKey(MData->Value0, MData->Value1);
                break;
#endif
#ifdef COHABZ
              case SMCCSetBuzzerLevel:
                BZSetConfBuzzerLevel(BytesToWord(MData->Value0, MData->Value1));
                break;
#endif
              case SMCCSSGetFlash:
                TmpMData.Code.Value0 = KMSSGetFlash();
                break;
              case SMCCSSSetSize:
                KMSSSetSize(BytesToWord(MData->Value0, MData->Value1));
                break;
              case SMCCSSGetVersion:
                TmpMData.Code.Value0 = SVHAMajor;
                TmpMData.Code.Value1 = SVHAMinor;
                TmpMData.Code.Value2 = SVHAPhase;
                break;
              case SMCCSSGetCO:
                TmpMData.Code.Value1 = COHA >> (MData->Value0 * 8);
                break;
#ifdef COHALI
              case SMCCSetLIPrell:
                LISetConfPrellC(MData->Value0, BytesToWord(MData->Value1, MData->Value2));
                break;
#endif
#ifdef COHADM
              case SMCCSetDMControlDelay:
                DMSetControlDelay(MData->Value0);
                break;
              case SMCCSetDMZD:
                DMSetZD(BytesToWord(MData->Value0, MData->Value1));
                break;
#endif
              case SMCCSetSMRecBufLength:
                SMC.RecBufferLength = MData->Value0;
                break;
            }
#ifdef COHAAI
            if((MData->Device & SMCCSetAIPropMask) == SMCCSetAIProp) {
              for(i = 0; i < 32; i++)
                if(KMGetDevAddr(i) == MData->Value0) break;
              i &= 0x07;
              if((MData->Device & SMCCSetAIPropTMask) == SMCCSetAIPropT) {
                p = MData->Device & ~SMCCSetAIPropTMask;
                if((p & 0x01) == 0)
                  AISetConfTValue(i, p >> 1, BytesToWord(MData->Value1, MData->Value2));
                else
                  AISetConfTHystFlags(i, p >> 1, MData->Value1, MData->Value2);
              }
              if(MData->Device == SMCCSetAIPropSR)
                AISetConfSRate(i, BytesToWord(MData->Value1, MData->Value2));
            }
#endif
#ifdef COHADI
            if((MData->Device & SMCCSetDIPropMask) == SMCCSetDIProp) {
              for(i = 0; i < 32; i++)
                if(KMGetDevAddr(i) == MData->Value0) break;
              i &= 0x07;
              if((MData->Device & SMCCSetDIPropTMask) == SMCCSetDIPropT) {
                p = MData->Device & ~SMCCSetDIPropTMask;
                if((p & 0x01) == 0)
                  DISetConfTValue(i, p >> 1, BytesToWord(MData->Value1, MData->Value2));
                else
                  DISetConfTHystFlags(i, p >> 1, MData->Value1, MData->Value2);
              }
              if(MData->Device == SMCCSetDIPropSR)
                DISetConfSRate(i, BytesToWord(MData->Value1, MData->Value2));
              if(MData->Device == SMCCSetDIPropType)
                DISetConfType(i, MData->Value1);
            }
#endif
            TmpMData.Code.MType = SMMTypeControlAck;
            break;
#ifdef COHAIR
          case SMMTypeConfigIRTrans:
            IRSetConf(MData->Value1, MData->Device, MData->Value0);
            TmpMData.Code.MType = SMMTypeConfigIRTransAck;
            break;
          case SMMTypeConfigIRLearn:
            IRCodeLearnInit(MData->Source, IRLearnTimeout, MData->Value0);
            break;
#endif
#ifdef COHALCD
          case SMMTypeDisplayData:
            LCDPutChar(MData->Device);
            LCDPutChar(MData->Value0);
            LCDPutChar(MData->Value1);
            LCDPutChar(MData->Value2);
            TmpMData.Code.MType = SMMTypeDisplayAck;
            break;
          case SMMTypeDisplayControl:
            if(MData->Device != LCDInstNil) {
              LCDPutCtrlCode(MData->Device);
              LCDPutCtrlCode(MData->Value0);
              LCDPutCtrlCode(MData->Value1);
              LCDPutCtrlCode(MData->Value2);
            }
            else
              LCDBL(MData->Value0);
            TmpMData.Code.MType = SMMTypeDisplayAck;
            break;
#endif
#ifdef COHAAM
          case SMMTypeConfigAM:
            AMSetConf(MData->Device, MData->Value0, MData->Value1, MData->Value2);
            TmpMData.Code.MType = SMMTypeConfigAMAck;
            break;
#endif
#ifdef COHAAS
          case SMMTypeConfigAS:
            if(MData->Value2 == 255)
              ASSetConfDefaults();
            else
              ASSetConfObj(MData->Device, MData->Value0, MData->Value1);
            TmpMData.Code.MType = SMMTypeConfigASAck;
            break;
#endif
          case SMMTypeTCSet:
            ZMSetTime(MData->Value2 & 0x07, MData->Value2 >> 3, MData->Value1, MData->Value0, MData->Device);
            TmpMData.Code.MType = SMMTypeTCSetAck;
            break;
          case SMMTypeMagicPacket:
            if(MData->Value0 == pgm_read_byte_near(SMHWAddressPointer + 1) && MData->Value1 == pgm_read_byte_near(SMHWAddressPointer + 2) && MData->Value2 == pgm_read_byte_near(SMHWAddressPointer + 3)) {
              SMC.ModulAddress = MData->Device;
#ifdef COHACB
              CBInit();
#endif
              TmpMData.Code.MType = SMMTypeMagicPacketAck;
            }
            break;
        }
        TmpMData.Code.Source = SMC.ModulAddress;
        TmpMData.Code.Dest = MData->Source;
        if((TmpMData.Code.MType & 0x03) > 0) SMSendMessage(SMRecBuf[SMRecBufFirst].Int, &TmpMData);
        if(MData->MType == SMMTypeControl) {
          switch(MData->Device) {
            case SMCCSystemReset:
              SMSystemReset();
              break;
            case SMCCSystemFullReset:
              cli();
              wdt_enable(WDTO_15MS);
              while(1);
            case SMCCConfigReset:
              SMConfigReset();
              break;
            case SMCCSetModulAddress:
              SMC.ModulAddress = MData->Value0;
#ifdef COHACB
              CBInit();
#endif
              break;
            case SMCCSetBridgeMode:
              SMC.BridgeMode = MData->Value0;
              break;
#ifdef COHAFM
            case SMCCSetFLANID:
              FMSetConfFLANID(MData->Value0);
              break;
            case SMCCSetEncFlags:
              FMSetConfEncFlags(MData->Value0);
              break;
#endif
#ifdef COHACB
            case SMCCSetCLANID:
              CBSetConfCLANID(MData->Value0);
              CBInit();
              break;
#endif
          }
        }
      }
      else {
        if(SMExtQueryStatus.ExpectAnswer == 1 && MData->Source == SMExtQueryStatus.Modul && (MData->MType & 0xFC) == SMMTypeQuery && MData->Device == SMExtQueryStatus.Device) {
          SMExtQueryStatus.ExpectAnswer = 0;
          SMExtQueryStatus.Timeout = 0;
          if(MData->MType== SMMTypeQueryAck) {
#ifdef COHAGUI
            if(SMExtQueryStatus.Enquirer == SMEnquirerGUI)
              GUIRecieveValue(MData->Value2, BytesToWord(MData->Value0, MData->Value1));
#endif
#ifdef COHAAS
            ASSetStatusElementValue(SMExtQueryStatus.Enquirer, MData->Value1 << 4 | MData->Value0 >> 4);
#endif
          }
        }
        if(SMExtSteuerStatus.ExpectAck == 1) {
          Flag = 1;
          p = SMRecBuf[SMRecBufFirst].Data.Code.MType;
          SMRecBuf[SMRecBufFirst].Data.Code.MType &= 0xFC;
          for(i = 0; i < MDataLength; i++)
            if(SMRecBuf[SMRecBufFirst].Data.Array[i] != SMExtSteuerStatus.MData.Array[i]) Flag = 0;
          if(Flag == 1) {
            SMExtSteuerStatus.ExpectAck = 0;
            SMExtSteuerStatus.Timeout = 0;
#ifdef COHAGUI
            if(SMExtSteuerStatus.Controller == SMControllerGUI) {
              if(p == SMMTypeSetAck) {
#ifdef COHABZ
                BZBuzzer(BZAck, BZBLGUIAck);
#endif
                GUIRecieveValue(SMExtSteuerStatus.MData.Code.Value2, BytesToWord(SMExtSteuerStatus.MData.Code.Value0, SMExtSteuerStatus.MData.Code.Value1));
              }
#ifdef COHABZ
              else
                BZBuzzer(BZError, BZBLGUIError);
#endif
            }
#endif
          }
        }
        if(MData->MType == SMMTypeTCSynchReq && SMC.TimeServer == 1) {
          TmpMData.Code.Source = SMC.ModulAddress;
          TmpMData.Code.Dest = MData->Source;
          TmpMData.Code.MType = SMMTypeTCSet;
          TmpMData.Code.Device = ZMGetHundredth();
          TmpMData.Code.Value0 = ZMGetSecond();
          TmpMData.Code.Value1 = ZMGetMinute();
          TmpMData.Code.Value2 = ZMGetHour() << 3 | ZMGetDay();
          SMExtSteuerStatus.ExpectAck = 1;
          SMExtSteuerStatus.MData = TmpMData;
          SMExtSteuerStatus.MData.Code.Source = MData->Source;
          SMExtSteuerStatus.MData.Code.Dest = SMC.ModulAddress;
          SMExtSteuerStatus.MData.Code.MType = SMMTypeTCSetAck;
          SMExtSteuerStatus.Timeout = SMAckTimeout;
          SMSendMessage(SMRecBuf[SMRecBufFirst].Int, &TmpMData);
        }
      }
    }
    SMRecBufFirst++;
    SMRecBufFirst %= SMC.RecBufferLength;
    if(SMRecBufFirst == SMRecBufLast) SMRecBufFirst = 255;
  }
  if(SMExtQueryStatus.ExpectAnswer == 1 && SMExtQueryStatus.Timeout == 0) {
    SMExtQueryStatus.ExpectAnswer = 0;
    SMSendProtErr(SMPECNoResponse, SMExtQueryStatus.Modul, SMMTypeQuery, SMExtQueryStatus.Device);
  }
  if(SMExtSteuerStatus.ExpectAck == 1 && SMExtSteuerStatus.Timeout == 0) {
    SMExtSteuerStatus.ExpectAck = 0;
#ifdef COHABZ
    if(SMExtSteuerStatus.Controller == SMControllerGUI)
      BZBuzzer(BZError, BZBLGUIError);
#endif
    SMSendProtErr(SMPECNoResponse, SMExtSteuerStatus.MData.Code.Source, SMExtSteuerStatus.MData.Code.MType, SMExtSteuerStatus.MData.Code.Device);
  }
}

#ifdef COHAIR
void SMIRReceive(tSMIRKeyCodeComplete pKC) {

  tByte i;                                // Schleifenzaehler
  tByte Key;
  tWord Makro;
  tWord HW;                                // Helligkeitswert (temp.)

  if(pKC.Length == 1) {
    if(pKC.Code[0] < 10) {
#ifdef COHABZ
      BZBuzzer(BZAck, BZBLIRAck);
#endif
      SMSendMakro(SMC.IRHotKeys[pKC.Code[0]]);
    }
    else {
      switch(pKC.Code[0]) {
        case IRKCPlus:
          SMSetOutput(SMDevLastChange.Modul, SMDevLastChange.Device, SMSCPlus, 0, (tMDataCode *)SMControllerIR);
          break;
        case IRKCMinus:
          SMSetOutput(SMDevLastChange.Modul, SMDevLastChange.Device, SMSCMinus, 0, (tMDataCode *)SMControllerIR);
          break;
        case IRKCAllOn:
          SMSetOutput(SMC.ModulAddress, 0, SMSCAllOn, 0, (tMDataCode *)SMControllerIR);
          break;
        case IRKCAllOff:
          SMSetOutput(SMC.ModulAddress, 0, SMSCAllOff, 0, (tMDataCode *)SMControllerIR);
          break;
#ifdef COHABZ
        default:
          BZBuzzer(BZError, BZBLIRError);
#endif
      }
    }
  }
  else {
    if(pKC.Code[0] == IRKCReserved) {
      if(pKC.Length < 6 && pKC.Length > 1) {
        Makro = pKC.Code[1];
        for(i = 2; i < pKC.Length; i++)
          Makro = Makro * 10 + pKC.Code[i];
#ifdef COHABZ
        BZBuzzer(BZAck, BZBLIRAck);
#endif
        SMSendMakro(Makro);
      }
#ifdef COHABZ
      else
        BZBuzzer(BZError, BZBLIRError);
#endif
    }
    else {
      Key = pKC.Code[0] * 10 + pKC.Code[1];
      if(pKC.Length == 2)
        HW = SMSCStatusInvert;
      else
        if(pKC.Length == 3)
          if(pKC.Code[2] == 0)
            HW = 0;
          else
            HW = (pKC.Code[2] + 1) * 10;
        else
          HW = pKC.Code[2] * 100 + pKC.Code[3] * 10 + pKC.Code[4];
#ifdef COHABZ
      BZBuzzer(BZAck, BZBLIRAck);
#endif
      SMSetOutput(SMC.IRAddr[Key].Modul, SMC.IRAddr[Key].Addr, HW, (pKC.Code[5] * 10 + pKC.Code[6]) * 10, (tMDataCode *)SMControllerIR);
      SMDevLastChange.Modul = SMC.IRAddr[Key].Modul;
      SMDevLastChange.Device = SMC.IRAddr[Key].Addr;
    }
  }
}
#endif

inline void SMDestroy(void) {
  free(SMRecBuf);
}
