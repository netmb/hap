////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Abstrakt                                             //
// Version:              2.2 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  23.01.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAAM
#define HAAM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define AMCount 0x04


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Modul;
  tByte Addr;
} tAMIOAddr;

typedef struct {
  tByte Addr;
  tByte Type;
  tByte SModul;
  union {
    struct {
      tAMIOAddr OPUp;
      tAMIOAddr OPDown;
      tByte MaxTime;
      tByte Type;
    } RS;
    struct {
      tByte InModul;
      tByte InDevA;
      tByte InDevB;
      tByte InDevC;
      tAMIOAddr Out;
      tByte Speed;
    } DG;
  };
} tAMProp;

typedef struct {
  tByte AMConfigCount;
  tAMProp AM[AMCount];
} tAMC;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tAMC *AMGetConfPointer(void);
void AMSetConfDefaults(void);
void AMSetConf(tByte pAddr, tByte pValue0, tByte pValue1, tByte pValue2);
inline tByte AMGetDevType(tByte pDevIndex);
tByte AMMIInit(tByte pAMMType, tByte pAMMMask);
tAMProp *AMMIGetMProp(void);
tByte AMGetDevIndex(tByte pAddr);
tByte AMGetDevNumber(tByte pIndex, tByte pMask);


#endif
