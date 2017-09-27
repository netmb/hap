////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Global                                               //
// Version:              2.1 (1)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          20.12.2005                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.02.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAGL
#define HAGL


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define CPUFrequenz 12000000
#define MDataLength 7


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef unsigned char tByte;
typedef unsigned int tWord;
typedef unsigned long tDWord;
typedef volatile tByte *tVPByte;

typedef struct {
  tByte Source;
  tByte Dest;
  tByte MType;
  tByte Device;
  tByte Value0;
  tByte Value1;
  tByte Value2;
} tMDataCode;

typedef union {
  tMDataCode Code;
  tByte Array[MDataLength];
} tMData;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

tWord BytesToWord(tByte pLByte, tByte pHByte);


#endif
