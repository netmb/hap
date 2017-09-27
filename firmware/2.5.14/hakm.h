////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Konfiguration                                        //
// Version:              2.2 (7)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          24.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAKM
#define HAKM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define KMIOSO 0x00
#define KMIOSOMask 0xFE
#define KMIOSO1 0x01
#define KMIOBZ 0x02
#define KMIOBZMask 0xFF
#define KMIOIR 0x03
#define KMIOIRMask 0xFF
#define KMIOFM 0x04
#define KMIOFMMask 0xFE
#define KMIOFMTrans 0x01
#define KMIOND 0x06
#define KMIONDMask 0xFF
#define KMIOSPISS 0x08
#define KMIOSPISSMask 0xFF
#define KMIOSPIMOSI 0x09
#define KMIOSPIMOSIMask 0xFF
#define KMIOSPIMISO 0x0A
#define KMIOSPIMISOMask 0xFF
#define KMIOSPISCK 0x0B
#define KMIOSPISCKMask 0xFF
#define KMIOTWISCL 0x0C
#define KMIOTWISCLMask 0xFF
#define KMIOTWISDA 0x0D
#define KMIOTWISDAMask 0xFF
#define KMIOSW 0x10
#define KMIOSWMask 0xF0
#define KMIOAI 0x20
#define KMIOAIMask 0xF8
#define KMIODI 0x28
#define KMIODIMask 0xF8
#define KMIOLCD 0x30
#define KMIOLCDMask 0xF0
#define KMIOLCDD0 0x00
#define KMIOLCDD1 0x01
#define KMIOLCDD2 0x02
#define KMIOLCDD3 0x03
#define KMIOLCDD4 0x04
#define KMIOLCDD5 0x05
#define KMIOLCDD6 0x06
#define KMIOLCDD7 0x07
#define KMIOLCDRW 0x08
#define KMIOLCDRS 0x09
#define KMIOLCDE 0x0A
#define KMIOLCDBL 0x0B
#define KMIODM 0x40
#define KMIODMMask 0xC0
#define KMIODMSD 0x01
#define KMIODMZL 0x02
#define KMIODMSW 0x04
#define KMIODMPAb 0x08
#define KMIOLI 0x80
#define KMIOLIMask 0x80
#define KMIOLIRE 0x01
#define KMIOLIFE 0x02
#define KMIOLIPrell 0x04
#define KMIOLIShort 0x08
#define KMIOLILong 0x0C
#define KMIOLIPullUp 0x10
#define KMIOLIForcePrell 0x20

#define KMAMRS 0xC0
#define KMAMRSMask 0xFF
#define KMAMDG 0xE0
#define KMAMDGMask 0xFF
#define KMAMGUI 0xF0
#define KMAMGUIMask 0xFF


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void KMSaveConfigStartMode(void);
void KMSaveConfig(void);
void KMLoadConfig(void);
inline tByte KMSSGetFlash(void);
inline void KMSSSetFlash(tByte pFlash);
inline void KMSSSetSize(tWord pSize);
inline void KMSetStartMode(tByte pStartMode);
void KMSetIO(tByte pPin, tByte pValue0, tByte pValue1);
void KMInit(void);
inline tByte KMGetDevType(tByte pDevIndex);
inline tByte KMGetDevAddr(tByte pDevIndex);
void KMSetDDR(tByte pIndex, tByte pIO);
tVPByte KMGetDDRAddress(tByte pIndex);
tVPByte KMGetPortAddress(tByte pIndex, tByte pIO);
tByte KMMIInit(tByte pKMIOType, tByte pKMIOMask);
void KMMIGetIOProp(tByte *pIndex, tByte *pProp, tByte *pAddr, tByte *pSModul);
tByte KMGetDevIndex(tByte pAddr);
tByte KMGetDevNumber(tByte pIndex, tByte pMask);


#endif
