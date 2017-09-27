////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                LCD 3x16                                             //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.11.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  07.11.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHALCD3X16

// Optionale Module ////////////////////////////////////////////////////////////

#include <halcd3x16.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define LCDMenueMarker 252


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void LCDInit(void) {
  DOGMInit();
}

#ifdef COHAGUI
void LCDPutMenue(tGUIMenue *pMenue) {

  tByte i;
  tByte n;

  LCDClear();
  if(pMenue->N > 2)
    n = 3;
  else
    n = pMenue->N;
  for(i = 0; i < n; i++) {
    if(pMenue->Top + i == pMenue->Select) {
      LCDGotoXY(0, i);
      LCDPutChar(LCDMenueMarker);
    }
    else
      LCDGotoXY(1, i);
    LCDPutString(pMenue->E[pMenue->Top + i].Name);
  }
}

#endif

#endif
