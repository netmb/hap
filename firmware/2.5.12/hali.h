////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Logic Input                                          //
// Version:              2.1 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          24.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.02.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HALI
#define HALI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef tWord tLIPrellC[4];

typedef struct {
  tLIPrellC PrellC;
} tLIC;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tLIC *LIGetConfPointer(void);
void LISetConfDefaults(void);
inline void LISetConfPrellC(tByte pIndex, tWord pValue);
void LIInit(void);
inline void LISetSynchPoll(void);
void LIPoll(void);
inline tByte LIGetValue(tByte pX);
inline void LIDestroy(void);


#endif
