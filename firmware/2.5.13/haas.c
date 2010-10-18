////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Autonome Steuerung                                   //
// Version:              2.5 (8)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          29.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  16.10.2010                                           //
// Zuletzt geändert von: Carsten Wolff                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHAAS

// Basis Module ////////////////////////////////////////////////////////////////

#include <stdlib.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hazm.h>
#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <haas.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define ASTimerPrescale 10

#define ASOTCat0 0
#define ASOTCat1 64
#define ASOTCat2 128
#define ASOTCat3 192

#define ASOTOutputModifier 63
#define ASOTOutputModifierMask 0xBF

#define ASOTPInput 60
#define ASOTPInputMask 0xFE
#define ASOTTimer 112
#define ASOTTimerMask 0xF8

#define ASOTNoOp 0
#define ASOTTimerM 32
#define ASOTTimerH 33
#define ASOTTimerD 34
#define ASOTTimerW 35
#define ASOTAInput 56
#define ASOTNVPInput 60
#define ASOTVPInput 61
#define ASOT0OutputModifier 63
#define ASOT1LShift 69
#define ASOT1RShift 70
#define ASOT1EQ 72
#define ASOT1NEQ 73
#define ASOT1LS 74
#define ASOT1LSE 75
#define ASOT1GT 76
#define ASOT1GTE 77
#define ASOT1ADD 80
#define ASOT1SUB 81
#define ASOT1MUL 82
#define ASOT1DIV 83
#define ASOTOffsetMul 84
#define ASOTOffsetDiv 85
#define ASOTRatioMul 86
#define ASOTRegelGlied0 96
#define ASOTUpDownControl1 100
#define ASOT1FWLS 104
#define ASOT1FWMD 105
#define ASOT1FWGT 106
#define ASOT1FWCT 107
#define ASOTASVZ 112
#define ASOTESVZ 113
#define ASOTESBG 114
#define ASOTFWTimed 115
#define ASOTOutput 120
#define ASOTNativeOutput 121
#define ASOTStatusOutput 122
#define ASOTMakro 123
#define ASOT1OutputModifier 127
#define ASOT2AND 128
#define ASOT2OR 129
#define ASOT2NAND 130
#define ASOT2NOR 131
#define ASOT2XOR 132
#define ASOT2LShift 133
#define ASOT2RShift 134
#define ASOT2EQ 136
#define ASOT2NEQ 137
#define ASOT2LS 138
#define ASOT2LSE 139
#define ASOT2GT 140
#define ASOT2GTE 141
#define ASOT2ADD 144
#define ASOT2SUB 145
#define ASOT2MUL 146
#define ASOT2DIV 147
#define ASOT2Flipflop0 152
#define ASOT2Flipflop1 153
#define ASOT2Flipflop2 154
#define ASOT2Flipflop3 155
#define ASOT2Flipflop4 156
#define ASOT2Flipflop5 157
#define ASOTUpDownControl2 164
#define ASOTUpDownControl2RS 165
#define ASOT2FWLS 168
#define ASOT2FWMD 169
#define ASOT2FWGT 170
#define ASOT2FWCT 171
#define ASOT3AND 192
#define ASOT3OR 193
#define ASOT3NAND 194
#define ASOT3NOR 195
#define ASOT3XOR 196
#define ASOT3ADD 208
#define ASOT3SUB 209
#define ASOT3MUL 210
#define ASOT3DIV 211
#define ASOT3Flipflop0 216
#define ASOT3Flipflop1 217
#define ASOT3Flipflop2 218
#define ASOT3Flipflop3 219
#define ASOT3Flipflop4 220
#define ASOT3Flipflop5 221
#define ASOT3FWLS 232
#define ASOT3FWMD 233
#define ASOT3FWGT 234
#define ASOT3FWCT 235


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte Value;
  union {
    tByte X;
    tByte Flag;
    tByte Timer;
    tByte RefValue;
  };  
} tASStatusElement;

typedef struct {
  tByte N;
  tASStatusElement *E;
} tASStatus;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tASC ASC;
tASStatus ASS;
tByte ASCounter;
tByte ASPreScaleSelect;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tASC *ASGetConfPointer(void) {
  return &ASC;
}

void ASSetConfDefaults(void) {

  tByte i;
  tByte j;

  for(i = 0; i < ASObjCount; i++)
    for(j = 0; j < 4; j++)
      ASC.ASObj[i].Array[j] = 0;
}

inline void ASSetConfObj(tByte pObj, tByte pIndex, tByte pValue) {
  ASC.ASObj[pObj].Array[pIndex] = pValue;
}

void ASInit(void) {

  tByte i;
  
  for(i = ASObjCount; i > 0; i--)
    if(ASC.ASObj[i - 1].S.Type > ASOTNoOp) break;
  if(ASC.ASObj[i - 1].S.Type == ASOTNoOp) i = 0;
  ASS.N = i;
  ASS.E = malloc(sizeof(tASStatusElement) * ASS.N);
  for(i = 0; i < ASS.N; i++) {
    ASS.E[i].Value = 0; 
    ASS.E[i].X = 0;
    if((ASC.ASObj[i].S.Type & ASOTPInputMask) == ASOTPInput) {
      ASS.E[i].Value = ASC.ASObj[i].S.V2;
      ASS.E[i].X = ASS.E[i].Value;
    }
    if(ASC.ASObj[i].S.Type == ASOTRegelGlied0)
      ASS.E[i].RefValue = ASC.ASObj[i].S.V1;
  }
  ASCounter = 0;
  ASPreScaleSelect = 0;
}

inline void ASSetStatusElementValue(tByte pElement, tByte pValue) {
  ASS.E[pElement].Value = pValue;
}

inline void ASCounterInc(void) {
  ASCounter++;
}

inline void ASPreScaleSelectInc(void) {
  ASPreScaleSelect++;
}

void ASRecStatusMess(tByte pModul, tByte pAddr, tWord pValue, tByte pExt) {

  tByte i;

  for(i = 0; i < ASS.N; i++) {
    if((ASC.ASObj[i].S.Type & ASOTPInputMask) == ASOTPInput && ASC.ASObj[i].S.V0 == pModul && ASC.ASObj[i].S.V1 == pAddr) {
      if(pExt & 0x80)
        ASS.E[i].Value = pValue >> 4;
      else
        ASS.E[i].Value = pValue;
	  }
    if(ASC.ASObj[i].S.Type == ASOTVPInput) ASS.E[i].X = 0;
  }
}

tByte ASEvalEdgeFlags(tByte pV0, tByte pV1) {

  tByte tmp;

  tmp = 0;
  if(pV0 > 0) tmp |= 1;
  if(pV1 > 0) tmp |= 2;
  return tmp;
}

void ASCalc(void) {

  tByte i;
  tByte Type;
  tByte V0;
  tByte V1;
  tByte V2;
  tByte tmp;
  tWord tmp0;
  tWord tmp1;

  if(ASCounter >= ASTimerPrescale) {
    ASCounter = 0;
    for(i = 0; i < ASS.N; i++) {
      Type = ASC.ASObj[i].S.Type;
      V0 = ASC.ASObj[i].S.V0;
      if(Type >= ASOTCat1) V0 = ASS.E[V0].Value;
      V1 = ASC.ASObj[i].S.V1;
      if(Type >= ASOTCat2) V1 = ASS.E[V1].Value;
      V2 = ASC.ASObj[i].S.V2;
      if(Type >= ASOTCat3) V2 = ASS.E[V2].Value;
      if((Type & ASOTTimerMask) == ASOTTimer && ASS.E[i].Timer > 0 && (V1 & 0x07) <= ASPreScaleSelect) ASS.E[i].Timer--;
      switch(Type) {
        case ASOTTimerM:
          tmp0 = ZMGetSecond() * 100 + ZMGetHundredth();
          tmp1 = (V0 & 0x3F) * 100 + (V1 & 0x0F) * 10;
          if(tmp0 >= tmp1 && tmp0 <= tmp1 + ((V0 & 0xC0) << 2 | V2) * 10)
            ASS.E[i].Value = 0xFF;
          else
            ASS.E[i].Value = 0x00;
          break;
        case ASOTTimerH:
          tmp0 = ZMGetMinute() * 60 + ZMGetSecond();
          tmp1 = (V0 & 0x3F) * 60 + (V1 & 0x3F);
          if(tmp0 >= tmp1 && tmp0 <= tmp1 + ((V0 & 0xC0) << 4 | (V1 & 0xC0) << 2 | V2))
            ASS.E[i].Value = 0xFF;
          else
            ASS.E[i].Value = 0x00;
          break;
        case ASOTTimerD:
          tmp0 = ZMGetHour() * 60 + ZMGetMinute();
          tmp1 = (V0 & 0x1F) * 60 + (V1 & 0x3F);
          if(ZMGetDay() < 5 && (V0 & 0x20) == 0) tmp1 = 0xFFFF;
          if(ZMGetDay() == 5 && (V0 & 0x40) == 0) tmp1 = 0xFFFF;
          if(ZMGetDay() == 6 && (V0 & 0x80) == 0) tmp1 = 0xFFFF;
          if(tmp0 >= tmp1 && tmp0 <= tmp1 + ((V1 & 0xC0) << 2 | V2))
            ASS.E[i].Value = 0xFF;
          else
            ASS.E[i].Value = 0x00;
          break;
        case ASOTTimerW:
          tmp0 = ZMGetDay() * 1440 + ZMGetHour() * 60 + ZMGetMinute();
          tmp1 = ((V0 & 0xE0) >> 5) * 1440 + (V0 & 0x1F) * 60 + (V1 & 0x3F);
          if(tmp0 >= tmp1 && tmp0 <= tmp1 + ((V1 & 0xC0) << 2 | V2))
            ASS.E[i].Value = 0xFF;
          else
            ASS.E[i].Value = 0x00;
          break;
        case ASOTAInput:
          if(ASS.E[i].Timer > 0)
            ASS.E[i].Timer--;
          else {
            ASS.E[i].Timer = V2;
            SMGetInput(i, V0, V1, 0, 0);
          }
          break;
        case ASOTNVPInput:
          break;
        case ASOTVPInput:
          if(ASS.E[i].X == ASS.E[i].Value)
            ASS.E[i].Value = V2;
          ASS.E[i].X = ASS.E[i].Value;
          break;
        case ASOT0OutputModifier:
        case ASOT1OutputModifier:
          if((ASS.E[i].Value < V0 && ASC.ASObj[i].S.V2 & 0x80) || (ASS.E[i].Value > V0 && ASC.ASObj[i].S.V2 & 0x40))
            ASS.E[i].Flag = 1;
          else
            ASS.E[i].Flag = 0;
          ASS.E[i].Value = V0;
          break;
        case ASOT1LShift:
        case ASOT2LShift:
          ASS.E[i].Value = V0 << V1;
          break;
        case ASOT1RShift:
        case ASOT2RShift:
          ASS.E[i].Value = V0 >> V1;
          break;
        case ASOT1EQ:
        case ASOT2EQ:
          if(V0 == V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1NEQ:
        case ASOT2NEQ:
          if(V0 != V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1LS:
        case ASOT2LS:
          if(V0 < V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1LSE:
        case ASOT2LSE:
          if(V0 <= V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1GT:
        case ASOT2GT:
          if(V0 > V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1GTE:
        case ASOT2GTE:
          if(V0 >= V1)
            ASS.E[i].Value = 255;
          else
            ASS.E[i].Value = 0;
          break;
        case ASOT1ADD:
        case ASOT2ADD:
        case ASOT3ADD:
          ASS.E[i].Value = V0 + V1 + V2;
          break;
        case ASOT1SUB:
        case ASOT2SUB:
        case ASOT3SUB:
          ASS.E[i].Value = V0 - V1 - V2;
          break;
        case ASOT1MUL:
        case ASOT2MUL:
        case ASOT3MUL:
          ASS.E[i].Value = V0 * V1 * V2;
          break;
        case ASOT1DIV:
        case ASOT2DIV:
        case ASOT3DIV:
          ASS.E[i].Value = V0 / V1 / V2;
          break;
        case ASOT2AND:
        case ASOT3AND:
          ASS.E[i].Value = V0 & V1 & V2;
          break;
        case ASOT2OR:
        case ASOT3OR:
          ASS.E[i].Value = V0 | V1 | V2;
          break;
        case ASOT2NAND:
        case ASOT3NAND:
          ASS.E[i].Value = ~(V0 & V1 & V2);
          break;
        case ASOT2NOR:
        case ASOT3NOR:
          ASS.E[i].Value = ~(V0 | V1 | V2);
          break;
        case ASOT2XOR:
        case ASOT3XOR:
          ASS.E[i].Value = V0 ^ V1 ^ V2;
          break;
        case ASOTOffsetMul:
          ASS.E[i].Value = (V0 + V1) * (V2 / 16.);
          break;
        case ASOTOffsetDiv:
          ASS.E[i].Value = V2 / (V0 + V1);
          break;
        case ASOTRatioMul:
          ASS.E[i].Value = V0 / (float)V1 * V2;
          break;
        case ASOTRegelGlied0:
          if(V0 < ASS.E[i].RefValue) {
            V0 = (ASS.E[i].RefValue - V0) >> 1;
            if(ASS.E[i].Value + V0 > 255)
              ASS.E[i].Value = 255;
            else
              ASS.E[i].Value += V0;
          }
          else {
            V0 = (V0 - ASS.E[i].RefValue) >> 1;
            if(V0 > ASS.E[i].Value)
              ASS.E[i].Value = 0;
            else
              ASS.E[i].Value -= V0;
          }
          break;
        case ASOTUpDownControl1:
          switch(V0) {
            case 132:
              ASS.E[i].Value = 128;
              break;
            case 8:
              if(ASS.E[i].Value == 136)
                ASS.E[i].Value = 135;
              else
                ASS.E[i].Value = 255;
              break;
            case 136:
              ASS.E[i].Value = 136;
              break;
          }
          break;
        case ASOT2Flipflop0:
        case ASOT3Flipflop0:
          if(V0 > 0) ASS.E[i].Value = V2;
          if(V1 > 0) ASS.E[i].Value = 0;
          break;
        case ASOT2Flipflop1:
        case ASOT3Flipflop1:
          if(V1 > 0) ASS.E[i].Value = 0;
          if(V0 > 0) ASS.E[i].Value = V2;
          break;
        case ASOT2Flipflop2:
        case ASOT3Flipflop2:
          if(V0 > 0 && ASS.E[i].Value == 0) ASS.E[i].Value = V2;
          else
            if(V1 > 0 && ASS.E[i].Value > 0) ASS.E[i].Value = 0;
          break;
        case ASOT2Flipflop3:
        case ASOT3Flipflop3:
          tmp = ASS.E[i].Flag;
          if(V0 > 0 && ~(tmp & 1)) ASS.E[i].Value = V2;
          if(V1 > 0 && ~(tmp & 2)) ASS.E[i].Value = 0;
          ASS.E[i].Flag = ASEvalEdgeFlags(V0, V1);
          break;
        case ASOT2Flipflop4:
        case ASOT3Flipflop4:
          tmp = ASS.E[i].Flag;
          if(V1 > 0 && ~(tmp & 2)) ASS.E[i].Value = 0;
          if(V0 > 0 && ~(tmp & 1)) ASS.E[i].Value = V2;
          ASS.E[i].Flag = ASEvalEdgeFlags(V0, V1);
          break;
        case ASOT2Flipflop5:
        case ASOT3Flipflop5:
          tmp = ASS.E[i].Flag;
          if(V0 > 0 && ~(tmp & 1) && ASS.E[i].Value == 0) ASS.E[i].Value = V2;
          else
            if(V1 > 0 && ~(tmp & 2) && ASS.E[i].Value > 0) ASS.E[i].Value = 0;
          ASS.E[i].Flag = ASEvalEdgeFlags(V0, V1);
          break;
        case ASOTUpDownControl2:
          if(ASS.E[i].RefValue != V0) {
            switch(V0) {
              case 132:
                ASS.E[i].Value = 100;
                break;
              case 8:
                if(ASS.E[i].RefValue == 136)
                  ASS.E[i].Value = 135;
                else
                  ASS.E[i].Value = 255;
                break;
              case 136:
                ASS.E[i].Value = 133;
                break;
            }
            ASS.E[i].RefValue = V0;
          }
          if(ASC.ASObj[i].S.V2 != V1) {
            switch(V1) {
              case 132:
                ASS.E[i].Value = 0;
                break;
              case 8:
                if(ASC.ASObj[i].S.V2 == 136)
                  ASS.E[i].Value = 135;
                else
                  ASS.E[i].Value = 255;
                break;
              case 136:
                ASS.E[i].Value = 134;
                break;
            }
            ASC.ASObj[i].S.V2 = V1;
          }
          break;
        case ASOTUpDownControl2RS:
          if(ASS.E[i].RefValue != V0) {
            switch(V0) {
              case 8:
                if(ASS.E[i].RefValue == 136)
                  ASS.E[i].Value = 135;
                else
                  ASS.E[i].Value = 255;
                break;
              case 132:
              case 136:
                ASS.E[i].Value = 133;
                break;
            }
            ASS.E[i].RefValue = V0;
          }
          if(ASC.ASObj[i].S.V2 != V1) {
            switch(V1) {
              case 8:
                if(ASC.ASObj[i].S.V2 == 136)
                  ASS.E[i].Value = 135;
                else
                  ASS.E[i].Value = 255;
                break;
              case 132:
              case 136:
                ASS.E[i].Value = 134;
                break;
            }
            ASC.ASObj[i].S.V2 = V1;
          }
          break;
        case ASOT1FWLS:
        case ASOT2FWLS:
        case ASOT3FWLS:
          if(V0 < V1)
            if(V0 < V2)
              ASS.E[i].Value = V0;
            else
              ASS.E[i].Value = V2;
          else
            if(V1 < V2)
              ASS.E[i].Value = V1;
            else
              ASS.E[i].Value = V2;
          break;
        case ASOT1FWMD:
        case ASOT2FWMD:
        case ASOT3FWMD:
          if(V0 > V1) {
            tmp = V1;
            V1 = V0;
            V0 = tmp;
          }
          if(V1 > V2) {
            tmp = V2;
            V2 = V1;
            V1 = tmp;
          }
          if(V0 > V1) {
            tmp = V1;
            V1 = V0;
            V0 = tmp;
          }
          ASS.E[i].Value = V1;
          break;
        case ASOT1FWGT:
        case ASOT2FWGT:
        case ASOT3FWGT:
          if(V0 > V1)
            if(V0 > V2)
              ASS.E[i].Value = V0;
            else
              ASS.E[i].Value = V2;
          else
            if(V1 > V2)
              ASS.E[i].Value = V1;
            else
              ASS.E[i].Value = V2;
          break;
        case ASOT1FWCT:
        case ASOT2FWCT:
        case ASOT3FWCT:
          if(V0 == 0)
            ASS.E[i].Value = V1;
          else
            ASS.E[i].Value = V2;
          break;
        case ASOTASVZ:
          if(V0 > 0) {
            ASS.E[i].Timer = V2;
            ASS.E[i].Value = V0;
          }
          else
            if(ASS.E[i].Timer == 0) ASS.E[i].Value = 0;
          break;
        case ASOTESVZ:
          if(V0 == 0) {
            ASS.E[i].Timer = V2;
            ASS.E[i].Value = 0;
          }
          else
            if(ASS.E[i].Timer == 0) ASS.E[i].Value = V0;
          break;
        case ASOTESBG:
          if(V0 > 0 && ASS.E[i].Timer > 0)
            ASS.E[i].Value = V0;
          else
            ASS.E[i].Value = 0;
          if(V0 == 0) ASS.E[i].Timer = V2;
          break;
        case ASOTFWTimed:
          if(ASS.E[i].Timer == 0) {
            ASS.E[i].Timer = V2;
            ASS.E[i].Value = V0;
          }
          break;
        case ASOTOutput:
          if(ASS.E[i].Value != V0) {
            ASS.E[i].Value = V0;
            tmp = ASC.ASObj[i].S.V0;
            if((ASC.ASObj[tmp].S.Type & ASOTOutputModifierMask) == ASOTOutputModifier) {
              if(ASS.E[tmp].Flag > 0)
                SMSetOutput(V1, V2, V0 / 2.55, BytesToWord(ASC.ASObj[tmp].S.V1, ASC.ASObj[tmp].S.V2 & 0x3F), 0);
            }
            else
              SMSetOutput(V1, V2, V0 / 2.55, 0, 0);
          }
          break;
        case ASOTNativeOutput:
          if(ASS.E[i].Value != V0) {
            ASS.E[i].Value = V0;
            if(V0 < 255) {
              tmp = ASC.ASObj[i].S.V0;
              if((ASC.ASObj[tmp].S.Type & ASOTOutputModifierMask) == ASOTOutputModifier) {
                if(ASS.E[tmp].Flag > 0)
                  SMSetOutput(V1, V2, V0, BytesToWord(ASC.ASObj[tmp].S.V1, ASC.ASObj[tmp].S.V2 & 0x3F), 0);
              }
              else
                SMSetOutput(V1, V2, V0, 0, 0);
            }
          }
          break;
        case ASOTStatusOutput:
          if(ASS.E[i].Value != V0) {
            ASS.E[i].Value = V0;
            SMSendStatus(SMMABroadcast, V2, V0, 0);
          }
          break;
		case ASOTMakro:
          if(V0 > 0 && ASS.E[i].Value != V0) { //Startet ein Makro wenn der Eingang auf "AN" wechselt
            ASS.E[i].Value = V0;
			SMSendMakro(V1);
          }
		  else if(V0 == 0 && ASS.E[i].Value != V0) { //Startet ein Makro wenn der Eingang auf "AUS" wechselt
            ASS.E[i].Value = V0;
			SMSendMakro(V2);
          }
          break;  
      }
    }
    ASPreScaleSelect = 0;
  }
}

inline void ASDestroy(void) {
  free(ASS.E);
}

#endif
