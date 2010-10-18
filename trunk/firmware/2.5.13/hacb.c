////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                CAN-Bus                                              //
// Version:              1.0 (4)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          21.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  22.05.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

#include <mv.h>

#ifdef COHACB

// Basis Module ////////////////////////////////////////////////////////////////

#include <hamcp2515.h>

// Essentielle Module //////////////////////////////////////////////////////////

#include <hasm.h>

// Optionale Module ////////////////////////////////////////////////////////////

#include <hacb.h>


////////////////////////////////////////////////////////////////////////////////
// Typdefinitionen                                                            //
////////////////////////////////////////////////////////////////////////////////

typedef struct {
  tByte CLANID;
  tMData Data;
} tCBMessage;


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tCBC CBC;
tCBMessage CBMessageRec;                    // Empfangen einer Nachricht
tMCPMessage CBMCPMessageRec;
tMCPMessage CBMCPMessageTrans;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

inline tCBC *CBGetConfPointer(void) {
  return &CBC;
}

void CBSetConfDefaults(void) {
  CBC.CLANID = 0;
}

inline void CBSetConfCLANID(tByte pCLANID) {
  CBC.CLANID = pCLANID;
}

void CBInit(void) {

  tByte FMaskDest;

  if(SMGetBridgeMode())
    FMaskDest = 0x00;
  else
    FMaskDest = 0xFF;
  MCP2515InitBegin();
  MCP2515SetFMask(0, 0xFF, 1 << MCPEXIDE, 0x00, FMaskDest);
  MCP2515SetFilter(0, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMGetModulAddress());
  MCP2515SetFilter(1, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMMABroadcast);
  MCP2515SetFMask(1, 0xFF, 1 << MCPEXIDE, 0x00, FMaskDest & SMMAMulticast);
  MCP2515SetFilter(2, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMMAMulticast);
  MCP2515SetFilter(3, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMMAMulticast);
  MCP2515SetFilter(4, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMMAMulticast);
  MCP2515SetFilter(5, CBC.CLANID, 1 << MCPEXIDE, 0x00, SMMAMulticast);
  MCP2515InitEnd();
}

void CBRecMessage(void) {

  tByte i;

  if(MCP2515GetMessage(&CBMCPMessageRec)) {
    CBMessageRec.CLANID = CBMCPMessageRec.SIDH;
    CBMessageRec.Data.Code.Source = CBMCPMessageRec.EIDH;
    CBMessageRec.Data.Code.Dest = CBMCPMessageRec.EIDL;
    for(i = 2; i < MDataLength; i++)
      CBMessageRec.Data.Array[i] = CBMCPMessageRec.Data[i - 2];
    SMRecBufAdd(SMIntIDCB, &CBMessageRec.Data);
  }
}

void CBTransMessage(tByte pInt, const tMData *pData) {

  tByte i;

  if(pInt == SMIntIDCB || ((pInt & ~SMIntIDInvertMask) != SMIntIDCB && (pInt & SMIntIDInvertMask)) || (pInt & SMIntIDNumberMask) == SMIntIDNumberBroadcast) {
    CBMCPMessageTrans.SIDH = CBC.CLANID;
    CBMCPMessageTrans.SIDL = 1 << MCPEXIDE;
    CBMCPMessageTrans.EIDH = pData->Code.Source;
    CBMCPMessageTrans.EIDL = pData->Code.Dest;
    CBMCPMessageTrans.Length = MDataLength - 2;
    for(i = 2; i < MDataLength; i++)
      CBMCPMessageTrans.Data[i - 2] = pData->Array[i];
    while(!MCP2515PutMessage(&CBMCPMessageTrans));
  }
}


#endif
