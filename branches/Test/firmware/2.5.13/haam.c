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


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAAM

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <haam.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define AMRSOPUp 0x00
#define AMRSOPDown 0x01
#define AMRSMaxTime 0x80
#define AMRSType 0x81
#define AMDGInModul 0x00
#define AMDGInDevA 0x01
#define AMDGInDevB 0x02
#define AMDGInDevC 0x03
#define AMDGOut 0x04
#define AMDGSpeed 0x05


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tAMC AMC;
tByte AMMIIndex;
tByte AMMIAMMType;
tByte AMMIAMMMask;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tAMC *AMGetConfPointer(void) {
  return &AMC;
}

void AMSetConfDefaults(void) {

  tByte i;

  AMC.AMConfigCount = 0;
  for(i = 0; i < AMCount; i++) {
    AMC.AM[i].Addr = 0;
    AMC.AM[i].Type = 0;
    AMC.AM[i].SModul = 0;
  }
}

void AMSetConf(tByte pAddr, tByte pValue0, tByte pValue1, tByte pValue2) {

  tByte i;

  if(pAddr == 0) {
    AMC.AM[AMC.AMConfigCount].Addr = pValue0;
    AMC.AM[AMC.AMConfigCount].Type = pValue1;
    AMC.AM[AMC.AMConfigCount].SModul = pValue2;
    AMC.AMConfigCount++;
  }
  else {
    i = 0;
    while(i < AMCount && AMC.AM[i].Addr != pAddr) i++;
    if(i < AMCount)
      switch(AMC.AM[i].Type) {
        case KMAMRS:
          switch(pValue0) {
            case AMRSOPUp:
              AMC.AM[i].RS.OPUp.Modul = pValue1;
              AMC.AM[i].RS.OPUp.Addr = pValue2;
              break;
            case AMRSOPDown:
              AMC.AM[i].RS.OPDown.Modul = pValue1;
              AMC.AM[i].RS.OPDown.Addr = pValue2;
              break;
            case AMRSMaxTime:
              AMC.AM[i].RS.MaxTime = pValue1;
              break;
            case AMRSType:
              AMC.AM[i].RS.Type = pValue1;
              break;
          }
          break;
        case KMAMDG:
          switch(pValue0) {
            case AMDGInModul:
              AMC.AM[i].DG.InModul = pValue1;
              break;
            case AMDGInDevA:
              AMC.AM[i].DG.InDevA = pValue1;
              break;
            case AMDGInDevB:
              AMC.AM[i].DG.InDevB = pValue1;
              break;
            case AMDGInDevC:
              AMC.AM[i].DG.InDevC = pValue1;
              break;
            case AMDGOut:
              AMC.AM[i].DG.Out.Modul = pValue1;
              AMC.AM[i].DG.Out.Addr = pValue2;
              break;
            case AMDGSpeed:
              AMC.AM[i].DG.Speed = pValue1;
              break;
          }
      }
  }
}

inline tByte AMGetDevType(tByte pDevIndex) {
  return AMC.AM[pDevIndex].Type;
}

tByte AMMIInit(tByte pAMMType, tByte pAMMMask) {

  tByte i;
  tByte n;

  AMMIIndex = 0;
  AMMIAMMType = pAMMType;
  AMMIAMMMask = pAMMMask;
  n = 0;
  for(i = 0; i < AMCount; i++)
    if((AMC.AM[i].Type & pAMMMask) == pAMMType) n++;
  return n;
}

tAMProp *AMMIGetMProp(void) {
  while((AMC.AM[AMMIIndex].Type & AMMIAMMMask) != AMMIAMMType) AMMIIndex++;
  AMMIIndex++;
  return &AMC.AM[AMMIIndex - 1];
}

tByte AMGetDevIndex(tByte pAddr) {

  tByte i;
  
  i = 0;
  while(AMC.AM[i].Addr != pAddr && i < AMCount) i++;
  if(AMC.AM[i].Addr == pAddr)
    return i | 0x80;
  else
    return 255;
}

tByte AMGetDevNumber(tByte pIndex, tByte pMask) {

  tByte i;
  tByte n;

  n = 0;
  pIndex = pIndex & 0x7F;
  for(i = 0; i < pIndex; i++)
    if((AMC.AM[i].Type & pMask) == (AMC.AM[pIndex].Type & pMask)) n++;
  return n;
}

#endif
