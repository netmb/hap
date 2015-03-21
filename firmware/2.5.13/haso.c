////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Static Output                                        //
// Version:              2.1 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          24.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  21.01.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <haso.h>


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void SOInit(void) {

  tByte i;
  tByte n;
  tByte Index;
  tVPByte Port;
  tByte Pin;
  tByte Prop;

  n = KMMIInit(KMIOSO, KMIOSOMask);
  for(i = 0; i < n; i++) {
    KMMIGetIOProp(&Index, &Prop, 0, 0);
	Port = KMGetPortAddress(Index, 1);
	Pin = Index & 0x07;
	KMSetDDR(Index, 1);
    if(Prop == KMIOSO1)
      *Port = *Port | (1 << Pin);
    else
      *Port = *Port & ~(1 << Pin);
  }
}
