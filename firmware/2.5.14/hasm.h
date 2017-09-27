////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Steuerung                                            //
// Version:              2.2 (6)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  05.02.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HASM
#define HASM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define SMIntIDNumberMask 0x0F
#define SMIntIDNumberBroadcast 0x0F
#define SMIntIDMediumMask 0x70
#define SMIntIDLB 0x00
#define SMIntIDFM 0x10
#define SMIntIDCB 0x20
#define SMIntIDMediumBroadcast 0x70
#define SMIntIDInvertMask 0x80
#define SMIntIDInvert 0x80
#define SMIntIDBroadcast 0x7F

#define SMMAUnconfigured 0x00
#define SMMAMulticast 0xF0
#define SMMABroadcast 0xFF

#define SMMTypeSet 0
#define SMMTypeSetAck 1
#define SMMTypeSetErr 2
#define SMMTypeQuery 8
#define SMMTypeQueryAck 9
#define SMMTypeQueryErr 10
#define SMMTypeStatus 16
#define SMMTypeStatusAck 17
#define SMMTypeStatusErr 18
#define SMMTypeMakro 24
#define SMMTypeMakroAck 25
#define SMMTypeMakroErr 26
#define SMMTypeEEPROM 28
#define SMMTypeEEPROMAck 29
#define SMMTypeEEPROMErr 30
#define SMMTypeControlProt 56
#define SMMTypeControlProtAck 57
#define SMMTypeControlProtErr 58
#define SMMTypeRawData 60
#define SMMTypeRawDataAck 61
#define SMMTypeRawDataErr 62
#define SMMTypeConfigIO 64
#define SMMTypeConfigIOAck 65
#define SMMTypeConfigIOErr 66
#define SMMTypeConfigIRAddr 68
#define SMMTypeConfigIRAddrAck 69
#define SMMTypeConfigIRAddrErr 70
#define SMMTypeConfigIRHotKeys 72
#define SMMTypeConfigIRHotKeysAck 73
#define SMMTypeConfigIRHotKeysErr 74
#define SMMTypeControl 76
#define SMMTypeControlAck 77
#define SMMTypeControlErr 78
#define SMMTypeConfigIRTrans 80
#define SMMTypeConfigIRTransAck 81
#define SMMTypeConfigIRTransErr 82
#define SMMTypeConfigIRLearn 84
#define SMMTypeConfigIRLearnAck 85
#define SMMTypeConfigIRLearnErr 86
#define SMMTypeDisplayData 88
#define SMMTypeDisplayAck 89
#define SMMTypeDisplayErr 90
#define SMMTypeDisplayControl 91
#define SMMTypeConfigAM 96
#define SMMTypeConfigAMAck 97
#define SMMTypeConfigAMErr 98
#define SMMTypeConfigAS 100
#define SMMTypeConfigASAck 101
#define SMMTypeConfigASErr 102
#define SMMTypeTCSet 120
#define SMMTypeTCSetAck 121
#define SMMTypeTCSetErr 122
#define SMMTypeTCSynchReq 123
#define SMMTypeMagicPacket 124
#define SMMTypeMagicPacketAck 125
#define SMMTypeMagicPacketErr 126
#define SMMTypeProtErr 127

#define SMSCIndexLow 128
#define SMSCStatusInvert 128
#define SMSCPlus 129
#define SMSCMinus 130
#define SMSCAllOn 131
#define SMSCAllOff 132
#define SMSCControlUp 133
#define SMSCControlDown 134
#define SMSCControlStop 135
#define SMSCControlStart 136
#define SMSCLeft 137
#define SMSCRight 138
#define SMSCPressShort 139
#define SMSCPressMedium 140
#define SMSCPressLong 141
#define SMSCRefresh 142
#define SMSCIndexHigh 142
#define SMSCNOP 255

#define SMPECNoResponse 1
#define SMPECDeviceBusy 2

#define SMEnquirerGUI 0xFF

#define SMControllerGUI 0x01
#define SMControllerIR 0x02
#define SMControllerEnd 0x02


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

#ifdef COHAIR
typedef struct {
  tByte Modul;
  tByte Addr;
} tSMIOAddr;
#endif

typedef struct {
  tByte ModulAddress;
  tWord MulticastGroups;
  tByte CCUAddress;
  tByte RecBufferLength;
  tByte BridgeMode;
  tByte TimeServer;
#ifdef COHAIR
  tSMIOAddr IRAddr[100];
  tWord IRHotKeys[10];
#endif
} tSMC;

#ifdef COHAIR
typedef struct {
  tByte Length;                        // Laenge des eingegebenen Codes (ohne Enter)
  tByte Code[10];                    // Code-Array
} tSMIRKeyCodeComplete;
#endif


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void SMSystemReset(void);
void SMResetExt(void);
inline tSMC *SMGetConfPointer(void);
void SMSetConfDefaults(void);
void SMInit(void);
inline tByte SMGetModulAddress(void);
inline tByte SMGetBridgeMode(void);
#ifdef COHAER
inline void SMResetCounterInc(void);
inline void SMResetCounterReset(void);
#endif
inline void SMExtSteuerStatusTimeoutDec(void);
inline void SMExtQueryStatusTimeoutDec(void);
void SMRecBufAdd(tByte pInt, const tMData *pData);
void SMSendStatus(tByte pModul, tByte pAddr, tWord pValue, tByte pExt);
void SMSendZMSynchReq(void);
void SMSendMakro(tWord pMakro);
#ifdef COHAIR
void SMSendIRLearnReady(tByte pModul, tByte pMType, tByte pDevAddr, tByte pIndex, tByte pTranslate);
#endif
void SMSendProtErr(tByte pCode, tByte pValue0, tByte pValue1, tByte pValue2);
void SMGetInput(tByte pEnquirer, tByte pModul, tByte pDevice, tByte pSelect, tMDataCode *pMData);
void SMSetOutput(tByte pModul, tByte pDevice, tByte pHW, tWord pDelay, tMDataCode *pMData);
void SMProcessMess(void);
#ifdef COHAIR
void SMIRReceive(tSMIRKeyCodeComplete pKC);
#endif
inline void SMDestroy(void);


#endif
