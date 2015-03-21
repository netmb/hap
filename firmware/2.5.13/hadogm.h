////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                LCD EA DOGM                                          //
// Version:              1.0 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          01.02.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  25.03.2008                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HADOGM
#define HADOGM


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define LCDInstNil 0x00
#define LCDDataNil 0xA0


////////////////////////////////////////////////////////////////////////////////
// Makros                                                                     //
////////////////////////////////////////////////////////////////////////////////

#define LCDPutCtrlCode(pCode) DOGMWriteInst(pCode)
#define LCDClear() DOGMWriteInst(0x01)

#ifdef COHALCD2X16
#define LCDGotoXY(pX, pY) DOGMWriteInst((tByte)(pY * 0x40 + pX) | 0x80)
#endif
#ifdef COHALCD3X16
#define LCDGotoXY(pX, pY) DOGMWriteInst((tByte)(pY * 0x10 + pX) | 0x80)
#endif

#define LCDPutChar(pChar) DOGMWriteData(pChar)


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void DOGMWriteInst(tByte pInst);
void DOGMWriteData(tByte pData);
void DOGMInit(void);
void LCDBL(tByte pValue);
void LCDPutString(tByte *pString);


#endif
