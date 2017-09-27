////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Zeit (Uhr)                                           //
// Version:              2.1 (6)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  12.02.2009                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

// Basis Module ////////////////////////////////////////////////////////////////

#include <avr/interrupt.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hazm.h>
#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#ifdef COHAFM
#include <hafm.h>
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

#ifdef COHADGPEC11
#include <hadgpec11.h>
#endif

#ifdef COHADGSTEC
#include <hadgstec.h>
#endif

#ifdef COHAGUI
#include <hagui.h>
#endif

#ifdef COHAAS
#include <haas.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Day;
  tByte Hour;
  tByte Minute;
  tByte Second;
  tByte Hundredth;
} tZMTime;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tZMTime ZMTime;
tByte ZMPrescaleCounter;
#ifndef COHADM
#ifdef COHAER
tVPByte ZMERPort;
tByte ZMERPin;
#endif
#endif


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void ZMInit(void) {

  tByte i;
  tByte Index;
  tByte N;
  
  N = KMMIInit(KMIOND, KMIONDMask);
  for(i = 0; i < N; i++) {
    KMMIGetIOProp(&Index, 0, 0, 0);
#ifndef COHADM
#ifdef COHAER
    ZMERPort = KMGetPortAddress(Index, 0);
    ZMERPin = Index & 0x07;
#endif
#endif
    KMSetDDR(Index, 2);
  }
  ZMTime.Day = 0;
  ZMTime.Hour = 0;
  ZMTime.Minute = 0;
  ZMTime.Second = 0;
  ZMTime.Hundredth = 0;
  TCCR0 = 1 << CS02;                // Divide by 256, Clockselect = CS02
  TIMSK = TIMSK | 1 << TOIE0;       // Aktiviere Timer 0 Overflow Interrupt
  TCCR2 = 1 << CS22;
  TIMSK = TIMSK | 1 << TOIE2;
  ZMPrescaleCounter = 0;
#ifdef COHADM
  MCUCR = 0x03;                     // Rising Edge INT0
  GICR = 0x40;                      // INT0 enable
#endif
}

inline void ZMSetTime(tByte pDay, tByte pHour, tByte pMinute, tByte pSecond, tByte pHundredth) {
  ZMTime.Day = pDay;
  ZMTime.Hour = pHour;
  ZMTime.Minute = pMinute;
  ZMTime.Second = pSecond;
  ZMTime.Hundredth = pHundredth;
}

inline tByte ZMGetDay(void) {
  return ZMTime.Day;
}

inline tByte ZMGetHour(void) {
  return ZMTime.Hour;
}

inline tByte ZMGetMinute(void) {
  return ZMTime.Minute;
}

inline tByte ZMGetSecond(void) {
  return ZMTime.Second;
}

inline tByte ZMGetHundredth(void) {
  return ZMTime.Hundredth;
}

ISR (TIMER0_OVF_vect) {
  TCNT0 = -2;  // 2 * 256 = 512 cycle
#ifdef COHAER
  SMResetCounterInc();
#endif
#ifdef COHAFM
  FMSynch();
#endif
#ifdef COHAIR
  IRSample();
#endif
#ifdef COHADM
  DMIncZCDVerifyC();
#endif
}

ISR (TIMER2_OVF_vect) {
  TCNT2 = -125;  // 125 * 64 = 8000 cycle
  ZMPrescaleCounter++;
  if(ZMPrescaleCounter == 15) {
    ZMPrescaleCounter = 0;
    ZMTime.Hundredth++;
    if(ZMTime.Hundredth == 100) {
      ZMTime.Hundredth = 0;
      ZMTime.Second++;
#ifdef COHADI
      DICounterInc();
#endif
#ifdef COHAGUI
      GUITimer();
#endif
#ifdef COHAAS
      ASPreScaleSelectInc();
#endif
      if(ZMTime.Second == 60) {
        ZMTime.Second = 0;
        ZMTime.Minute++;
#ifdef COHAAS
        ASPreScaleSelectInc();
#endif
        if(ZMTime.Minute == 60) {
          ZMTime.Minute = 0;
          ZMTime.Hour++;
#ifdef COHAAS
          ASPreScaleSelectInc();
#endif
          if(ZMTime.Hour == 24) {
            ZMTime.Hour = 0;
            ZMTime.Day++;
#ifdef COHAAS
            ASPreScaleSelectInc();
#endif
            if(ZMTime.Day == 7) {
              ZMTime.Day = 0;
#ifdef COHAAS
              ASPreScaleSelectInc();
#endif
            }
          }
        }
      }
    }
#ifndef COHADM
#ifdef COHAER
    if(*ZMERPort >> ZMERPin & 0x01) SMResetCounterReset();
#endif
#endif
    SMExtSteuerStatusTimeoutDec();
    SMExtQueryStatusTimeoutDec();
#ifdef COHABZ
    BZControl();
#endif
#ifdef COHAIR
    IRSynch();
#endif
#ifdef COHALI
    LISetSynchPoll();
#endif
#ifdef COHAAI
    AICounterInc();
#endif
#ifdef COHARS
    RSCounterInc();
#endif
#ifdef COHADG
    DGSpeedDec();
#endif
#ifdef COHAAS
    ASCounterInc();
#endif
  }
}

ISR (INT0_vect) {
#ifdef COHADM
  DMSynch();
#ifdef COHAER
  SMResetCounterReset();
#endif
#endif
}
