////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Infrarot Fernbedienung                               //
// Version:              2.1 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  21.02.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAIR
#define HAIR


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define IRCodeSize 6

#define IRKC0 0
#define IRKC1 1
#define IRKC2 2
#define IRKC3 3
#define IRKC4 4
#define IRKC5 5
#define IRKC6 6
#define IRKC7 7
#define IRKC8 8
#define IRKC9 9
#define IRKCAllOn 12
#define IRKCAllOff 15
#define IRKCReserved 30
#define IRKCPlus 32
#define IRKCMinus 33
#define IRKCEnter 38
#define IRKCIgnore 62

#define IRKCVolMinus 17
#define IRKCVolPlus 16
#define IRKCFullScreen 46
#define IRKCMute 13
#define IRKCSource 34

#define IRLearnTimeout 400


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte IRDevAddr;
  tByte IRTranslate[1 << IRCodeSize];
} tIRC;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tIRC *IRGetConfPointer(void);
void IRSetConfDefaults(void);
inline void IRSetConf(tByte pDevAddr, tByte pIndex, tByte pTranslate);
void IRInit(void);
inline void IRCodeLearnInit(tByte pModul, tWord pTimeout, tByte pAction);
inline void IRSynch(void);
void IRPutKey(void);
void IRSample(void);


#endif
