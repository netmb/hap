////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Hauptprogramm                                        //
// Version:              2.5 (10)                                             //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  12.02.2009                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#ifdef COHACB
#include <hacb.h>
#endif

#ifdef COHAIR
#include <hair.h>
#endif

#ifdef COHALI
#include <hali.h>
#endif

#ifdef COHAAI
#include <haai.h>
#endif

#ifdef COHADI
#include <hadi.h>
#endif

#ifdef COHADM
#include <hadm.h>
#endif

#ifdef COHARS
#include <hars.h>
#endif

#ifdef COHAGUI
#include <hagui.h>
#endif

#ifdef COHAAS
#include <haas.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Hauptprogramm                                                              //
////////////////////////////////////////////////////////////////////////////////

int main(void) {

  // Initialisation
  KMInit();
  SMSystemReset();

#ifdef COHABZ
  BZBuzzer(BZAck, BZBLSystem);
#endif

  // Hauptschleife
  for(;;) {
#ifdef COHAER
    SMResetExt();
#endif
    SMProcessMess();
#ifdef COHACB
    CBRecMessage();
#endif
#ifdef COHAIR
    IRPutKey();
#endif
#ifdef COHALI
    LIPoll();
#endif
#ifdef COHAAI
    AISample();
#endif
#ifdef COHADI
    DISample();
#endif
#ifdef COHADM
    DMRegulate();
#endif
#ifdef COHARS
    RSControl();
#endif
#ifdef COHAGUI
    GUIControl();
#endif
#ifdef COHAAS
    ASCalc();
#endif
  }
}
