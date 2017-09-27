////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Analog Input                                         //
// Version:              2.2 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          26.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAAI
#define HAAI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define AITCount 0x02


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord SRate;
  struct {
    tWord Value;
    tByte Hyst;
    tByte Flags;
  } T[AITCount];
} tAIProp;

typedef tAIProp tAIC[8];


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tAIC *AIGetConfPointer(void);
void AISetConfDefaults(void);
inline void AISetConfSRate(tByte pPin, tWord pSRate);
inline void AISetConfTValue(tByte pPin, tByte pT, tWord pValue);
inline void AISetConfTHystFlags(tByte pPin, tByte pT, tByte pHyst, tByte pFlags);
void AIInit(void);
void AISetValue(tByte pX, tByte pSelect, tWord pValue);
inline void AICounterInc(void);
void AISample(void);
tWord AIGetValue(tByte pX, tByte pSelect);
inline void AIDestroy(void);


#endif
