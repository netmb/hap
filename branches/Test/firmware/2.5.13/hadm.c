////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Dimmer                                               //
// Version:              2.2 (8)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  28.09.2011                                           //
// Zuletzt geändert von: Carsten Wolff                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHADM

// Basis Module ////////////////////////////////////////////////////////////////

#include <math.h>
#include <stdlib.h>
#include <avr/interrupt.h>
#include <avr/io.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#include <hadm.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DMTicsProHalbwelle 15000
#define DMTicsSynchDiff -300          // Nulldurchgangsverschiebung        
#define DMSteps 255
#define DMSoftDelay 3
#define DMPlusMinusSteps 2
#define DMControlDelayDef 60
#define DMZDDef 60
#define DMZCDVerifyTol 10             // Nulldurchgangstoleranz  
#define DMMaxHW 240                   // Maximale Helligkeit
#define DMControlFlag 0x80


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tWord HW;                           // Helligkeitswert (0 - 63)
  tWord HWNew;                        // Neuer Helligkeitswert (0 - 63)
  tByte ValueInvert;
  tWord Delay;                        // Regelverzoegerung (Init DC)
  tWord DC;                           // Delay-Counter
  tWord Step;
  tVPByte Port;
  tByte Pin;
  tByte Prop;
  tByte Addr;
  tByte SModul;
} tDMStatusElement;

typedef struct {
  tByte N;                            // Anzahl der Dimmerstufen
  tDMStatusElement *E;                // Eigenschaften eines Dimmerausgangs
  tByte ControlDelay;
  tWord ZD;
} tDMStatus;

typedef struct {
  int Start;
  tByte X;
} tDMZZPStart[2];

typedef struct {
  int Stop;
  tByte X;
} tDMZZPStop[2];


////////////////////////////////////////////////////////////////////////////////
// Konstanten                                                                 //
////////////////////////////////////////////////////////////////////////////////

const tWord cDMZTol = 60;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tDMStatus DMS;                        // Interner Status des Dimmermoduls
tDMZZPStart *DMZStart;                // Zuendzeitpunkte Start
tDMZZPStop *DMZStop;                  // Zuendzeitpunkte Stop
tByte DMZCStart;                      // Counter fuer Zuendzeitpunkte
tByte DMZCStop;                       // Counter fuer Zuendzeitpunkte
tByte DMZA;
tByte DMSynchReg;                     // Zeitsynch. der Regulate-Fkt.
tByte DMSynchZZP;                     // Synch. zur Umschaltung der Timertabelle
tByte DMSetZZPActiv;                  // -Wert setzen- Funktion aktiv
int DMZCDVerifyC;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline void DMSetControlDelay(tByte pDelay) {
  DMS.ControlDelay = pDelay;
}

inline void DMSetZD(tWord pDelay) {
  DMS.ZD = pDelay;
}

void DMInit(void) {
  
  tByte i;
  tByte Index;

  DMSynchReg = 0;
  DMS.N = KMMIInit(KMIODM, KMIODMMask);
  DMS.E = malloc(sizeof(tDMStatusElement) * DMS.N);
  for(i = 0; i < DMS.N; i++) {
    KMMIGetIOProp(&Index, &DMS.E[i].Prop, &DMS.E[i].Addr, &DMS.E[i].SModul);
    DMS.E[i].Port = KMGetPortAddress(Index, 1);
    DMS.E[i].Pin = Index & 0x07;
    DMS.E[i].HW = 0;
    DMS.E[i].HWNew = 0;
    DMS.E[i].ValueInvert = 100;
    DMS.E[i].Delay = 0;
    DMS.E[i].DC = 0;
    DMS.E[i].Step = 1;
    KMSetDDR(Index, 1);
  }
  DMS.ControlDelay = DMControlDelayDef;
  DMS.ZD = DMZDDef;
  DMZStart = malloc(sizeof(tDMZZPStart) * (DMS.N + 1));
  DMZStop = malloc(sizeof(tDMZZPStop) * (DMS.N + 1));
  for(i = 0; i < DMS.N; i++) {
    DMZStart[i][0].Start = 0;
	DMZStart[i][0].X = i;
	DMZStart[i][1] = DMZStart[i][0];
    DMZStop[i][0].Stop = DMS.ZD;
 	DMZStop[i][0].X = i;
 	DMZStop[i][1] = DMZStop[i][0];
  }    
  DMZStart[DMS.N][0].Start = 0x7FFF;
  DMZStart[DMS.N][1] = DMZStart[DMS.N][0];
  DMZStop[DMS.N][0].Stop = 0x7FFF;
  DMZStop[DMS.N][1] = DMZStop[DMS.N][0];
  DMZA = 0;
  DMSynchZZP = 0;
  
  // Timer1 initialisieren
  TCCR1B = 0x02;                    // CS10 = 2 (Prescale: 8)
  TIMSK = TIMSK | 1 << OCIE1A;
  TIMSK = TIMSK | 1 << OCIE1B;
  TIMSK = TIMSK | 1 << TOIE1;
}

int DMCalcZZPPAn(double px) {

  int tmp;
  
//  tmp = ceil(DMTicsProHalbwelle / M_PI * acos(2 * (px * DMMaxHW / DMSteps) / DMSteps - 1));
  tmp = ceil(DMTicsProHalbwelle * pow(acos(2 * pow((px * DMMaxHW / DMSteps) / DMSteps, 0.7) - 1) / M_PI, 0.9));
  return tmp - DMTicsProHalbwelle;
}

int DMCalcZZPPAb(double px) {

  int tmp;

//  tmp = ceil(DMTicsProHalbwelle / M_PI * acos(2 * (px * DMMaxHW / DMSteps) / DMSteps - 1));
  tmp = ceil(DMTicsProHalbwelle * pow(acos(2 * pow((px * DMMaxHW / DMSteps) / DMSteps, 0.7) - 1) / M_PI, 0.9));
  return -tmp;
}

void DMSetZZP(int pStart, int pStop, tByte pX) {

  tByte i;
  tByte s;
  tByte n;
  int tmp;
 
  DMSetZZPActiv = 1; // Sperre setzen wenn Funktion aktiv ist
  
  if(pStart > pStop) pStop = pStart;
  // Start und Stopzeit bei Ãberlauf korrigieren
  tmp = pStart - DMTicsSynchDiff;
  if(tmp > 0) pStart = DMTicsSynchDiff - DMTicsProHalbwelle + tmp;
  tmp = pStop - DMTicsSynchDiff;
  if(tmp > 0) pStop = DMTicsSynchDiff - DMTicsProHalbwelle + tmp;
  // Beim ersten Aufruf pro Halbwelle die aktuelle Timertabelle kopieren
  if(DMSynchZZP == 0) {
    for(n = 0; n < DMS.N; n++) DMZStart[n][!DMZA] = DMZStart[n][DMZA];
    for(n = 0; n < DMS.N; n++) DMZStop[n][!DMZA] = DMZStop[n][DMZA];
    DMSynchZZP = 1;
  }
  i = 0;
  // Startzeitpunkt einfügen
  while(pX != DMZStart[i][!DMZA].X) i++;
  s = 0;
  while(pStart > DMZStart[s][!DMZA].Start) s++;
  if(s > i) {
    s--;
    for(n = i; n < s; n++) DMZStart[n][!DMZA] = DMZStart[n + 1][!DMZA];
  }
  else
    for(n = i; n > s; n--) DMZStart[n][!DMZA] = DMZStart[n - 1][!DMZA];
  DMZStart[s][!DMZA].Start = pStart;
  DMZStart[s][!DMZA].X = pX;
  
  // Stoppzeitpunkt einfügen
  i = 0;
  while(pX != DMZStop[i][!DMZA].X) i++;
  s = 0;
  while(pStop > DMZStop[s][!DMZA].Stop) s++;
  if(s > i) {
    s--;
    for(n = i; n < s; n++) DMZStop[n][!DMZA] = DMZStop[n + 1][!DMZA];
  }
  else
    for(n = i; n > s; n--) DMZStop[n][!DMZA] = DMZStop[n - 1][!DMZA];
  DMZStop[s][!DMZA].Stop = pStop;
  DMZStop[s][!DMZA].X = pX;
  
  DMSetZZPActiv = 0; // Sperre aufheben
}

void DMSetValue(tByte pX, tByte pPHW, tWord pDelay) {

  tWord HW;
  tWord HDiff;
  tWord Delay;
  int ZZP;

  if(pPHW == 0 && DMGetValue(pX) > 0) DMS.E[pX].ValueInvert = DMGetValue(pX); // Wert speichern
  if((DMS.E[pX].Prop & KMIODMSD) == KMIODMSD && pDelay < DMSoftDelay)
    Delay = DMSoftDelay;
  else
    if((DMS.E[pX].Prop & KMIODMSW) == KMIODMSW)
      Delay = 0;
    else
      Delay = pDelay;
  if((DMS.E[pX].Prop & KMIODMSW) == KMIODMSW && pPHW > 0)
    HW = DMSteps;
  else
    HW = pPHW * DMSteps / 100;
  if(Delay == 0) {
    DMS.E[pX].HW = HW;
    if(DMS.E[pX].Prop & KMIODMPAb)
      DMSetZZP(-DMTicsProHalbwelle, DMCalcZZPPAb(HW), pX);
    else if((DMS.E[pX].Prop & KMIODMZL) == 0) {
      ZZP = DMCalcZZPPAn(HW);
      DMSetZZP(ZZP, ZZP + DMS.ZD, pX);
    }
    else {
      ZZP = DMCalcZZPPAn(HW);
      DMSetZZP(ZZP, 0, pX);
    }
  }
  DMS.E[pX].HWNew = HW;
  if(DMS.E[pX].HW > DMS.E[pX].HWNew)
    HDiff = DMS.E[pX].HW - DMS.E[pX].HWNew;
  else
    HDiff = DMS.E[pX].HWNew - DMS.E[pX].HW;
  DMS.E[pX].Delay = Delay * 10 / HDiff;
  DMS.E[pX].DC = Delay * 10 / HDiff;
  DMS.E[pX].Step = HDiff / Delay / 10 + 1;
  SMSendStatus(DMS.E[pX].SModul, DMS.E[pX].Addr, pPHW, 0);
}

tByte DMIncValue(tByte pX) {

  short int HW;

  HW = DMGetValue(pX);
  if(HW != 100) {
    HW = HW + DMPlusMinusSteps;
    if(HW > 100) HW = 100;
    DMSetValue(pX, HW, 0);
  }
  return HW;
}

tByte DMDecValue(tByte pX) {

  short int HW;

  HW = DMGetValue(pX);
  if(HW != 0) {
    HW = HW - DMPlusMinusSteps;
    if(HW < 0) HW = 0;
    DMSetValue(pX, HW, 0);
  }
  return HW;
}

void DMControlInvert(tByte pX) {
  if(DMGetValue(pX) > 0) {
    DMS.E[pX].ValueInvert = DMGetValue(pX);
    DMSetValue(pX, 0, 0);
  }
  else
    DMSetValue(pX, DMS.E[pX].ValueInvert, 0);
}

void DMControlUp(tByte pX) {
  DMSetValue(pX, 100, ((tWord)DMS.ControlDelay * (100 - DMGetValue(pX))) / 100);
}

void DMControlDown(tByte pX) {
  DMSetValue(pX, 0, ((tWord)DMS.ControlDelay * DMGetValue(pX)) / 100);
}

void DMControlStop(tByte pX) {
  DMS.E[pX].HWNew = DMS.E[pX].HW;
  SMSendStatus(DMS.E[pX].SModul, DMS.E[pX].Addr, DMGetValue(pX), 0);
}

void DMControlStart(tByte pX) {
  if(DMS.E[pX].Prop & DMControlFlag)
    DMControlDown(pX);
  else
    DMControlUp(pX);
  DMS.E[pX].Prop ^= DMControlFlag;
}

tByte DMGetValue(tByte pX) {
  return (float)DMS.E[pX].HW * 100 / DMSteps + .5;
}

void DMRegulate(void) {

  tByte i;                            // Schleifenzaehler
  int ZZP;

  if(DMSynchReg == 1) {
    for(i = 0; i < DMS.N; i++)
      if(DMS.E[i].DC == 0) {
        if(DMS.E[i].HW < DMS.E[i].HWNew) {
          if(DMS.E[i].HW + DMS.E[i].Step < DMS.E[i].HWNew)
            DMS.E[i].HW = DMS.E[i].HW + DMS.E[i].Step;
          else
            DMS.E[i].HW = DMS.E[i].HWNew;
          if(DMS.E[i].Prop & KMIODMPAb)
            DMSetZZP(-DMTicsProHalbwelle, DMCalcZZPPAb(DMS.E[i].HW), i);
          else if((DMS.E[i].Prop & KMIODMZL) == 0) {
            ZZP = DMCalcZZPPAn(DMS.E[i].HW);
            DMSetZZP(ZZP, ZZP + DMS.ZD, i);
          }
          else {
            ZZP = DMCalcZZPPAn(DMS.E[i].HW);
            DMSetZZP(ZZP, 0, i);
          }
          if(DMS.E[i].HW == DMSteps) DMS.E[i].Prop |= DMControlFlag;
        }    
        else
          if(DMS.E[i].HW > DMS.E[i].HWNew) {
            if(DMS.E[i].HWNew + DMS.E[i].Step < DMS.E[i].HW)
              DMS.E[i].HW = DMS.E[i].HW - DMS.E[i].Step;
            else
              DMS.E[i].HW = DMS.E[i].HWNew;
            if(DMS.E[i].Prop & KMIODMPAb)
              DMSetZZP(-DMTicsProHalbwelle, DMCalcZZPPAb(DMS.E[i].HW), i);
            else if((DMS.E[i].Prop & KMIODMZL) == 0) {
              ZZP = DMCalcZZPPAn(DMS.E[i].HW);
              DMSetZZP(ZZP, ZZP + DMS.ZD, i);
            }
            else {
              ZZP = DMCalcZZPPAn(DMS.E[i].HW);
              DMSetZZP(ZZP, 0, i);
            }
            if(DMS.E[i].HW == 0) DMS.E[i].Prop &= ~DMControlFlag;
          }
        DMS.E[i].DC = DMS.E[i].Delay;
      }
      else
        DMS.E[i].DC--;
    DMSynchReg = 0;
  }
}

ISR (TIMER1_COMPA_vect) {
  while(OCR1A >= DMZStart[DMZCStart][DMZA].Start - cDMZTol && DMZCStart < DMS.N) {
    if(DMS.E[DMZStart[DMZCStart][DMZA].X].HW > 0)
      *DMS.E[DMZStart[DMZCStart][DMZA].X].Port |= 1 << DMS.E[DMZStart[DMZCStart][DMZA].X].Pin;
    DMZCStart++;
  }
  OCR1A = DMZStart[DMZCStart][DMZA].Start;
}

ISR (TIMER1_COMPB_vect) {
  while(OCR1B >= DMZStop[DMZCStop][DMZA].Stop - cDMZTol && DMZCStop < DMS.N) {
    *DMS.E[DMZStop[DMZCStop][DMZA].X].Port &= ~(1 << DMS.E[DMZStop[DMZCStop][DMZA].X].Pin);
    DMZCStop++;
  }
  OCR1B = DMZStop[DMZCStop][DMZA].Stop;
}


ISR (TIMER1_OVF_vect) {

  tByte i;

  for(i = 0; i < DMS.N; i++)
    *DMS.E[i].Port &= ~(1 << DMS.E[i].Pin);
}

inline void DMSynch(void) {
// Pro Halbwelle zählt DMZCDVerifyC um 234 hoch 
  if(abs(DMZCDVerifyC) <= DMZCDVerifyTol || DMZCDVerifyC > 2344) {
    DMZCDVerifyC = -234;
    TCNT1 = DMTicsSynchDiff - DMTicsProHalbwelle;
    DMZCStart = 0;
    DMZCStop = 0;
    if(DMSynchZZP == 1 && DMSetZZPActiv == 0) DMZA = !DMZA; //bei Ãnderung neue Timertabelle aktivieren
    OCR1A = DMZStart[0][DMZA].Start;
    OCR1B = DMZStop[0][DMZA].Stop;
    DMSynchReg = 1;
    DMSynchZZP = 0;
  }
}

inline void DMIncZCDVerifyC(void) {
  DMZCDVerifyC++;
}

inline void DMDestroy(void) {
  free(DMS.E);
  free(DMZStart);
  free(DMZStop);
}

#endif
