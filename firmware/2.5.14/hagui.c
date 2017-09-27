////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                GUI                                                  //
// Version:              1.1 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.11.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAGUI

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

#include <hatwi.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hakm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#ifdef COHABZ
#include <habz.h>
#endif

#include <haam.h>
#include <hagui.h>

#ifdef COHALCD2X16
#include <halcd2x16.h>
#endif
#ifdef COHALCD3X16
#include <halcd3x16.h>
#endif


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define GUICTMenue 1
#define GUICTOutCtrl 16
#define GUICTThermostat 32

#define GUIHistoryDepth 8

#define GUIEEPROM64WriteAdr 0xA8
#define GUIEEPROM64ReadAdr 0xA9


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef union {
  tGUIMenue *Menue;
  tGUIOutCtrl *OutCtrl;
  tGUIThermostat *Thermostat;
} tGUIControl;

typedef struct {
  tWord Control;
  tByte Select;
  tByte Top;
} tGUIHistoryEntry;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tAMProp *GUICP;
tWord GUIRootCtrlAddr;
tWord GUIStdCtrlAddr;
tByte GUIStdCtrlTime;
tByte GUIStdCtrlCounter;
tGUIControl GUICtrl;
tByte GUICtrlType;
tWord GUICtrlAddr;
tGUIHistoryEntry GUIHistory[GUIHistoryDepth];
tByte GUIHistoryIndex;
tByte GUIEvent;
tByte GUISpeed;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline void GUISetEvent(tByte pEvent, tByte pSpeed) {
#ifdef COHABZ
  if(GUIEvent == SMSCLeft || GUIEvent == SMSCRight)
    BZBuzzer(BZAck, BZBLGUITurn);
  if(GUIEvent >= SMSCPressShort || GUIEvent <= SMSCPressLong)
    BZBuzzer(BZAck, BZBLGUIButton);
#endif
  GUIEvent = pEvent;
  GUISpeed = pSpeed / 10 + 1;
}

void GUIRecieveValue(tByte pSelect, int pValue) {
  switch(GUICtrlType) {
    case GUICTOutCtrl:
      GUICtrl.OutCtrl->Value = pValue;
      break;
    case GUICTThermostat:
      if(pSelect == 0) GUICtrl.Thermostat->Value = pValue;
      if(pSelect == 0xA0) GUICtrl.Thermostat->ValueNew = pValue;
      break;
  }
  GUIEvent = SMSCRefresh;
}

tByte GUIEEPReadByte(void) {
  TWIFillBufferAtIndex(0, GUIEEPROM64ReadAdr);
  TWIStartNormal(2);
  while(TWIBusy());
  return TWIGetDataFromIndex(1);
}

tWord GUIEEPReadWord(void) {
  TWIFillBufferAtIndex(0, GUIEEPROM64ReadAdr);
  TWIStartNormal(3);
  while(TWIBusy());
  return BytesToWord(TWIGetDataFromIndex(2), TWIGetDataFromIndex(1));
}

void GUIEEPReadString(tByte *pString) {

  tByte i;

  pString[0] = GUIEEPReadByte();
  TWIFillBufferAtIndex(0, GUIEEPROM64ReadAdr);
  TWIStartNormal(pString[0] + 1);
  while(TWIBusy());
  for(i = 1; i <= pString[0]; i++) pString[i] = TWIGetDataFromIndex(i);
}

void GUILoadControl(tWord pAddr) {

  tByte i;

  GUICtrlAddr = pAddr;
  TWIFillBufferAtIndex(0, GUIEEPROM64WriteAdr);
  TWIFillBufferAtIndex(1, pAddr >> 8);
  TWIFillBufferAtIndex(2, pAddr & 0xFF);
  TWISuppressStopSignal();
  TWIStartNormal(3);
  while(TWIBusy());
  GUICtrlType = GUIEEPReadByte();
  switch(GUICtrlType) {
    case GUICTMenue:
      GUICtrl.Menue = malloc(sizeof(tGUIMenue));
      GUICtrl.Menue->N = GUIEEPReadByte();
      GUICtrl.Menue->E = malloc(sizeof(tGUIMenueEntry) * GUICtrl.Menue->N); 
      for(i = 0; i < GUICtrl.Menue->N; i++) {
        GUIEEPReadString(GUICtrl.Menue->E[i].Name);
        GUICtrl.Menue->E[i].Control = GUIEEPReadWord();
      }
      GUICtrl.Menue->Select = 0;
      GUICtrl.Menue->Top = 0;
      break;
    case GUICTOutCtrl:
      GUICtrl.OutCtrl = malloc(sizeof(tGUIOutCtrl));
      GUICtrl.OutCtrl->Modul = GUIEEPReadByte();
      GUICtrl.OutCtrl->Device = GUIEEPReadByte();
      GUICtrl.OutCtrl->Value = SMSCNOP;
      SMGetInput(SMEnquirerGUI, GUICtrl.OutCtrl->Modul, GUICtrl.OutCtrl->Device, 0, 0);
      GUICtrl.OutCtrl->State = GUIOCStateNormal;
      GUIEEPReadString(GUICtrl.OutCtrl->Name);
      break;
    case GUICTThermostat:
      GUICtrl.Thermostat = malloc(sizeof(tGUIThermostat));
      GUICtrl.Thermostat->Modul = GUIEEPReadByte();
      GUICtrl.Thermostat->Device = GUIEEPReadByte();
      GUICtrl.Thermostat->Value = GUINOP;
      SMGetInput(SMEnquirerGUI, GUICtrl.Thermostat->Modul, GUICtrl.Thermostat->Device, 0, 0);
      GUICtrl.Thermostat->ValueNew = GUINOP;
      SMGetInput(SMEnquirerGUI, GUICtrl.Thermostat->Modul, GUICtrl.Thermostat->Device, 0xA0, 0);
      GUICtrl.Thermostat->State = GUITSStateNormal;
      GUICtrl.Thermostat->Refresh = GUIEEPReadByte();
      GUICtrl.Thermostat->RefreshCounter = GUICtrl.Thermostat->Refresh;
      GUIEEPReadString(GUICtrl.Thermostat->Name);
      break;
  }
}

void GUIInit(void) {
  if(AMMIInit(KMAMGUI, KMAMGUIMask)) {
    GUICP = AMMIGetMProp();
    TWIFillBufferAtIndex(0, GUIEEPROM64WriteAdr);
    TWIFillBufferAtIndex(1, 0);
    TWIFillBufferAtIndex(2, 0);
    TWISuppressStopSignal();
    TWIStartNormal(3);
    while(TWIBusy());
    GUIRootCtrlAddr = GUIEEPReadWord();
    GUIStdCtrlAddr = GUIEEPReadWord();
    GUIStdCtrlTime = GUIEEPReadByte();
    GUIStdCtrlCounter = GUIStdCtrlTime;
    GUIHistory[0].Control = GUIRootCtrlAddr;
    GUIHistory[GUIHistoryIndex].Select = 0;
    GUIHistory[GUIHistoryIndex].Top = 0;
    GUIHistoryIndex = 0;
    GUILoadControl(GUIRootCtrlAddr);
    GUICtrl.Menue->Select = 0;
    GUICtrl.Menue->Top = 0;
    GUIEvent = SMSCRefresh;
  }
  else
    GUIEvent = SMSCNOP;
}

void GUITimer(void) {
  if(GUIStdCtrlCounter > 0) GUIStdCtrlCounter--;
  if(GUICtrlType == GUICTThermostat)
    if(GUICtrl.Thermostat->RefreshCounter > 0)
      GUICtrl.Thermostat->RefreshCounter--;
}

void GUINextCtrl(void) {
  GUIHistoryIndex++;
  GUIHistory[GUIHistoryIndex].Control = GUICtrlAddr;
  if(GUICtrlType == GUICTMenue) {
    GUIHistory[GUIHistoryIndex].Select = GUICtrl.Menue->Select;
    GUIHistory[GUIHistoryIndex].Top = GUICtrl.Menue->Top;
  }
}

void GUIPrevCtrl(void) {
  GUILoadControl(GUIHistory[GUIHistoryIndex].Control);
  if(GUICtrlType == GUICTMenue) {
    GUICtrl.Menue->Select = GUIHistory[GUIHistoryIndex].Select;
    GUICtrl.Menue->Top = GUIHistory[GUIHistoryIndex].Top;
  }
  GUIHistoryIndex--;
}

void GUIOCStateEditInit(void) {
  if(GUICtrl.OutCtrl->State == GUIOCStateNormal) {
    GUICtrl.OutCtrl->ValueNew = GUICtrl.OutCtrl->Value;
    if(GUICtrl.OutCtrl->ValueNew > 100)
      GUICtrl.OutCtrl->ValueNew = 0;
    GUICtrl.OutCtrl->State = GUIOCStateEdit;
  }
}

void GUIControl(void) {

  tWord NextCtrl;

  if(GUIEvent != SMSCNOP) {
    GUIStdCtrlCounter = GUIStdCtrlTime;
    LCDBL(100);
    switch(GUICtrlType) {
      case GUICTMenue:
        switch(GUIEvent) {
          case SMSCLeft:
            if(GUICtrl.Menue->Select > 0) GUICtrl.Menue->Select--;
            if(GUICtrl.Menue->Select < GUICtrl.Menue->Top) GUICtrl.Menue->Top--;
            break;
          case SMSCRight:
            if(GUICtrl.Menue->Select < GUICtrl.Menue->N - 1) GUICtrl.Menue->Select++;
#ifdef COHALCD2X16
            if(GUICtrl.Menue->Select - GUICtrl.Menue->Top  > 1) GUICtrl.Menue->Top++;
#endif
#ifdef COHALCD3X16
            if(GUICtrl.Menue->Select - GUICtrl.Menue->Top  > 2) GUICtrl.Menue->Top++;
#endif
            break;
          case SMSCPressShort:
            NextCtrl = GUICtrl.Menue->E[GUICtrl.Menue->Select].Control;
            if(GUIHistory[GUIHistoryIndex].Control == NextCtrl || GUIHistoryIndex < GUIHistoryDepth - 2) {
              if(GUIHistory[GUIHistoryIndex].Control != NextCtrl) GUINextCtrl();
              free(GUICtrl.Menue->E);
              free(GUICtrl.Menue);
              if(GUIHistory[GUIHistoryIndex].Control != NextCtrl)
                GUILoadControl(NextCtrl);
              else
                GUIPrevCtrl();
            }
#ifdef COHABZ
            else
              BZBuzzer(BZError, BZBLGUIError);
#endif
            break;
        }
        break;
      case GUICTOutCtrl:
        switch(GUIEvent) {
          case SMSCLeft:
            if(GUICtrl.OutCtrl->Value != SMSCNOP) {
              GUIOCStateEditInit();
              if(GUICtrl.OutCtrl->ValueNew > GUISpeed)
                GUICtrl.OutCtrl->ValueNew -= GUISpeed;
              else
                GUICtrl.OutCtrl->ValueNew = 0;
            }
            break;
          case SMSCRight:
            if(GUICtrl.OutCtrl->Value != SMSCNOP) {
              GUIOCStateEditInit();
              if(GUICtrl.OutCtrl->ValueNew + GUISpeed < 100)
                GUICtrl.OutCtrl->ValueNew += GUISpeed;
              else
                GUICtrl.OutCtrl->ValueNew = 100;
            }
            break;
          case SMSCPressShort:
            if(GUICtrl.OutCtrl->State == GUIOCStateNormal) {
              free(GUICtrl.OutCtrl);
              GUIPrevCtrl();
            }
            if(GUICtrl.OutCtrl->State == GUIOCStateEdit) {
              if(GUICtrl.OutCtrl->Modul == SMGetModulAddress()) {
#ifdef COHABZ
                BZBuzzer(BZAck, BZBLGUIAck);
#endif
                GUICtrl.OutCtrl->Value = GUICtrl.OutCtrl->ValueNew;
              }
              else
                GUICtrl.OutCtrl->Value = SMSCNOP;
              SMSetOutput(GUICtrl.OutCtrl->Modul, GUICtrl.OutCtrl->Device, GUICtrl.OutCtrl->ValueNew, 0, (tMDataCode *)SMControllerGUI);
              GUICtrl.OutCtrl->State = GUIOCStateNormal;
            }
            break;
          case SMSCPressMedium:
            if(GUICtrl.OutCtrl->State == GUIOCStateEdit)
              GUICtrl.OutCtrl->State = GUIOCStateNormal;
            break;
        }
        break;
      case GUICTThermostat:
        switch(GUIEvent) {
          case SMSCLeft:
            if(GUICtrl.Thermostat->ValueNew != GUINOP) {
              GUICtrl.Thermostat->State = GUITSStateEdit;
              if(GUICtrl.Thermostat->ValueNew > (GUISpeed << 3) - 320)
                GUICtrl.Thermostat->ValueNew -= GUISpeed << 3;
              else
                GUICtrl.Thermostat->ValueNew = -320;
            }
            break;
          case SMSCRight:
            if(GUICtrl.Thermostat->ValueNew != GUINOP) {
              GUICtrl.Thermostat->State = GUITSStateEdit;
              if(GUICtrl.Thermostat->ValueNew + (GUISpeed << 3) < 960)
                GUICtrl.Thermostat->ValueNew += GUISpeed << 3;
              else
                GUICtrl.Thermostat->ValueNew = 960;
            }
            break;
          case SMSCPressShort:
            if(GUICtrl.Thermostat->State == GUITSStateNormal) {
              free(GUICtrl.Thermostat);
              GUIPrevCtrl();
            }
            if(GUICtrl.Thermostat->State == GUITSStateEdit) {
              SMSetOutput(GUICtrl.Thermostat->Modul, GUICtrl.Thermostat->Device, 0xA0, GUICtrl.Thermostat->ValueNew, (tMDataCode *)SMControllerGUI);
              if(GUICtrl.OutCtrl->Modul != SMGetModulAddress())
                GUICtrl.Thermostat->ValueNew = GUINOP;
#ifdef COHABZ
              else
                BZBuzzer(BZAck, BZBLGUIAck);
#endif
              GUICtrl.Thermostat->State = GUITSStateNormal;
            }
            break;
          case SMSCPressMedium:
            if(GUICtrl.Thermostat->State == GUITSStateEdit) {
              GUICtrl.Thermostat->ValueNew = GUINOP;
              SMGetInput(SMEnquirerGUI, GUICtrl.Thermostat->Modul, GUICtrl.Thermostat->Device, 0xA0, 0);
              GUICtrl.Thermostat->State = GUITSStateNormal;
            }
            break;
        }
        break;
    }
#ifdef COHALCD
    switch(GUICtrlType) {
      case GUICTMenue:
        LCDPutMenue(GUICtrl.Menue);
        break;
      case GUICTOutCtrl:
        LCDPutOutCtrl(GUICtrl.OutCtrl);
        break;
      case GUICTThermostat:
        LCDPutThermostat(GUICtrl.Thermostat);
        break;
    }
#endif
    GUIEvent = SMSCNOP;
  }
  else
    if(GUIStdCtrlCounter == 0) {
      LCDBL(0);
      if(GUIStdCtrlAddr != GUICtrlAddr) {
        GUINextCtrl();
        switch(GUICtrlType) {
          case GUICTMenue:
            free(GUICtrl.Menue->E);
            free(GUICtrl.Menue);
            break;
          case GUICTOutCtrl:
            free(GUICtrl.OutCtrl);
            break;
          case GUICTThermostat:
            free(GUICtrl.Thermostat);
            break;
        }
        GUILoadControl(GUIStdCtrlAddr);
      }
    }
    if(GUICtrlType == GUICTThermostat)
      if(GUICtrl.Thermostat->RefreshCounter == 0) {
        SMGetInput(SMEnquirerGUI, GUICtrl.Thermostat->Modul, GUICtrl.Thermostat->Device, 0, 0);
        GUICtrl.Thermostat->RefreshCounter = GUICtrl.Thermostat->Refresh;
      }
}

#endif
