////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Steuerung MCP2515                                    //
// Version:              1.0 (0)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  03.02.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef HAMCP2515
#define HAMCP2515


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <hagl.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

//	Bitdefinition von TXBnSIDL ( n = 0, 1 )
#define MCPEXIDE 3


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte SIDH;
  tByte SIDL;
  tByte EIDH;
  tByte EIDL;
  tByte Length;
  tByte Data[8];
} tMCPMessage;


////////////////////////////////////////////////////////////////////////////////
// Deklarationen                                                              //
////////////////////////////////////////////////////////////////////////////////

void MCP2515Reset(void);
void MCP2515InitBegin(void);
void MCP2515InitEnd(void);
void MCP2515SetFMask(tByte pFMask, tByte pSIDH, tByte pSIDL, tByte pEIDH, tByte pEIDL);
void MCP2515SetFilter(tByte pFilter, tByte pSIDH, tByte pSIDL, tByte pEIDH, tByte pEIDL);
tByte MCP2515GetMessage(tMCPMessage *pMessage);
tByte MCP2515PutMessage(tMCPMessage *pMessage);


#endif
