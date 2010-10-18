////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                GUI                                                  //
// Version:              1.0 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.11.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  11.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAGUI
#define HAGUI


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define GUIOCStateNormal 0
#define GUIOCStateEdit 16

#define GUITSStateNormal 0
#define GUITSStateEdit 16

#define GUINOP 0x7FFF


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Name[15];
  tWord Control;
} tGUIMenueEntry;

typedef struct {
  tByte N;
  tGUIMenueEntry *E;
  tByte Select;
  tByte Top;
} tGUIMenue;

typedef struct {
  tByte Modul;
  tByte Device;
  tByte Value;
  tByte ValueNew;
  tByte State;
  tByte Name[17];
} tGUIOutCtrl;

typedef struct {
  tByte Modul;
  tByte Device;
  int Value;
  int ValueNew;
  tByte State;
  tByte Refresh;
  tByte RefreshCounter;
  tByte Name[17];
} tGUIThermostat;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

inline void GUISetEvent(tByte pEvent, tByte pSpeed);
void GUIRecieveValue(tByte pSelect, int pValue);
void GUIInit(void);
void GUITimer(void);
void GUIControl(void);


#endif
