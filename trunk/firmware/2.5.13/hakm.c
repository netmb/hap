////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Konfiguration                                        //
// Version:              2.2 (9)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          24.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  20.02.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

// Basis Module ////////////////////////////////////////////////////////////////

#include <avr/eeprom.h>
#include <avr/interrupt.h>
#include <avr/io.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

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

#ifdef COHALI
#include <hali.h>
#endif

#ifdef COHAAI
#include <haai.h>
#endif

#ifdef COHADI
#include <hadi.h>
#endif

#ifdef COHAAM
#include <haam.h>
#endif

#ifdef COHAAS
#include <haas.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define KMEEPCfgStartAdr 0x00
#define KMEEPCfgStartModeAdr 0x03

#define KMSMNormal 0xD9
#define KMSMFlushConfig 0xB3

#define KMADCBSS 0x0C
#define KMADCBMOSI 0x0D
#define KMADCBMISO 0x0E
#define KMADCBSCK 0x0F
#define KMADTWISCL 0x10
#define KMADTWISDA 0x11
#define KMADFMRC 0x18
#define KMADFMTM 0x19
#define KMADND 0x1A
#define KMADBZ 0x08
#define KMADIR 0x1C

#define KMSetIOFlag 0x20


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Flash;
  tWord Size;
} tKMSS;

typedef struct {
  tByte Type;
  tByte Addr;
  tByte SModul;
} tKMIO;

typedef struct {
  tKMSS SS;
  tByte StartMode;
  tKMIO IO[32];
} tKMC;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tKMC KMC;                                // Konfiguration
tByte KMMIIndex;
tByte KMMIKMIOType;
tByte KMMIKMIOMask;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void KMSaveConfigStartMode(void) {
  eeprom_write_block(&KMC, (void *)(KMEEPCfgStartAdr + KMEEPCfgStartModeAdr), 1);
}

void KMSaveConfig(void) {

  void *Addr;

  Addr = KMEEPCfgStartAdr;
  eeprom_write_block(&KMC, Addr, sizeof(tKMC));
  Addr += sizeof(tKMC);
  eeprom_write_block(SMGetConfPointer(), Addr, sizeof(tSMC));
  Addr += sizeof(tSMC);
#ifdef COHABZ
  eeprom_write_block(BZGetConfPointer(), Addr, sizeof(tBZC));
  Addr += sizeof(tBZC);
#endif
#ifdef COHAFM
  eeprom_write_block(FMGetConfPointer(), Addr, sizeof(tFMC));
  Addr += sizeof(tFMC);
#endif
#ifdef COHACB
  eeprom_write_block(CBGetConfPointer(), Addr, sizeof(tCBC));
  Addr += sizeof(tCBC);
#endif
#ifdef COHAIR
  eeprom_write_block(IRGetConfPointer(), Addr, sizeof(tIRC));
  Addr += sizeof(tIRC);
#endif
#ifdef COHALI
  eeprom_write_block(LIGetConfPointer(), Addr, sizeof(tLIC));
  Addr += sizeof(tLIC);
#endif
#ifdef COHAAI
  eeprom_write_block(AIGetConfPointer(), Addr, sizeof(tAIC));
  Addr += sizeof(tAIC);
#endif
#ifdef COHADI
  eeprom_write_block(DIGetConfPointer(), Addr, sizeof(tDIC));
  Addr += sizeof(tDIC);
#endif
#ifdef COHAAM
  eeprom_write_block(AMGetConfPointer(), Addr, sizeof(tAMC));
  Addr += sizeof(tAMC);
#endif
#ifdef COHAAS
  eeprom_write_block(ASGetConfPointer(), Addr, sizeof(tASC));
  Addr += sizeof(tASC);
#endif
}

void KMLoadConfig(void) {

  void *Addr;

  Addr = KMEEPCfgStartAdr;
  eeprom_read_block(&KMC, Addr, sizeof(tKMC));
  Addr += sizeof(tKMC);
  eeprom_read_block(SMGetConfPointer(), Addr, sizeof(tSMC));
  Addr += sizeof(tSMC);
#ifdef COHABZ
  eeprom_read_block(BZGetConfPointer(), Addr, sizeof(tBZC));
  Addr += sizeof(tBZC);
#endif
#ifdef COHAFM
  eeprom_read_block(FMGetConfPointer(), Addr, sizeof(tFMC));
  Addr += sizeof(tFMC);
#endif
#ifdef COHACB
  eeprom_read_block(CBGetConfPointer(), Addr, sizeof(tCBC));
  Addr += sizeof(tCBC);
#endif
#ifdef COHAIR
  eeprom_read_block(IRGetConfPointer(), Addr, sizeof(tIRC));
  Addr += sizeof(tIRC);
#endif
#ifdef COHALI
  eeprom_read_block(LIGetConfPointer(), Addr, sizeof(tLIC));
  Addr += sizeof(tLIC);
#endif
#ifdef COHAAI
  eeprom_read_block(AIGetConfPointer(), Addr, sizeof(tAIC));
  Addr += sizeof(tAIC);
#endif
#ifdef COHADI
  eeprom_read_block(DIGetConfPointer(), Addr, sizeof(tDIC));
  Addr += sizeof(tDIC);
#endif
#ifdef COHAAM
  eeprom_read_block(AMGetConfPointer(), Addr, sizeof(tAMC));
  Addr += sizeof(tAMC);
#endif
#ifdef COHAAS
  eeprom_read_block(ASGetConfPointer(), Addr, sizeof(tASC));
  Addr += sizeof(tASC);
#endif
}

inline tByte KMSSGetFlash(void) {
  return KMC.SS.Flash;
}

inline void KMSSSetFlash(tByte pFlash) {
  KMC.SS.Flash = pFlash;
}

inline void KMSSSetSize(tWord pSize) {
  KMC.SS.Size = pSize;
}

inline void KMSetStartMode(tByte pStartMode) {
  KMC.StartMode = pStartMode;
}

void KMSetIO(tByte pPin, tByte pValue0, tByte pValue1) {
  if(pPin & KMSetIOFlag)
    KMC.IO[pPin & 0x1F].SModul = pValue0;
  else {
    KMC.IO[pPin & 0x1F].Type = pValue0;
    KMC.IO[pPin & 0x1F].Addr = pValue1;
  }
}

void KMInit(void) {

  tByte i;

  cli();
  KMLoadConfig();
  if(KMC.StartMode != KMSMNormal) {
    for(i = 0; i < 32; i++) {
      KMC.IO[i].Type = KMIOSO;
      KMC.IO[i].Addr = i;
      KMC.IO[i].SModul = 0;
    }
    KMSetIO(16, KMIOTWISCL, KMADTWISCL);
    KMSetIO(17, KMIOTWISDA, KMADTWISDA);
    KMSetIO(26, KMIOND, KMADND);
#ifdef COHABZ
    KMSetIO(8, KMIOBZ, KMADBZ);
#endif
#ifdef COHAFM
    KMSetIO(24, KMIOFM, KMADFMRC);
    KMSetIO(25, KMIOFM | KMIOFMTrans, KMADFMTM);
#endif
#ifdef COHACB
    KMSetIO(12, KMIOSPISS, KMADCBSS);
    KMSetIO(13, KMIOSPIMOSI, KMADCBMOSI);
    KMSetIO(14, KMIOSPIMISO, KMADCBMISO);
    KMSetIO(15, KMIOSPISCK, KMADCBSCK);
#endif
#ifdef COHAIR
    KMSetIO(28, KMIOIR, KMADIR);
#endif
    if(KMC.StartMode != KMSMFlushConfig) {
      SMSetConfDefaults();
#ifdef COHABZ
      BZSetConfDefaults();
#endif
#ifdef COHAFM
      FMSetConfDefaults();
#endif
#ifdef COHACB
      CBSetConfDefaults();
#endif
    }
#ifdef COHAIR
    IRSetConfDefaults();
#endif
#ifdef COHALI
    LISetConfDefaults();
#endif
#ifdef COHAAI
    AISetConfDefaults();
#endif
#ifdef COHADI
    DISetConfDefaults();
#endif
#ifdef COHAAM
    AMSetConfDefaults();
#endif
#ifdef COHAAS
    ASSetConfDefaults();
#endif
  }
}

inline tByte KMGetDevType(tByte pDevIndex) {
  return KMC.IO[pDevIndex].Type;
}

inline tByte KMGetDevAddr(tByte pDevIndex) {
  return KMC.IO[pDevIndex].Addr;
}

void KMSetDDR(tByte pIndex, tByte pIO) {
  if((pIO & 0x01) == 0) {
    if(pIndex < 8) DDRA = DDRA & ~(1 << (pIndex & 0x07));
    else if (pIndex < 16) DDRB = DDRB & ~(1 << (pIndex & 0x07));
      else if (pIndex < 24) DDRC = DDRC & ~(1 << (pIndex & 0x07));
        else if (pIndex < 32) DDRD = DDRD & ~(1 << (pIndex & 0x07));
  }
  else {
    if(pIndex < 8) DDRA = DDRA | (1 << (pIndex & 0x07));
    else if (pIndex < 16) DDRB = DDRB  | (1 << (pIndex & 0x07));
      else if (pIndex < 24) DDRC = DDRC  | (1 << (pIndex & 0x07));
        else if (pIndex < 32) DDRD = DDRD  | (1 << (pIndex & 0x07));
  }
  if((pIO & 0x02) > 0) {
    if(pIndex < 8) PORTA = PORTA | (1 << (pIndex & 0x07));
    else if (pIndex < 16) PORTB = PORTB  | (1 << (pIndex & 0x07));
      else if (pIndex < 24) PORTC = PORTC  | (1 << (pIndex & 0x07));
        else if (pIndex < 32) PORTD = PORTD  | (1 << (pIndex & 0x07));
  }
  else {
    if(pIndex < 8) PORTA = PORTA & ~(1 << (pIndex & 0x07));
    else if (pIndex < 16) PORTB = PORTB & ~(1 << (pIndex & 0x07));
      else if (pIndex < 24) PORTC = PORTC & ~(1 << (pIndex & 0x07));
        else if (pIndex < 32) PORTD = PORTD & ~(1 << (pIndex & 0x07));
  }
}

tVPByte KMGetDDRAddress(tByte pIndex) {

  tVPByte tmp;

  tmp = 0;
  if(pIndex < 8) tmp = &DDRA;
  else if (pIndex < 16) tmp = &DDRB;
    else if (pIndex < 24) tmp = &DDRC;
      else if (pIndex < 32) tmp = &DDRD;
  return tmp;
}

tVPByte KMGetPortAddress(tByte pIndex, tByte pIO) {

  tVPByte tmp;

  tmp = 0;
  if(pIO == 0) {
    if(pIndex < 8) tmp = &PINA;
    else if (pIndex < 16) tmp = &PINB;
      else if (pIndex < 24) tmp = &PINC;
        else if (pIndex < 32) tmp = &PIND;
  }
  else {
    if(pIndex < 8) tmp = &PORTA;
    else if (pIndex < 16) tmp = &PORTB;
      else if (pIndex < 24) tmp = &PORTC;
        else if (pIndex < 32) tmp = &PORTD;
  }
  return tmp;
}

tByte KMMIInit(tByte pKMIOType, tByte pKMIOMask) {

  tByte i;
  tByte n;

  KMMIIndex = 0;
  KMMIKMIOType = pKMIOType;
  KMMIKMIOMask = pKMIOMask;
  n = 0;
  for(i = 0; i < 32; i++)
    if((KMC.IO[i].Type & pKMIOMask) == pKMIOType) n++;
  return n;
}

void KMMIGetIOProp(tByte *pIndex, tByte *pProp, tByte *pAddr, tByte *pSModul) {
  while((KMC.IO[KMMIIndex].Type & KMMIKMIOMask) != KMMIKMIOType) KMMIIndex++;
  *pIndex = KMMIIndex;
  if(pProp != 0) *pProp = KMC.IO[KMMIIndex].Type & ~KMMIKMIOMask;
  if(pAddr != 0) *pAddr = KMC.IO[KMMIIndex].Addr;
  if(pSModul != 0) *pSModul = KMC.IO[KMMIIndex].SModul;
  KMMIIndex++;
}

tByte KMGetDevIndex(tByte pAddr) {

  tByte i;
  
  i = 0;
  while(KMC.IO[i].Addr != pAddr && i < 32) i++;
  if(KMC.IO[i].Addr == pAddr)
    return i;
  else
#ifdef COHAAM
    return AMGetDevIndex(pAddr);
#endif
#ifndef COHAAM
    return 255;
#endif
}

tByte KMGetDevNumber(tByte pIndex, tByte pMask) {

  tByte i;
  tByte n;

  n = 0;
  if((pIndex & 0x80) == 0){
    for(i = 0; i < pIndex; i++)
      if((KMC.IO[i].Type & pMask) == (KMC.IO[pIndex].Type & pMask)) n++;
  }
#ifdef COHAAM
  else
    n = AMGetDevNumber(pIndex, pMask);
#endif
  return n;
}
