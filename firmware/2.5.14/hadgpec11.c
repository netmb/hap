////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Drehgeber PEC11                                      //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.11.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt ge�ndert am:  28.11.2006                                           //
// Zuletzt ge�ndert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHADGPEC11

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <haam.h>
#include <hadgpec11.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DGAUp 0
#define DGADown 1
#define DGBUp 2
#define DGBDown 3


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tAMProp *CP;
  tByte Event;
} tDGStatusElement;

typedef struct {
  tByte N;
  tDGStatusElement *E;
} tDGStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tDGStatus DGS;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void DGInit(void) {
  
  tByte i;

  DGS.N = AMMIInit(KMAMDG, KMAMDGMask);
  DGS.E = malloc(sizeof(tDGStatusElement) * DGS.N);
  for(i = 0; i < DGS.N; i++) {
    DGS.E[i].CP = AMMIGetMProp();
    DGS.E[i].Event = SMSCNOP;
  }
}

void DGProcessEvent(tByte pModul, tByte pDevice, tByte pEvent) {

  tByte i;
  tByte OutModul;
  tByte OutDevice;

  for(i = 0; i < DGS.N; i++) {
    if(DGS.E[i].CP->DG.InModul == pModul) {
      OutModul = DGS.E[i].CP->DG.Out.Modul;
      OutDevice = DGS.E[i].CP->DG.Out.Addr;
      if(DGS.E[i].CP->DG.InDevA == pDevice) {
        if(pEvent == 4) {
          if(DGS.E[i].Event == DGBUp)
            SMSetOutput(OutModul, OutDevice, SMSCLeft, 0, 0);
          DGS.E[i].Event = DGAUp;
        }
        else {
          if(DGS.E[i].Event == DGBDown)
            SMSetOutput(OutModul, OutDevice, SMSCLeft, 0, 0);
          DGS.E[i].Event = DGADown;
        }
	    }
      if(DGS.E[i].CP->DG.InDevB == pDevice) {
        if(pEvent == 4) {
          if(DGS.E[i].Event == DGAUp)
            SMSetOutput(OutModul, OutDevice, SMSCRight, 0, 0);
          DGS.E[i].Event = DGBUp;
        }
        else {
          if(DGS.E[i].Event == DGADown)
            SMSetOutput(OutModul, OutDevice, SMSCRight, 0, 0);
          DGS.E[i].Event = DGBDown;
        }
	    }
      if(DGS.E[i].CP->DG.InDevC == pDevice)
        SMSetOutput(OutModul, OutDevice, (pEvent >> 2 & 0x03) + 138, 0, 0);
    }
  }
}

inline void DGDestroy(void) {
  free(DGS.E);
}

#endif
