////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Steuerung MCP2515                                    //
// Version:              1.0 (2)                                              //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          28.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  22.03.2006                                           //
// Zuletzt geändert von: Holger Heuser                                        //
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Module einbinden                                                           //
////////////////////////////////////////////////////////////////////////////////

// Basis Module ////////////////////////////////////////////////////////////////

#include <hamcp2515.h>
#include <haspi.h>


////////////////////////////////////////////////////////////////////////////////
// Precompiler Konstanten                                                     //
////////////////////////////////////////////////////////////////////////////////

// SPI Kommandos
#define MCPReset 0xC0
#define	MCPRead 0x03
#define	MCPReadRX 0x90
#define	MCPWrite 0x02
#define	MCPWriteTX 0x40
#define	MCPRTS 0x80
#define MCPReadStatus 0xA0
#define	MCPRXStatus 0xB0
#define	MCPModBit 0x05

// Register Adressen
#define MCPRXF0SIDH 0x00
#define MCPRXF0SIDL 0x01
#define MCPRXF0EID8 0x02
#define MCPRXF0EID0 0x03
#define MCPRXF1SIDH 0x04
#define MCPRXF1SIDL 0x05
#define MCPRXF1EID8 0x06
#define MCPRXF1EID0 0x07
#define MCPRXF2SIDH 0x08
#define MCPRXF2SIDL 0x09
#define MCPRXF2EID8 0x0A
#define MCPRXF2EID0 0x0B
#define MCPBFPCTRL 0x0C
#define MCPTXRTSCTRL 0x0D
#define MCPCANSTAT 0x0E
#define MCPCANCTRL 0x0F

#define MCPRXF3SIDH 0x10
#define MCPRXF3SIDL 0x11
#define MCPRXF3EID8 0x12
#define MCPRXF3EID0 0x13
#define MCPRXF4SIDH 0x14
#define MCPRXF4SIDL 0x15
#define MCPRXF4EID8 0x16
#define MCPRXF4EID0 0x17
#define MCPRXF5SIDH 0x18
#define MCPRXF5SIDL 0x19
#define MCPRXF5EID8 0x1A
#define MCPRXF5EID0 0x1B
#define MCPTEC 0x1C
#define MCPREC 0x1D

#define MCPRXM0SIDH 0x20
#define MCPRXM0SIDL 0x21
#define MCPRXM0EID8 0x22
#define MCPRXM0EID0 0x23
#define MCPRXM1SIDH 0x24
#define MCPRXM1SIDL 0x25
#define MCPRXM1EID8 0x26
#define MCPRXM1EID0 0x27
#define MCPCNF3 0x28
#define MCPCNF2 0x29
#define MCPCNF1 0x2A
#define MCPCANINTE 0x2B
#define MCPCANINTF 0x2C
#define MCPEFLG 0x2D

#define MCPTXB0CTRL 0x30
#define MCPTXB0SIDH 0x31
#define MCPTXB0SIDL 0x32
#define MCPTXB0EID8 0x33
#define MCPTXB0EID0 0x34
#define MCPTXB0DLC 0x35
#define MCPTXB0D0 0x36
#define MCPTXB0D1 0x37
#define MCPTXB0D2 0x38
#define MCPTXB0D3 0x39
#define MCPTXB0D4 0x3A
#define MCPTXB0D5 0x3B
#define MCPTXB0D6 0x3C
#define MCPTXB0D7 0x3D

#define MCPTXB1CTRL 0x40
#define MCPTXB1SIDH 0x41
#define MCPTXB1SIDL 0x42
#define MCPTXB1EID8 0x43
#define MCPTXB1EID0 0x44
#define MCPTXB1DLC 0x45
#define MCPTXB1D0 0x46
#define MCPTXB1D1 0x47
#define MCPTXB1D2 0x48
#define MCPTXB1D3 0x49
#define MCPTXB1D4 0x4A
#define MCPTXB1D5 0x4B
#define MCPTXB1D6 0x4C
#define MCPTXB1D7 0x4D

#define MCPTXB2CTRL 0x50
#define MCPTXB2SIDH 0x51
#define MCPTXB2SIDL 0x52
#define MCPTXB2EID8 0x53
#define MCPTXB2EID0 0x54
#define MCPTXB2DLC 0x55
#define MCPTXB2D0 0x56
#define MCPTXB2D1 0x57
#define MCPTXB2D2 0x58
#define MCPTXB2D3 0x59
#define MCPTXB2D4 0x5A
#define MCPTXB2D5 0x5B
#define MCPTXB2D6 0x5C
#define MCPTXB2D7 0x5D

#define MCPRXB0CTRL 0x60
#define MCPRXB0SIDH 0x61
#define MCPRXB0SIDL 0x62
#define MCPRXB0EID8 0x63
#define MCPRXB0EID0 0x64
#define MCPRXB0DLC 0x65
#define MCPRXB0D0 0x66
#define MCPRXB0D1 0x67
#define MCPRXB0D2 0x68
#define MCPRXB0D3 0x69
#define MCPRXB0D4 0x6A
#define MCPRXB0D5 0x6B
#define MCPRXB0D6 0x6C
#define MCPRXB0D7 0x6D

#define MCPRXB1CTRL 0x70
#define MCPRXB1SIDH 0x71
#define MCPRXB1SIDL 0x72
#define MCPRXB1EID8 0x73
#define MCPRXB1EID0 0x74
#define MCPRXB1DLC 0x75
#define MCPRXB1D0 0x76
#define MCPRXB1D1 0x77
#define MCPRXB1D2 0x78
#define MCPRXB1D3 0x79
#define MCPRXB1D4 0x7A
#define MCPRXB1D5 0x7B
#define MCPRXB1D6 0x7C
#define MCPRXB1D7 0x7D

//	Bitdefinition von BFPCTRL
#define MCPB1BFS 5
#define MCPB0BFS 4
#define MCPB1BFE 3
#define MCPB0BFE 2
#define MCPB1BFM 1
#define MCPB0BFM 0

//	Bitdefinition von TXRTSCTRL
#define MCPB2RTS 5
#define MCPB1RTS 4
#define MCPB0RTS 3
#define MCPB2RTSM 2
#define MCPB1RTSM 1
#define MCPB0RTSM 0

//	Bitdefinition von CANSTAT
#define MCPOPMOD2 7
#define MCPOPMOD1 6
#define MCPOPMOD0 5
#define MCPICOD2 3
#define MCPICOD1 2
#define MCPICOD0 1

//	Bitdefinition von CANCTRL
#define MCPREQOP2 7
#define MCPREQOP1 6
#define MCPREQOP0 5
#define MCPABAT 4
#define MCPCLKEN 2
#define MCPCLKPRE1 1
#define MCPCLKPRE0 0

//	Bitdefinition von CNF3
#define MCPWAKFIL 6
#define MCPPHSEG22 2
#define MCPPHSEG21 1
#define MCPPHSEG20 0

//	Bitdefinition von CNF2
#define MCPBTLMODE 7
#define MCPSAM 6
#define MCPPHSEG12 5
#define MCPPHSEG11 4
#define MCPPHSEG10 3
#define MCPPHSEG2 2
#define MCPPHSEG1 1
#define MCPPHSEG0 0

//	Bitdefinition von CNF1
#define MCPSJW1 7
#define MCPSJW0 6
#define MCPBRP5 5
#define MCPBRP4 4
#define MCPBRP3 3
#define MCPBRP2 2
#define MCPBRP1 1
#define MCPBRP0 0

//	Bitdefinition von CANINTE
#define MCPMERRE 7
#define MCPWAKIE 6
#define MCPERRIE 5
#define MCPTX2IE 4
#define MCPTX1IE 3
#define MCPTX0IE 2
#define MCPRX1IE 1
#define MCPRX0IE 0

//	Bitdefinition von CANINTF
#define MCPMERRF 7
#define MCPWAKIF 6
#define MCPERRIF 5
#define MCPTX2IF 4
#define MCPTX1IF 3
#define MCPTX0IF 2
#define MCPRX1IF 1
#define MCPRX0IF 0

//	Bitdefinition von EFLG
#define MCPRX1OVR 7
#define MCPRX0OVR 6
#define MCPTXB0 5
#define MCPTXEP 4
#define MCPRXEP 3
#define MCPTXWAR 2
#define MCPRXWAR 1
#define MCPEWARN 0

//	Bitdefinition von TXBnCTRL ( n = 0, 1, 2 )
#define MCPABTF 6
#define MCPMLOA 5
#define MCPTXERR 4
#define MCPTXREQ 3
#define MCPTXP1 1
#define MCPTXP0 0

//	Bitdefinition von RXB0CTRL
#define MCPRXM1 6
#define MCPRXM0 5
#define MCPRXRTR 3
#define MCPBUKT 2
#define MCPBUKT1 1
#define MCPFILHIT0 0

//	Bitdefinition von RXB1CTRL
#define MCPFILHIT2 2
#define MCPFILHIT1 1

//	Bitdefinition von RXBnSIDL ( n = 0, 1 )
#define MCPSRR 4
#define MCPIDE 3

//	Bitdefinition von RXBnDLC ( n = 0, 1 )
#define MCPRTR 6
#define MCPDLC3 3
#define MCPDLC2 2
#define MCPDLC1 1
#define MCPDLC0 0


////////////////////////////////////////////////////////////////////////////////
// Globale Variablen                                                          //
////////////////////////////////////////////////////////////////////////////////

tByte MCPNBtR;


////////////////////////////////////////////////////////////////////////////////
// Funktionen                                                                 //
////////////////////////////////////////////////////////////////////////////////

void MCP2515Reset(void) {
  SPISetSSLow();
  SPIWrite(MCPReset);
  SPISetSSHigh();
}

tByte MCP2515ReadReg(tByte pAddr) {

  tByte Value;

  SPISetSSLow();
  SPIWrite(MCPRead);
  SPIWrite(pAddr);
  Value = SPIRead();
  SPISetSSHigh();
  return Value;
}

void MCP2515WriteReg(tByte pAddr, tByte pValue) {
  SPISetSSLow();
  SPIWrite(MCPWrite);
  SPIWrite(pAddr);
  SPIWrite(pValue);
  SPISetSSHigh();
}

void MCP2515ModBitReg(tByte pAddr, tByte pMask, tByte pValue) {
  SPISetSSLow();
  SPIWrite(MCPModBit);
  SPIWrite(pAddr);
  SPIWrite(pMask);
  SPIWrite(pValue);
  SPISetSSHigh();
}

void MCP2515InitBegin(void) {
  MCPNBtR = 0;

  SPIInit();

  MCP2515Reset();
  
  MCP2515WriteReg(MCPCNF1, (1 << MCPBRP5) | (1 << MCPBRP4) | (1 << MCPBRP0));
  MCP2515WriteReg(MCPCNF2, (1 << MCPBTLMODE) | (1 << MCPPHSEG12) | (1 << MCPPHSEG11) | (1 << MCPPHSEG0));
  MCP2515WriteReg(MCPCNF3, (1 << MCPPHSEG22) | (1 << MCPPHSEG20));

  MCP2515WriteReg(MCPRXB0CTRL, (1 << MCPRXM1) | (1 << MCPBUKT));
  MCP2515WriteReg(MCPRXB1CTRL, (1 << MCPRXM1));
}

void MCP2515InitEnd(void) {
  MCP2515ModBitReg(MCPCANCTRL, 0xE0, 0);
}

void MCP2515SetFMask(tByte pFMask, tByte pSIDH, tByte pSIDL, tByte pEIDH, tByte pEIDL) {
  SPISetSSLow();
  SPIWrite(MCPWrite);
  if(pFMask == 0)
    SPIWrite(MCPRXM0SIDH);
  else
    SPIWrite(MCPRXM1SIDH);
  SPIWrite(pSIDH);
  SPIWrite(pSIDL);
  SPIWrite(pEIDH);
  SPIWrite(pEIDL);
  SPISetSSHigh();
}

void MCP2515SetFilter(tByte pFilter, tByte pSIDH, tByte pSIDL, tByte pEIDH, tByte pEIDL) {
  SPISetSSLow();
  SPIWrite(MCPWrite);
  if(pFilter < 3)
    SPIWrite(pFilter * 4);
  else
    SPIWrite(pFilter * 4 + 4);
  SPIWrite(pSIDH);
  SPIWrite(pSIDL);
  SPIWrite(pEIDH);
  SPIWrite(pEIDL);
  SPISetSSHigh();
}

tByte MCP2515GetMessage(tMCPMessage *pMessage) {

  tByte RXStatus;
  tByte i;

  SPISetSSLow();
  SPIWrite(MCPRXStatus);
  RXStatus = SPIRead();
  SPIRead();
  SPISetSSHigh();
  if(RXStatus & 0x40 && !(MCPNBtR && RXStatus & 0x80)) {
    SPISetSSLow();
    SPIWrite(MCPReadRX);
    MCPNBtR = 1;
  }
  else
    if(RXStatus & 0x80) {
      SPISetSSLow();
      SPIWrite(MCPReadRX | 0x04);
      MCPNBtR = 0;
    }
    else
      return 0;
  pMessage->SIDH = SPIRead();
  pMessage->SIDL = SPIRead();
  pMessage->EIDH = SPIRead();
  pMessage->EIDL = SPIRead();
  pMessage->Length = SPIRead() & 0x0F;
  for(i = 0; i < pMessage->Length; i++) pMessage->Data[i] = SPIRead();
  SPISetSSHigh();
  return 1;
}

tByte MCP2515PutMessage(tMCPMessage *pMessage) {

  tByte TXStatus;
  tByte SelBufAddr;
	tByte i;

  SPISetSSLow();
  SPIWrite(MCPReadStatus);
  TXStatus = SPIRead();
  SPIRead();
  SPISetSSHigh();
  if((TXStatus & 0x54) == 0)
    SelBufAddr = 0x04;
  else
    if((TXStatus & 0x14) == 0)
      SelBufAddr = 0x02;
    else
      if((TXStatus & 0x04) == 0)
        SelBufAddr = 0x00;
      else
        return 0;
  SPISetSSLow();
  SPIWrite(MCPWriteTX | SelBufAddr);
  SPIWrite(pMessage->SIDH);
  SPIWrite(pMessage->SIDL);
  SPIWrite(pMessage->EIDH);
  SPIWrite(pMessage->EIDL);
  if(pMessage->Length > 8) pMessage->Length = 8;
  SPIWrite(pMessage->Length);
  for(i = 0; i < pMessage->Length; i++) SPIWrite(pMessage->Data[i]);
  SPISetSSHigh();
  asm volatile ("nop");
  SPISetSSLow();
  if(SelBufAddr == 0x00)
    SPIWrite(MCPRTS | 0x01);
  else
    SPIWrite(MCPRTS | SelBufAddr);
  SPISetSSHigh();
  return 1;
}
