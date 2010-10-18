////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Digital Input                                        //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.03.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  07.03.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HADI
#define HADI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DITCount 0x02


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord SRate;
  tByte Type;
  struct {
    int Value;
    tByte Hyst;
    tByte Flags;
  } T[DITCount];
} tDIProp;

typedef tDIProp tDIC[8];


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tDIC *DIGetConfPointer(void);
void DISetConfDefaults(void);
inline void DISetConfSRate(tByte pPin, tWord pSRate);
inline void DISetConfType(tByte pPin, tByte pType);
inline void DISetConfTValue(tByte pPin, tByte pT, int pValue);
inline void DISetConfTHystFlags(tByte pPin, tByte pT, tByte pHyst, tByte pFlags);
void DIInit(void);
void DISetValue(tByte pX, tByte pSelect, tWord pValue);
inline void DICounterInc(void);
void DISample(void);
int DIGetValue(tByte pX, tByte pSelect);
inline void DIDestroy(void);


#endif
