////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Funk                                                 //
// Version:              2.2 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.02.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAFM
#define HAFM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define FMMLength 8
#define FMRangeExtCount 4


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte FLANID;
  tByte EncFlags;
  tByte EncKey[FMMLength];
  tByte RangeExt[FMRangeExtCount];
} tFMC;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tFMC *FMGetConfPointer(void);
void FMSetConfDefaults(void);
inline void FMSetConfFLANID(tByte pFLANID);
inline void FMSetConfEncFlags(tByte pEncFlags);
inline void FMSetConfEncKey(tByte pIndex, tByte pKey);
inline void FMSetConfRangeExt(tByte pIndex, tByte pExt);
void FMInit(void);
inline void FMSynch(void);
void FMTransmit(tByte pInt, const tMData *pData);


#endif
