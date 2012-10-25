////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Switch                                               //
// Version:              2.1 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  12.12.2008                                           //
// Zuletzt geändert von: Carsten Wolff                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHASW

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hasw.h>

////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define SWSRatePrescale 1
#define SWSPwmTime 1200

////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Value;
  tWord Counter;
  tVPByte Port;
  tByte Pin;
  tByte Addr;
  tByte SModul;  
} tSWStatusElement;

typedef struct {
  tByte N;
  tSWStatusElement *E;
} tSWStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tSWStatus SWS;
tWord SWCounter;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void SWInit(void) {
  
  tByte i;
  tByte Index;

  SWS.N = KMMIInit(KMIOSW, KMIOSWMask);
  SWS.E = malloc(sizeof(tSWStatusElement) * SWS.N);
  for(i = 0; i < SWS.N; i++) {
    KMMIGetIOProp(&Index, 0, &SWS.E[i].Addr, &SWS.E[i].SModul);
    SWS.E[i].Port = KMGetPortAddress(Index, 1);
    SWS.E[i].Pin = Index & 0x07;
    SWS.E[i].Value = 0;
	SWS.E[i].Counter = 0;
    KMSetDDR(Index, 1);
  }
  SWCounter = 0;
}

inline tByte SWGetValue(tByte pX) {
  return SWS.E[pX].Value;
}

inline void SWCounterInc(void) {
  SWCounter++;
}

void SWPwm(void) {
   
   tByte i;
   tByte Value;
   int Ratio; 


  if(SWCounter >= SWSRatePrescale) {
    SWCounter = 0;
    for(i = 0; i < SWS.N; i++) {
      Value = SWS.E[i].Value;	
	  if(Value > 0 && Value < 100) {
	    Ratio = ( SWSPwmTime / 100 ) * Value;
	    if(SWS.E[i].Counter <= Ratio) 
		  *SWS.E[i].Port = *SWS.E[i].Port | 1 << SWS.E[i].Pin;
		else 
		  *SWS.E[i].Port = *SWS.E[i].Port & ~(1 << SWS.E[i].Pin);
		SWS.E[i].Counter++;
        if(SWS.E[i].Counter >= SWSPwmTime) SWS.E[i].Counter = 0;  
	  }
	}
  }
}


void SWSetValue(tByte pX, tByte pValue) {
  if(SWS.E[pX].Value == 0 || SWS.E[pX].Value == 100) 
    SWS.E[pX].Counter = 0;
  SWS.E[pX].Value = pValue;
  if(pValue >= 100)
    *SWS.E[pX].Port = *SWS.E[pX].Port | 1 << SWS.E[pX].Pin;  
  else if(pValue == 0) 
    *SWS.E[pX].Port = *SWS.E[pX].Port & ~(1 << SWS.E[pX].Pin);
  SMSendStatus(SWS.E[pX].SModul, SWS.E[pX].Addr, pValue, 0);    
}

inline void SWDestroy(void) {
  free(SWS.E);
}

#endif
