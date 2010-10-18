////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Digital Input Dallas 1820                            //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          07.03.2007                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  07.03.2007                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HADIDS1820
#define HADIDS1820


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DIDS1820FCStartConv 0x44
#define DIDS1820FCReadScratchpad 0xBE


////////////////////////////////////////////////////////////////////////////////
// Makros                                                                     //
////////////////////////////////////////////////////////////////////////////////

#define DIDS1820StartConversion(pPins) OWISendByte(DIDS1820FCStartConv, pPins)
#define DIDS1820ReadScratchpad(pPins) OWISendByte(DIDS1820FCReadScratchpad, pPins)


#endif
