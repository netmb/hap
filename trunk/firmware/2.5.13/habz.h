////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Buzzer                                               //
// Version:              2.1 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  20.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HABZ
#define HABZ


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define BZAck 1
#define BZError 10
#define BZPanic 45

#define BZBLSystem 0
#define BZBLIRButton 4
#define BZBLIRAck 5
#define BZBLIRError 6
#define BZBLIRLearnAck 7
#define BZBLGUIButton 8
#define BZBLGUIAck 9
#define BZBLGUIError 10
#define BZBLGUITurn 11


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord BuzzerLevel;
} tBZC;

////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline tBZC *BZGetConfPointer(void);
inline void BZSetConfDefaults(void);
inline void BZSetConfBuzzerLevel(tWord pBuzzerLevel);
void BZInit(void);
void BZBuzzer(tByte pTime, tByte pLevel);
void BZControl(void);


#endif
