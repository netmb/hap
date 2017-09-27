////////////////////////////////////////////////////////////////////////////////
// Projekt:              Home-Automation                                      //
// Modul:                Modulverwaltung                                      //
// Version:              2.5 (10)                                             //
////////////////////////////////////////////////////////////////////////////////
// Erstellt am:          06.01.2006                                           //
// Erstellt von:         Holger Heuser                                        //
// Zuletzt geändert am:  28.12.2009                                           //
// Zuletzt geändert von: Carsten Wolff                                        //
////////////////////////////////////////////////////////////////////////////////

#ifndef MV
#define MV


////////////////////////////////////////////////////////////////////////////////
// Software-Version festlegen                                                 //
////////////////////////////////////////////////////////////////////////////////

#define SVHAMajor 2
#define SVHAMinor 5
#define SVHAPhase 14


////////////////////////////////////////////////////////////////////////////////
// Compiler-Optionen festlegen                                                //
////////////////////////////////////////////////////////////////////////////////

// COHALCD - LCD-Display ///////////////////////////////////////////////////////
// 1 - Display 1 x  8    (nicht implementiert)
// 2 - Display 2 x 16
// 3 - Display 3 x 16

// COHADG - Drehgeber //////////////////////////////////////////////////////////
// 1 - PEC11
// 2 - STEC

#define COHAES                // EEPROM-Support                    (Bit  0 -  0)
//#define COHAER                // Externer Reset                    (Bit  1 -  1)
#define COHABZ                // Buzzer                            (Bit  2 -  2)
#define COHAFM                // Funkmodul                         (Bit  3 -  3)
#define COHACB                // CAN-Bus                           (Bit  4 -  4)
//#define COHAIR                // Infrarotschnittstelle             (Bit  5 -  5)
//#define COHALCD 2             // siehe oben                        (Bit  6 -  7)
//#define COHALI                // Logischer Eingang                 (Bit  8 -  8)
//#define COHAAI                // Analoger Eingang                  (Bit  9 -  9)
//#define COHADIDS1820          // Dallas Digitales Thermometer      (Bit 10 - 10)
//#define COHASW                // Geschalteter Ausgang              (Bit 11 - 11)
//#define COHADM                // Gedimmter Ausgang                 (Bit 12 - 12)
//#define COHARS                // Rollladensteuerung                (Bit 13 - 13)
//#define COHADG 2              // siehe oben                        (Bit 14 - 15)
//#define COHAGUI               // Bedienoberfläche                  (Bit 16 - 16)
//#define COHAAS                // Autonome Steuerung                (Bit 17 - 17)


////////////////////////////////////////////////////////////////////////////////
// Compiler-Optionen berechnen                                                //
////////////////////////////////////////////////////////////////////////////////

#ifdef COHALCD
#if COHALCD == 1
#define COHALCD1X8
#endif
#if COHALCD == 2
#define COHALCD2X16
#endif
#if COHALCD == 3
#define COHALCD3X16
#endif
#endif

#ifndef COHADI
#ifdef COHADIDS1820
#define COHADI
#endif
#endif

#ifdef COHADG
#if COHADG == 1
#define COHADGPEC11
#endif
#if COHADG == 2
#define COHADGSTEC
#endif
#endif

#ifndef COHAAM
#ifdef COHARS
#define COHAAM
#endif
#endif
#ifndef COHAAM
#ifdef COHADG
#define COHAAM
#endif
#endif
#ifndef COHAAM
#ifdef COHAGUI
#define COHAAM
#endif
#endif

#ifdef COHAES
#define COHAESCC 0x01
#else
#define COHAESCC 0x00
#endif

#ifdef COHAER
#define COHAERCC 0x02
#else
#define COHAERCC 0x00
#endif

#ifdef COHABZ
#define COHABZCC 0x04
#else
#define COHABZCC 0x00
#endif

#ifdef COHAFM
#define COHAFMCC 0x08
#else
#define COHAFMCC 0x00
#endif

#ifdef COHACB
#define COHACBCC 0x10
#else
#define COHACBCC 0x00
#endif

#ifdef COHAIR
#define COHAIRCC 0x20
#else
#define COHAIRCC 0x00
#endif

#ifdef COHALCD
#define COHALCDCC (COHALCD << 6)
#else
#define COHALCDCC 0x00
#endif

#ifdef COHALI
#define COHALICC 0x100
#else
#define COHALICC 0x00
#endif

#ifdef COHAAI
#define COHAAICC 0x200
#else
#define COHAAICC 0x00
#endif

#ifdef COHADIDS1820
#define COHADIDS1820CC 0x400
#else
#define COHADIDS1820CC 0x00
#endif

#ifdef COHASW
#define COHASWCC 0x800
#else
#define COHASWCC 0x00
#endif

#ifdef COHADM
#define COHADMCC 0x1000
#else
#define COHADMCC 0x00
#endif

#ifdef COHARS
#define COHARSCC 0x2000
#else
#define COHARSCC 0x00
#endif

#ifdef COHADG
#define COHADGCC (COHADG << 14)
#else
#define COHADGCC 0x00
#endif

#ifdef COHAGUI
#define COHAGUICC 0x10000
#else
#define COHAGUICC 0x00
#endif

#ifdef COHAAS
#define COHAASCC 0x20000
#else
#define COHAASCC 0x00
#endif

#define COHA (COHAESCC | COHABZCC | COHAFMCC | COHACBCC | COHAIRCC | COHALCDCC | COHALICC | COHAAICC | COHADIDS1820CC | COHASWCC | COHADMCC | COHARSCC | COHADGCC | COHAGUICC | COHAASCC | COHAERCC)


#endif
