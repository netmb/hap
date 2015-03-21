////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Autonome Steuerung                                   //
// Version:              2.1 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  16.08.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAAS
#define HAAS


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define ASObjCount 64


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef union {
  tByte Array[4];
  struct {
    tByte Type;
    tByte V0;
    tByte V1;
    tByte V2;
  } S;
} tASObj;

typedef struct {
  tASObj ASObj[ASObjCount];
} tASC;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tASC *ASGetConfPointer(void);
void ASSetConfDefaults(void);
inline void ASSetConfObj(tByte pObj, tByte pIndex, tByte pValue);
void ASInit(void);
inline void ASSetStatusElementValue(tByte pElement, tByte pValue);
inline void ASCounterInc(void);
inline void ASPreScaleSelectInc(void);
void ASRecStatusMess(tByte pModul, tByte pAddr, tWord pValue, tByte pExt);
void ASCalc(void);
inline void ASDestroy(void);


#endif
