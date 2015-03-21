
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `hap` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `hap`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `abstractdevice` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Type` int(11) default NULL,
  `SubType` int(11) NOT NULL default '0',
  `Module` int(11) NOT NULL default '0',
  `Address` int(11) NOT NULL default '0',
  `ChildDevice0` int(11) default NULL,
  `ChildDevice1` int(11) default NULL,
  `ChildDevice2` int(11) default NULL,
  `ChildDevice3` int(11) default NULL,
  `Makro` int(11) default NULL,
  `Notify` int(11) default '0',
  `Attrib0` varchar(32) default NULL,
  `Attrib1` varchar(32) default NULL,
  `Attrib2` varchar(32) default NULL,
  `Attrib3` varchar(32) default NULL,
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=121 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `ac_objects` (
  `ID` int(11) NOT NULL auto_increment,
  `Sequence` int(11) default NULL,
  `Module` int(11) default NULL,
  `Object` int(11) default NULL,
  `Type` int(11) default NULL,
  `Prop1` int(11) default NULL,
  `Prop2` int(11) default NULL,
  `Prop3` int(11) default NULL,
  `ConfigObject` text,
  `X` int(11) NOT NULL,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=5427 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `ac_sequence` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Module` int(11) default NULL,
  `Room` int(11) default NULL,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=156 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `ac_types` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Type` int(11) default NULL,
  `Description` mediumtext,
  `InPorts` tinyint(4) default '0',
  `OutPorts` tinyint(4) default '1',
  `ShortName` varchar(64) default NULL,
  `Display` varchar(255) default '{}',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=91 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `analoginput` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Analog Input',
  `Module` int(11) NOT NULL default '0',
  `Address` int(11) NOT NULL default '0',
  `Port` int(11) NOT NULL default '0',
  `Pin` int(11) NOT NULL default '0',
  `Measure` varchar(512) default NULL,
  `Unit` varchar(32) NOT NULL default '',
  `Correction` float default NULL,
  `Notify` int(11) default '0',
  `SampleRate` float NOT NULL default '10',
  `Trigger0` float default '0',
  `Trigger0Hyst` int(11) default '0',
  `Trigger0Notify` int(11) default '0',
  `Trigger1` float default '0',
  `Trigger1Hyst` int(11) default '0',
  `Trigger1Notify` int(11) default '0',
  `Status` float default NULL,
  `Makro` int(11) default NULL,
  `Room` int(11) default NULL,
  `Formula` varchar(255) default NULL,
  `FormulaDescription` varchar(255) default NULL,
  `Config` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `config` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) NOT NULL default '',
  `IsDefault` smallint(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  UNIQUE KEY `code_unique` (`Name`)
) ENGINE=MyISAM AUTO_INCREMENT=132 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `device` (
  `ID` int(11) NOT NULL auto_increment,
  `ParentID` int(11) default '0',
  `Name` varchar(64) default 'Device',
  `Type` int(11) NOT NULL default '0',
  `Module` int(11) NOT NULL default '0',
  `Port` int(11) NOT NULL default '0',
  `Pin` int(11) NOT NULL default '0',
  `Address` int(11) NOT NULL default '0',
  `Makro` int(11) default NULL,
  `Notify` int(11) default '0',
  `Room` int(11) default NULL,
  `Formula` varchar(255) default '',
  `FormulaDescription` varchar(255) default '',
  `Description` varchar(255) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  KEY `Modul` (`Module`)
) ENGINE=MyISAM AUTO_INCREMENT=709 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `homematic` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(63) DEFAULT NULL,
  `Module` int(11) NOT NULL DEFAULT '0',
  `Address` int(11) NOT NULL DEFAULT '0',
  `HomematicAddress` varchar(6) NOT NULL DEFAULT '0',
  `HomematicDeviceType` int(11) NOT NULL DEFAULT '0',
  `Notify` int(11) DEFAULT NULL,
  `Room` int(11) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Formula` varchar(255) DEFAULT '',
  `FormulaDescription` varchar(255) DEFAULT '',
  `Config` int(11) NOT NULL,
  `Channel` int(11) DEFAULT '1',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `digitalinput` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Digital Input',
  `Module` int(11) NOT NULL default '0',
  `Address` int(11) NOT NULL default '0',
  `Port` int(11) NOT NULL default '0',
  `Pin` int(11) NOT NULL default '0',
  `Type` int(11) NOT NULL,
  `Notify` int(11) default '0',
  `SampleRate` float NOT NULL default '0',
  `Trigger0` float default NULL,
  `Trigger0Hyst` float default NULL,
  `Trigger0Notify` int(11) default NULL,
  `Trigger1` float default NULL,
  `Trigger1Hyst` float default NULL,
  `Trigger1Notify` int(11) default NULL,
  `Makro` int(11) default NULL,
  `Room` int(11) default NULL,
  `Config` int(1) NOT NULL default '0',
  `Formula` varchar(255) default NULL,
  `FormulaDescription` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=62 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `firmware` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `VMajor` int(11) NOT NULL,
  `VMinor` int(11) NOT NULL,
  `VPhase` int(11) NOT NULL,
  `Date` varchar(8) NOT NULL,
  `Filename` varchar(64) NOT NULL default '/',
  `Content` mediumblob NOT NULL,
  `PreCompiled` tinyint(1) default '0',
  `CompileOptions` int(11) default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=130 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_area` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Image` varchar(32) default NULL,
  `Root` tinyint(1) default '0',
  `Scene` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 PACK_KEYS=0;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_map` (
  `ID` int(11) NOT NULL auto_increment,
  `SourceArea` int(11) NOT NULL default '0',
  `DestArea` int(11) NOT NULL default '0',
  `X` double default '0',
  `Y` double default '0',
  `Width` double default '0',
  `Height` double default '0',
  `Scene` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  KEY `SourceArea` (`SourceArea`),
  KEY `DestArea` (`DestArea`)
) ENGINE=MyISAM AUTO_INCREMENT=375 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_objects` (
  `ID` int(11) NOT NULL auto_increment,
  `SceneID` int(11) default NULL,
  `Type` varchar(32) default NULL,
  `ConfigObject` text,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=3495 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_scene` (
  `ID` int(11) NOT NULL auto_increment,
  `ViewID` int(11) default NULL,
  `IsDefault` smallint(1) default '0',
  `CenterX` smallint(1) default '0',
  `CenterY` smallint(1) default '0',
  `Name` varchar(64) default NULL,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=121 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_types` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Type` varchar(32) default NULL,
  `Description` mediumtext,
  `Display` varchar(255) default '{}',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `gui_view` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `IsDefault` smallint(1) default NULL,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `lcd_objects` (
  `ID` int(11) NOT NULL auto_increment,
  `AbstractDevID` int(11) default NULL,
  `Type` int(11) default NULL,
  `Offset` int(11) default NULL,
  `String` text,
  `ConfigObject` text,
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=1466 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `lcd_types` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default NULL,
  `Type` int(11) default NULL,
  `Description` mediumtext,
  `InPorts` tinyint(4) default '0',
  `OutPorts` tinyint(4) default '1',
  `ShortName` varchar(64) default NULL,
  `Display` varchar(255) default '{}',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=85 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `log` (
  `ID` int(11) NOT NULL auto_increment,
  `PID` int(11) default NULL,
  `Time` datetime default NULL,
  `Source` varchar(64) default NULL,
  `Type` varchar(64) default NULL,
  `Message` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=13439 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `logicalinput` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Logical Input',
  `Module` int(11) NOT NULL default '0',
  `Address` int(11) NOT NULL default '0',
  `Port` int(11) NOT NULL default '0',
  `Pin` int(11) NOT NULL default '0',
  `Type` int(11) default NULL,
  `Notify` int(11) default '0',
  `Makro` int(11) default NULL,
  `Room` int(11) default NULL,
  `Formula` varchar(255) default NULL,
  `FormulaDescription` varchar(255) default NULL,
  `Config` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=260 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `makro` (
  `ID` int(11) NOT NULL auto_increment,
  `MakroNr` int(11) default '0',
  `Name` varchar(64) default 'Makro',
  `Module` int(11) default NULL,
  `Script` varchar(128) default NULL,
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `module` (
  `ID` int(11) NOT NULL auto_increment,
  `UID` varchar(6) default '000000',
  `Name` varchar(64) default 'Module',
  `Address` int(11) NOT NULL default '0',
  `StartMode` int(11) NOT NULL default '217',
  `CCUAddress` int(11) NOT NULL default '0',
  `DevOption` int(11) default '0',
  `OldAddress` int(11) default '0',
  `Description` varchar(255) default NULL,
  `BuzzerLevel` int(11) default '0',
  `VLAN` int(11) default NULL,
  `CANVLAN` int(11) default NULL,
  `CryptKey0` int(11) default '0',
  `CryptKey1` int(11) default '0',
  `CryptKey2` int(11) default '0',
  `CryptKey3` int(11) default '0',
  `CryptKey4` int(11) default '0',
  `CryptKey5` int(11) default '0',
  `CryptKey6` int(11) default '0',
  `CryptKey7` int(11) default '0',
  `CryptOption` int(11) default '0',
  `BridgeMode` int(11) default '0',
  `LIBounceDelay` int(11) default '10',
  `LIShortDelay` int(11) default '50',
  `LILongDelay` int(11) default '150',
  `ReceiveBuffer` int(11) default '4',
  `DimmerTicLength` int(11) default '60',
  `DimmerCycleLength` int(11) default '6',
  `FirmwareOptions` int(11) default NULL,
  `FirmwareVersion` varchar(18) default NULL,
  `IsTimeServer` tinyint(1) default NULL,
  `Room` int(11) default NULL,
  `IsCCU` tinyint(1) default '0',
  `IsCCUModule` tinyint(1) default '0',
  `FirmwareID` int(11) default '0',
  `CurrentFirmwareOptions` int(11) unsigned default '0',
  `CurrentFirmwareID` int(11) default NULL,
  `UpstreamModule` int(11) default NULL,
  `UpstreamInterface` int(11) default NULL,
  `MCastGroups` int(11) default '32768',
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=261 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `rangeextender` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Range Extender',
  `Module` int(11) default NULL,
  `DestModule` int(11) default NULL,
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `remotecontrol` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default 'Remote Control',
  `Module` int(11) default NULL,
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `remotecontrol_hotkey` (
  `ID` int(11) NOT NULL auto_increment,
  `Module` int(11) NOT NULL default '0',
  `Key` int(11) NOT NULL default '0',
  `MacroNumber` int(11) NOT NULL default '0',
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  KEY `Modul` (`Module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `remotecontrol_learned` (
  `ID` int(11) NOT NULL auto_increment,
  `RemoteControl` int(11) NOT NULL default '0',
  `Name` varchar(64) default 'Remote Control Learned',
  `Module` int(11) default '0',
  `Address` int(11) default '0',
  `Code` int(11) default '0',
  `Action` int(11) default '0',
  `Room` int(11) default NULL,
  `Config` int(11) default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=151 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `remotecontrol_mapping` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Remote Control',
  `Module` int(11) NOT NULL default '0',
  `IRKey` int(11) NOT NULL default '0',
  `DestDevice` int(11) NOT NULL default '0',
  `DestVirtModule` int(11) default '0',
  `DestMakroNr` int(11) default '0',
  `Room` int(11) default NULL,
  `Config` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  KEY `Modul` (`Module`)
) ENGINE=MyISAM AUTO_INCREMENT=90 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `roles` (
  `ID` int(11) NOT NULL auto_increment,
  `Role` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `room` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(64) default 'Room',
  `Description` varchar(255) default NULL,
  `Config` int(11) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=133 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `scheduler` (
  `ID` int(11) NOT NULL auto_increment,
  `Cron` varchar(24) default NULL,
  `Cmd` varchar(32) default NULL,
  `Args` varchar(128) default NULL,
  `Status` smallint(6) default '0',
  `Description` varchar(255) default '',
  `Makro` smallint(1) DEFAULT '0',
  `Config` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=1274 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_address` (
  `ID` int(11) NOT NULL auto_increment,
  `Address` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=257 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_bootloaderid` (
  `ID` int(11) NOT NULL auto_increment,
  `BootloaderID` varchar(6) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_devicetypes` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  `ParserCmd` varchar(255) default NULL,
  `DefaultPortPin` varchar(3) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_digitalinputtypes` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  `ParserCmd` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_encryptionmodes` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  `ParserCmd` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_inputvaluetemplates` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_interfaces` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default '4',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_ircodes` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Code` int(11) default NULL,
  `ParserCmd` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_logicalinputtemplates` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_outputvaluetemplates` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_portpin` (
  `ID` int(11) NOT NULL auto_increment,
  `Port` int(11) default NULL,
  `Pin` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_schedulercommands` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(64) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_startmodes` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Type` int(11) default NULL,
  `ParserCmd` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_timebase` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(32) default NULL,
  `Value` smallint(6) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_messagetypes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Type` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `makro_by_datagram` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `VLAN` int(11) DEFAULT NULL,
  `Source` int(11) DEFAULT NULL,
  `Destination` int(11) DEFAULT NULL,
  `MType` int(11) DEFAULT NULL,
  `Address` int(11) DEFAULT NULL,
  `V0` varchar(5) DEFAULT NULL,
  `V1` varchar(5) DEFAULT NULL,
  `V2` varchar(5) DEFAULT NULL,
  `Makro` int(11) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Config` int(11) NOT NULL DEFAULT '0',
  `Active` int(1) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_homematicdevicetypes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(63) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `static_weekdays` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` varchar(32) default NULL,
  `Value` smallint(6) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `status` (
  `ID` int(11) NOT NULL auto_increment,
  `TS` int(11) unsigned default NULL,
  `Type` tinyint(4) unsigned default NULL,
  `Module` int(11) unsigned default NULL,
  `Address` tinyint(4) unsigned default NULL,
  `Status` float default NULL,
  `Config` smallint(6) unsigned default NULL,
  PRIMARY KEY  (`ID`),
  KEY `ID` (`ID`),
  KEY `Type` (`Type`),
  KEY `Module` (`Module`),
  KEY `Address` (`Address`),
  KEY `TS` (`TS`),
  KEY `Config` (`Config`)
) ENGINE=MyISAM AUTO_INCREMENT=70599 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) NOT NULL auto_increment,
  `Username` varchar(255) default NULL,
  `Password` varchar(255) default NULL,
  `Prename` varchar(255) default NULL,
  `Surname` varchar(255) default NULL,
  `EMail` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `users_roles` (
  `User` int(11) NOT NULL,
  `Role` int(11) NOT NULL,
  PRIMARY KEY  (`User`,`Role`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
REPLACE INTO `ac_types` VALUES (1, 'No Operation', 0, 'Bei diesem Objekt gibt es keine weiteren Eigenschaften bzw. diese sind nicht relevant. Der Ausgangswert dieses Objekts ist stets 0. Wird ein Objekt nicht explizit konfiguriert, so ist es von diesem Typ. Um den Speicherplatzbedarf zur Laufzeit gering zu halten, sollte mÃ¶glichst kein Objekt dieses Typs zwischen anderen Objekten in der Reihenfolge stehen. Stehen diese Objekte am Ende der Objektfolge, so werden sie nicht berÃ¼cksichtigt und es wird auch kein Speicher dafÃ¼r benÃ¶tigt.', 0, 1, 'No Operation', '{"Label": ""}'), (2, 'Timer (MinuziÃ¶se AusfÃ¼hrung) ', 32, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn sich die Zeit in einem bestimmten abgeschlossenen minuziÃ¶sen Intervall befindet. Andernfalls ist der Ausgang 0. Das Intervall wird definiert durch den Startwert innerhalb der Minute und die LÃ¤nge des Intervalls. Der Startwert errechnet sich aus den 6 niederwertigen Bits der 1-ten Eigenschaft in Sekunden plus den 4 niederwertigen Bits der 2-ten Eigenschaft in 1/10 Sekunden. Die LÃ¤nge des Intervalls ergibt sich aus den 2 hÃ¶herwertigen Bits der 1-ten Eigenschaft multipliziert mit 256 plus des Werts der 3-ten Eigenschaft in 1/10 Sekunden.\r\n', 0, 1, 'Timer (min)', '{"Start Value (s)" : 0, "Interval (1/10s)": 0 , "Label": ""}'), (3, 'Timer (StÃ¼ndliche AusfÃ¼hrung)', 33, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn sich die Zeit in einem bestimmten abgeschlossenen stÃ¼ndlichen Intervall befindet. Andernfalls ist der Ausgang 0. Das Intervall wird definiert durch den Startwert innerhalb der Stunde und die LÃ¤nge des Intervalls. Der Startwert errechnet sich aus den 6 niederwertigen Bits der 1-ten Eigenschaft in Minuten plus der 6 niederwertigen Bits der 2-ten Eigenschaft in Sekunden. Die LÃ¤nge des Intervalls ergibt sich aus den 2 hÃ¶herwertigen Bits der 1-ten Eigenschaft multipliziert mit 1024 plus den 2 hÃ¶herwertigen Bits der 2-ten Eigenschaft multipliziert mit 256 plus des Werts der 3-ten Eigenschaft in Sekunden.\r\n', 0, 1, 'Timer (h)', '{"Start Value (mm:ss)" : 0, "Interval (s)": 0  , "Label": ""}'), (4, 'Timer (TÃ¤gliche AusfÃ¼hrung)', 34, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn sich die Zeit in einem bestimmten abgeschlossenen tÃ¤glichen Intervall befindet. Andernfalls ist der Ausgang 0. Das Intervall wird definiert durch den Startwert innerhalb des Tages und die LÃ¤nge des Intervalls. Der Startwert errechnet sich aus den 5 niederwertigen Bits der 1-ten Eigenschaft in Stunden plus der 6 niederwertigen Bits der 2-ten Eigenschaft in Minuten. Die LÃ¤nge des Intervalls ergibt sich aus den 2 hÃ¶herwertigen Bits der 2-ten Eigenschaft multipliziert mit 256 plus des Werts der 3-ten Eigenschaft in Minuten. Dieser Mechanismus funktioniert an Werktagen nur, wenn das Bit 5, an Samstagen, wenn das Bit 6 und an Sonntagen, wenn das Bit 7 der 1-ten Eigenschaft gesetzt ist.', 0, 1, 'Timer (d)', '{"Start Value (hh:mm)": 0, "Interval (m)": 0, "Mo.-Fr.": 0, "Saturday": 0, "Sunday":0 , "Label": ""}'), (5, 'Timer (WÃ¶chentliche AusfÃ¼hrung)', 35, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn sich die Zeit in einem bestimmten abgeschlossenen wÃ¶chentlichen Intervall befindet. Andernfalls ist der Ausgang 0. Das Intervall wird definiert durch den Startwert innerhalb der Woche und die LÃ¤nge des Intervalls. Der Startwert errechnet sich aus den 3 hÃ¶herwertigen Bits der 1-ten Eigenschaft in Tagen plus die 5 niederwertigen Bits der 1-ten Eigenschaft in Stunden plus die 6 niederwertigen Bits der 2-ten Eigenschaft in Minuten. Die LÃ¤nge des Intervalls ergibt sich aus den 2 hÃ¶herwertigen Bits der 2-ten Eigenschaft multipliziert mit 256 plus des Werts der 3-ten Eigenschaft in Minuten.\r\n', 0, 1, 'Timer (w)', '{"Start Value (d)": 0, "Start Value (hh:mm)": 0, "Intervall (m)": 0  , "Label": ""}'), (6, 'Eingang (aktiv)', 56, 'Der Ausgang dieses Objekts prÃ¤sentiert das Ergebnis der Abfrage eines bestimmten GerÃ¤tes. In der 1-ten Eigenschaft ist dabei die Modul-Adresse des Moduls zu hinterlegen, an der eben dieses GerÃ¤t angeschlossen ist. Die 2-te Eigenschaft gibt die entsprechende GerÃ¤te-Adresse an. Die 3-te Eigenschaft definiert in 1/10 Sekunden das Intervall, in dem die Abfrage wiederholt, der Wert des Ausgangs also aktualisiert wird. Wenn insbesondere das GerÃ¤t nicht an dem Modul betrieben wird, auf dem die zu konfigurierende autonome Steuerung lÃ¤uft, empfiehlt es sich, diesen Wert hinreichend groÃŸ zu wÃ¤hlen, um den Funkverkehr mÃ¶glichst klein zu halten. Handelt es sich bei dem abzufragenden GerÃ¤t um einen analogen Eingang, so wird der 10 Bit groÃŸe Ergebniswert auf einen 8 Bit groÃŸen gekÃ¼rzt, indem die 2 niederwertigen Bits nicht beachtet werden.', 0, 1, 'Input active', '{"HAP-Module": 0, "HAP-Device": 0, "Interval (1/10s)": 0 , "Label": ""}'), (7, 'Eingang (passiv, nicht flÃ¼chtig)', 60, 'Der Ausgang dieses Objekts wird durch Empfangen einer Statusmeldung verÃ¤ndert. Die Modul-Adresse der Statusmeldung muÃŸ mit der Modul-Adresse des Moduls, auf dem die zu konfigurierende autonome Steuerung lÃ¤uft, identisch sein oder es muÃŸ sich um einen Broadcast handeln. ZusÃ¤tzlich muÃŸ die Absender-Adresse mit der 1-ten Eigenschaft sowie die GerÃ¤te-Adresse der Statusmeldung mit der 2-ten Eigenschaft Ã¼bereinstimmen. Ein eventuell 10 Bit groÃŸer Statuswert wird durch Nichtbeachtung der 2 niederwertigen Bits auf einen 8 Bit groÃŸen Wert gekÃ¼rzt. Nach einem Reset wird der Ausgang mit dem Wert der 3-ten Eigenschaft initialisiert.', 0, 1, 'Input passive', '{"HAP-Module": 0, "HAP-Device": 0,  "Init-Value": 0 , "Label": ""}'), (8, 'Bitweise Linksverschiebung (1 Eingang)', 69, 'Der Ausgangswert dieses Objekts ergibt sich durch eine bitweise Linksverschiebung des Eingangswertes. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die 2-te Eigenschaft kodiert die Anzahl der Bits, um die verschoben werden soll.', 1, 1, 'Bitwise left', '{"Shift-Bits": 0, "Label": ""}'), (9, 'Bitweise Rechtsverschiebung (1 Eingang)', 70, 'Der Ausgangswert dieses Objekts ergibt sich durch eine bitweise Rechtsverschiebung des Eingangswertes. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die 2-te Eigenschaft kodiert die Anzahl der Bits, um die verschoben werden soll.', 1, 1, 'Bitwise right', '{"Shift-Bits": 0, "Label": ""}'), (10, 'Vergleichsoperator â€žgleichâ€œ (1 Eingang)', 72, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs gleich dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare =', '{"Value": 0 , "Label": ""}'), (11, 'Vergleichsoperator â€žnicht gleichâ€œ (1 Eingang)', 73, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs nicht gleich dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare !=', '{"Value": 0 , "Label": ""}'), (12, 'Vergleichsoperator â€žkleinerâ€œ (1 Eingang)', 74, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs kleiner dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare <', '{"Value": 0 , "Label": ""}'), (13, 'Vergleichsoperator â€žkleiner oder gleichâ€œ (1 Eingang)', 75, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs kleiner oder gleich dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare <=', '{"Value": 0 , "Label": ""}'), (14, 'Vergleichsoperator â€žgrÃ¶ÃŸerâ€œ (1 Eingang)', 76, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs grÃ¶ÃŸer dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare >', '{"Value": 0 , "Label": ""}'), (15, 'Vergleichsoperator â€žgrÃ¶ÃŸer oder gleichâ€œ (1 Ein', 77, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des Eingangs grÃ¶ÃŸer oder gleich dem Wert der 2-ten Eigenschaft ist. Andernfalls ist der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Compare >=', '{"Value": 0 , "Label": ""}'), (16, 'Addition (1 Eingang)', 80, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Addition des Eingangswertes mit der 2-ten und 3-ten Eigenschaft. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Addition', '{"Value0": 0, "Value1": 0, "Label": ""}'), (17, 'Subtraktion (1 Eingang)', 81, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Subtraktion der 2-ten und 3-ten Eigenschaft vom Eingangswert. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Substr.', '{"Value0": 0, "Value1": 0, "Label": ""}'), (18, 'Multiplikation (1 Eingang)', 82, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Multiplikation des Eingangswertes mit der 2-ten und 3-ten Eigenschaft. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Multipl.', '{"Value0": 0, "Value1": 0, "Label": ""}'), (19, 'Division (1 Eingang)', 83, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Division des Eingangswertes durch die 2-te und 3-te Eigenschaft. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Divison', '{"Value0": 0, "Value1": 0, "Label": ""}'), (20, 'Multiplikation mit Offset', 84, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Addition der 2-ten Eigenschaft zum Eingangswert und anschlieÃŸender Multiplikation mit der 3-ten Eigenschaft dividiert durch 16. Die Rundung auf einen ganzzahligen Wert wird am Ende vorgenommen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Multipl. with offset', '{"Offset": 0, "Multiplicator": 0 , "Label": ""}'), (21, 'Division mit Offset ', 85, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Addition der 2-ten Eigenschaft zum Eingangswert und anschlieÃŸender Division der 3-ten Eigenschaft durch eben diesen Wert. Die Rundung auf einen ganzzahligen Wert wird am Ende vorgenommen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Division with offset', '{"Offset": 0, "Divisor": 0 , "Label": ""}'), (22, 'Regelglied 0', 96, 'Der Wert des Ausgangs dieses Objekts wird jeweils um die HÃ¤lfte der Differenz zwischen dem Eingangswert und einem Referenzwert korrigiert. Er kann dabei nicht grÃ¶ÃŸer als 255 und nicht kleiner als 0 werden. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Der Referenzwert wird mit der 2-ten Eigenschaft initialisiert.', 1, 1, 'Controller', '{"Reference": 0 , "Label": ""}'), (23, 'AusschaltverzÃ¶gerung', 112, 'Ist der Eingangswert dieses Objekts grÃ¶ÃŸer 0, so nimmt der Ausgang eben diesen Wert an und hÃ¤lt ihn fÃ¼r eine konfigurierbare Zeit, auch wenn der Eingangswert wieder 0 geworden ist. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die Zeit, um die der Ausschaltvorgang verzÃ¶gert wird, wird in der 3-ten Eigenschaft hinterlegt', 1, 1, 'Switch-off delay', '{"Time-Base": 0, "Value": 0 , "Label": ""}'), (24, 'EinschaltverzÃ¶gerung', 113, 'Ist der Eingangswert dieses Objekts grÃ¶ÃŸer 0, so wird dieser Wert erst nach einer konfigurierbaren Zeit auf den Ausgang Ã¼bertragen. Ist der Eingangswert 0, so wird auch der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die Zeit, um die der Einschaltvorgang verzÃ¶gert wird, wird in der 3-ten Eigenschaft hinterlegt', 1, 1, 'Switch-on delay', '{"Time-Base": 0, "Value": 0 , "Label": ""}'), (25, 'Ausgang', 120, 'Ã„ndert sich der Eingangswert dieses Objekts, so wird eben dieser Wert dividiert durch 2,55 (Der Wertebereich der autonomen Steuerung von 0 bis 255 wird auf 0 bis 100 begrenzt.) in Form eines Steuerbefehls weitergegeben. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die Modul-Adresse des Moduls, fÃ¼r das der Steuerbefehl bestimmt ist, wird in der 2-ten Eigenschaft gespeichert. Die 3-te Eigenschaft speichert schlieÃŸlich die GerÃ¤te-Adresse des ZielgerÃ¤tes.', 1, 0, 'Output', '{"HAP-Module": 0, "HAP-Device": 0 , "Label": ""}'), (26, 'Bitweise UND-VerknÃ¼pfung (2 EingÃ¤nge)', 128, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen UND-VerknÃ¼pfung der beiden EingÃ¤nge mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise AND', '{"Value": 0 , "Label": ""}'), (27, 'Bitweise ODER-VerknÃ¼pfung (2 EingÃ¤nge) ', 129, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen ODER-VerknÃ¼pfung der beiden EingÃ¤nge mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise OR', '{"Value": 0 , "Label": ""}'), (28, 'Bitweise NICHT-UND-VerknÃ¼pfung (2 EingÃ¤nge)', 130, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen NICHT-UND-VerknÃ¼pfung der beiden EingÃ¤nge mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise NAND', '{"Value": 0 , "Label": ""}'), (29, 'Bitweise NICHT-ODER-VerknÃ¼pfung (2 EingÃ¤nge)', 131, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen NICHT-ODER-VerknÃ¼pfung der beiden EingÃ¤nge mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt', 2, 1, 'Bitwise NOR', '{"Value": 0 , "Label": ""}'), (30, 'Bitweise EXKLUSIV-ODER-VerknÃ¼pfung (2 EingÃ¤nge)', 132, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen EXKLUSIV-ODER-VerknÃ¼pfung der beiden EingÃ¤nge mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise XOR', '{"Value": 0 , "Label": ""}'), (31, 'Bitweise Linksverschiebung (2 EingÃ¤nge)', 133, 'Der Ausgangswert dieses Objekts ergibt sich durch eine bitweise Linksverschiebung des 1-ten Eingangswertes. Der 2-te Eingangswert gibt die Anzahl der Bits an, um die verschoben werden soll. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise left', '{"Shift-Bits": 0, "Label": ""}'), (32, 'Bitweise Rechtsverschiebung (2 EingÃ¤nge)', 134, 'Der Ausgangswert dieses Objekts ergibt sich durch eine bitweise Rechtsverschiebung des 1-ten Eingangswertes. Der 2-te Eingangswert gibt die Anzahl der Bits an, um die verschoben werden soll. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Bitwise right', '{"Shift-Bits": 0, "Label": ""}'), (33, 'Vergleichsoperator â€žgleichâ€œ (2 EingÃ¤nge)', 136, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs gleich dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare =', '{"Label": ""}'), (34, 'Vergleichsoperator â€žnicht gleichâ€œ (2 EingÃ¤nge)', 137, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs nicht gleich dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare !=', '{"Label": ""}'), (35, 'Vergleichsoperator â€žkleinerâ€œ (2 EingÃ¤nge)', 138, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs kleiner dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare <', '{"Label": ""}'), (36, 'Vergleichsoperator â€žkleiner oder gleichâ€œ (2 EingÃ¤', 139, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs kleiner oder gleich dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare <=', '{"Label": ""}'), (37, 'Vergleichsoperator â€žgrÃ¶ÃŸerâ€œ (2 EingÃ¤nge)', 140, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs grÃ¶ÃŸer dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare >', '{"Label": ""}'), (38, 'Vergleichsoperator â€žgrÃ¶ÃŸer oder gleichâ€œ (2 Ein', 141, 'Der Ausgang dieses Objekts nimmt den Wert 255 an, wenn der Wert des 1-ten Eingangs grÃ¶ÃŸer oder gleich dem Wert des 2-ten Eingangs ist. Andernfalls ist der Ausgang 0. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Compare >=', '{"Label": ""}'), (39, 'Addition (2 EingÃ¤nge)', 144, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Addition der beiden Eingangswerte mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Addition', '{"Value": 0 , "Label": ""}'), (40, 'Subtraktion (2 EingÃ¤nge)', 145, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Subtraktion des 2-ten Eingangs und der 3-ten Eigenschaft vom 1-ten Eingang. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Substr.', '{"Value": 0 , "Label": ""}'), (41, 'Multiplikation (2 EingÃ¤nge)', 146, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Multiplikation der beiden Eingangswerte mit der 3-ten Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Multipl.', '{"Value": 0 , "Label": ""}'), (42, 'Division (2 EingÃ¤nge)', 147, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Division des 1-ten Eingangswertes durch den 2-ten Eingang und die 3-te Eigenschaft. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Division', '{"Value": 0 , "Label": ""}'), (43, 'Bitweise UND-VerknÃ¼pfung (3 EingÃ¤nge) ', 192, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen UND-VerknÃ¼pfung der drei EingÃ¤nge. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Bitwise AND', '{"Label": ""}'), (44, 'Bitweise ODER-VerknÃ¼pfung (3 EingÃ¤nge)', 193, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen ODER-VerknÃ¼pfung der drei EingÃ¤nge. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Bitwise OR', '{"Label": ""}'), (45, 'Bitweise NICHT-UND-VerknÃ¼pfung (3 EingÃ¤nge) ', 194, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen NICHT-UND-VerknÃ¼pfung der drei EingÃ¤nge. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Bitwise NAND', '{"Label": ""}'), (46, 'Bitweise NICHT-ODER-VerknÃ¼pfung (3 EingÃ¤nge) ', 195, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen NICHT-ODER-VerknÃ¼pfung der drei EingÃ¤nge. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Bitwise NOR', '{"Label": ""}'), (47, 'Bitweise EXKLUSIV-ODER-VerknÃ¼pfung (3 EingÃ¤nge)', 196, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der bitweisen EXKLUSIV-ODER-VerknÃ¼pfung der drei EingÃ¤nge. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Bitwise XOR', '{"Label": ""}'), (48, 'Addition (3 EingÃ¤nge)', 208, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Addition der drei Eingangswerte. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Addition', '{"Label": ""}'), (49, 'Subtraktion (3 EingÃ¤nge)', 209, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Subtraktion des 2-ten und 3-ten Eingangs vom 1-ten Eingang. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Substr.', '{"Label": ""}'), (50, 'Multiplikation (3 EingÃ¤nge)', 210, 'Der Wert des Ausgangs dieses Objekts ergibt sich aus der Multiplikation der drei Eingangswerte. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Multipl.', '{"Label": ""}'), (51, 'Division (3 EingÃ¤nge)', 211, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Division des 1-ten Eingangswertes durch den 2-ten und 3-ten Eingang. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Division ', '{"Label": ""}'), (52, 'Auf-/Ab-Steuerung 1-Taster-LÃ¶sung ', 100, 'Dieses Objekt setzt die Eingangswerte, wie sie von einem entsprechend konfigurierten logi-schen Eingang geliefert werden, in entsprechende Steuercodes um, wie sie zur Ansteuerung eines Dimmers oder eines Rollladens verwendet werden kÃ¶nnen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die 2-te und 3-te Eigenschaft wird nicht verwendet.', 1, 1, 'Up/Down 1 Button', '{"Label": ""}'), (53, 'Weiterleitung â€žkleinerâ€œ (1 Eingang) ', 104, 'Der Ausgang dieses Objektes nimmt den kleinsten Wert vom Eingang, der 2-ten Eigenschaft und der 3-ten Eigenschaft an. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Forward <', '{"Value0": 0, "Value1": 0 , "Label": ""}'), (54, 'Weiterleitung â€žmittlerenâ€œ (1 Eingang) ', 105, 'Der Ausgang dieses Objektes nimmt den mittleren Wert vom Eingang, der 2-ten Eigenschaft und der 3-ten Eigenschaft an. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Foward middle', '{"Value0": 0, "Value1": 0 , "Label": ""}'), (55, 'Weiterleitung â€žgrÃ¶ÃŸerâ€œ (1 Eingang) ', 106, 'Der Ausgang dieses Objektes nimmt den grÃ¶ÃŸten Wert vom Eingang, der 2-ten Eigenschaft und der 3-ten Eigenschaft an. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Forward >', '{"Value0": 0, "Value1": 0 , "Label": ""}'), (56, 'Weiterleitung â€žgesteuertâ€œ (1 Eingang) ', 107, 'Der Ausgang dieses Objektes nimmt den Wert der 2-ten Eigenschaft an, wenn der Eingang 0 ist. Andernfalls wird der Wert der 3-ten Eigenschaft angenommen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Forward controlled', '{"Value0": 0, "Value1": 0 , "Label": ""}'), (57, 'Ausgang (nativ)', 121, 'Ã„ndert sich der Eingangswert dieses Objekts, so wird eben dieser Wert in Form eines Steuerbefehls weitergegeben. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die Modul-Adresse des Moduls, fÃ¼r das der Steuerbefehl bestimmt ist, wird in der 2-ten Eigenschaft gespeichert. Die 3-te Eigenschaft speichert schlieÃŸlich die GerÃ¤te-Adresse des ZielgerÃ¤tes.', 1, 0, 'Output native', '{"HAP-Module": 0, "HAP-Device": 0 , "Label": ""}'), (58, 'Auf-/Ab-Steuerung 2-Taster-LÃ¶sung ', 164, 'Dieses Objekt setzt die Eingangswerte, wie sie von entsprechend konfigurierten logischen EingÃ¤ngen geliefert werden, in entsprechende Steuercodes um, wie sie zur Ansteuerung eines Dimmers oder eines Rollladens verwendet werden kÃ¶nnen. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt. Die 3-te Eigenschaft wird nicht verwendet.', 0, 1, 'Up/Down 2 Button', '{"Label": ""}'), (59, 'Weiterleitung â€žkleinerâ€œ (2 EingÃ¤nge) ', 168, 'Der Ausgang dieses Objektes nimmt den kleinsten Wert vom 1-ten Eingang, dem 2-ten Eingang und der 3-ten Eigenschaft an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Forward <', '{"Value": 0 , "Label": ""}'), (60, 'Weiterleitung â€žmittlerenâ€œ (2 EingÃ¤nge) ', 169, 'Der Ausgang dieses Objektes nimmt den mittleren Wert vom 1-ten Eingang, dem 2-ten Eingang und der 3-ten Eigenschaft an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Forward middle', '{"Value": 0 , "Label": ""}'), (61, 'Weiterleitung â€žgrÃ¶ÃŸerâ€œ (2 EingÃ¤nge) ', 170, 'Der Ausgang dieses Objektes nimmt den grÃ¶ÃŸten Wert vom 1-ten Eingang, dem 2-ten Eingang und der 3-ten Eigenschaft an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Forward >', '{"Value": 0 , "Label": ""}'), (62, 'Weiterleitung â€žgesteuertâ€œ (2 EingÃ¤nge) ', 171, 'Der Ausgang dieses Objektes nimmt den Wert des 2-ten Eingangs an, wenn der 1-te Eingang 0 ist. Andernfalls wird der Wert der 3-ten Eigenschaft angenommen. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt.', 2, 1, 'Forward controlled', '{"Value": 0 , "Label": ""}'), (63, 'Weiterleitung â€žkleinerâ€œ (3 EingÃ¤nge) ', 232, 'Der Ausgang dieses Objektes nimmt den kleinsten Wert der EingÃ¤nge an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Forward <', '{"Label": ""}'), (64, 'Weiterleitung â€žmittlerenâ€œ (3 EingÃ¤nge) ', 233, 'Der Ausgang dieses Objektes nimmt den mittleren Wert der EingÃ¤nge an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Forward middle', '{"Label": ""}'), (65, 'Weiterleitung â€žgrÃ¶ÃŸerâ€œ (3 EingÃ¤nge) ', 234, 'Der Ausgang dieses Objektes nimmt den grÃ¶ÃŸten Wert der EingÃ¤nge an. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Forward >', '{"Label": ""}'), (66, 'Weiterleitung â€žgesteuertâ€œ (3 EingÃ¤nge) ', 235, 'Der Ausgang dieses Objektes nimmt den Wert des 2-ten Eingangs an, wenn der 1-te Eingang 0 ist. Andernfalls wird der Wert des 3-ten Eingangs angenommen. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten, 2-ten und 3-ten Eigenschaft hinterlegt.', 3, 1, 'Forward controlled', '{"Label": ""}'), (67, 'Ausgangsmodifizierer (kein Eingang) ', 63, 'Der Ausgangswert dieses Objekts ergibt sich als der Wert der 1-ten Eigenschaft. Ist dieses Objekt einem Ausgang vorgeschaltet, so bestimmt die 2-te Eigenschaft (Low-Byte) und die 3-te Eigenschaft (High-Byte) die VerzÃ¶gerung in 1/10 Sekunden, mit der eine am Ausgang ange-schlossene Dimmerstufe den durch den Ausgang reprÃ¤sentierten Wert annimmt.', 0, 1, 'Output modifier', '{"Output-Value": 0, "Delay (1/10s)": 0 , "Edge Rising":0, "Edge Falling":0, "Label": ""}'), (68, 'Ausgangsmodifizierer (1 Eingang)', 127, 'Der Ausgangswert dieses Objekts ergibt sich als dessen Eingangswert. Die Nummer des Objekts, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Ist dieses Objekt einem Ausgang vorgeschaltet, so bestimmt die 2-te Eigenschaft (Low-Byte) und die 3-te Eigenschaft (High-Byte) die VerzÃ¶gerung in 1/10 Sekunden, mit der eine am Ausgang angeschlossene Dimmerstufe den durch den Ausgang reprÃ¤sentierten Wert annimmt.', 1, 1, 'Output modifier', '{"Delay (1/10s)": 0, "Edge Rising":0, "Edge Falling":0 , "Label": ""}'), (69, 'Eingang (passiv, flÃ¼chtig)', 61, 'Der Ausgang dieses Objekts wird durch Empfangen einer Statusmeldung verÃ¤ndert. Die Modul-Adresse der Statusmeldung muÃŸ mit der Modul-Adresse des Moduls, auf dem die zu konfigurierende autonome Steuerung lÃ¤uft, identisch sein oder es muÃŸ sich um einen Broadcast handeln. ZusÃ¤tzlich muÃŸ die Absender-Adresse mit der 1-ten Eigenschaft sowie die GerÃ¤te-Adresse der Statusmeldung mit der 2-ten Eigenschaft Ã¼bereinstimmen. Ein eventuell 10 Bit groÃŸer Statuswert wird durch Nichtbeachtung der 2 niederwertigen Bits auf einen 8 Bit groÃŸen Wert gekÃ¼rzt. Nach der Verarbeitung des Ausgangswerts durch die autonome Steuerung oder nach einem Reset wird der Ausgang wieder auf den Wert der 3-ten Eigenschaft gesetzt.', 0, 1, 'Input passive volatile', '{"HAP-Module": 0, "HAP-Device": 0,  "Init-Value": 0 , "Label": ""}'), (70, 'Einschaltbegrenzung', 114, 'Ist der Eingangswert dieses Objekts grÃ¶ÃŸer 0 und eine konfigurierbare Zeitspanne noch nicht abgelaufen, so wird dieser Wert auf den Ausgang Ã¼bertragen. Die Zeit fÃ¤ngt in dem Moment an abzulaufen, wenn der Eingangswert grÃ¶ÃŸer 0 wird. Ist der Eingangswert 0 bzw. die Zeit abgelaufen, so wird auch der Ausgang 0. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die Zeit, um die der Einschaltvorgang verzÃ¶gert wird, wird in der 3-ten Eigenschaft hinterlegt', 1, 1, 'Switch-on limiter', '{"Time-Base": 0, "Value": 0 , "Label": ""}'), (71, 'FlipFlop0 (2 EingÃ¤nge)', 152, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert grÃ¶ÃŸer 0 ist. Ist der 2-te Eingangswert grÃ¶ÃŸer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Der 2-te Eingang ist gegenÃ¼ber dem 1-ten Eingang priorisiert.', 2, 1, 'FlipFlop 0', '{"Value": 0 , "Label": ""}'), (72, 'FlipFlop0 (3 EingÃ¤nge)', 216, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert grÃ¶ÃŸer 0 ist. Ist der 2-te Eingangswert grÃ¶ÃŸer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Der 2-te Eingang ist gegenÃ¼ber dem 1-ten Eingang priorisiert.', 3, 1, 'FlipFlop', '{"Label": ""}'), (73, 'Multiplikation mit einer rationalen Zahl ', 86, 'Der Wert des Ausgangs dieses Objekts ergibt sich durch Division des Eingangswerts mit der 2-ten Eigenschaft und anschlieÃŸender Multiplikation mit der 3-ten Eigenschaft. Die Rundung auf einen ganzzahligen Wert wird am Ende vorgenommen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt.', 1, 1, 'Multipl. with. rat. Number', '{"Divisor": 0, "Multiplicator": 0 , "Label": ""}'), (74, 'Zeitgesteuerte Weiterleitung', 115, 'Der Eingangswert dieses Objektes wird in einem zu konfigurierendem Intervall auf den Ausgang Ã¼bertragen. Somit wird nicht jede Ã„nderung des Eingangs vom Ausgang Ã¼bernommen, sondern nur jene, die mit dem Ablauf dieses Intervalls zusammenfallen. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die LÃ¤nge des Zeitintervalls wird in der 3-ten Eigenschaft hinterlegt,', 1, 1, 'Timed Forward', '{"Time-Base": 0, "Value": 0 , "Label": ""}'), (75, 'Statusmeldungsausgang', 122, 'Ã„ndert sich der Eingangswert dieses Objekts, so wird eben dieser Wert in Form einer Statusmeldung als Broadcast verschickt. Die Nummer des Objektes, das als Eingang fungiert, wird in der 1-ten Eigenschaft hinterlegt. Die 3-te Eigenschaft speichert die GerÃ¤te-Adresse, die in der Statusmeldung hinterlegt wird. Es handelt sich somit um die GerÃ¤te-Adresse des Statusmeldungsausgangs.', 1, 0, 'Status signal output', '{"HAP-Module": 0, "HAP-Device": 0 , "Label": ""}'), (76, 'Auf-/Ab-Steuerung 2-Taster-LÃ¶sung (Rollladensteuerung) ', 165, 'Dieses Objekt setzt die Eingangswerte, wie sie von entsprechend konfigurierten logischen Ein-gÃ¤ngen geliefert werden, in entsprechende Steuercodes um, wie sie zur Ansteuerung eines Rollladens verwendet werden kÃ¶nnen. Die Nummern der Objekte, die als Eingang fungieren, werden in der 1-ten und 2-ten Eigenschaft hinterlegt', 2, 1, 'Up/Down 2 Btn. Shutter', '{"Label": ""}'), (80, 'Annotation', 256, NULL, 0, 0, 'Comment', '{"Label": ""}'), (81, 'FlipFlop1 (2 EingÃ¤nge)', 153, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert größer 0 ist. Ist der 2-te Eingangswert größer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Der 1-te Eingang ist gegenüber dem 2-ten Eingang priorisiert.', 2, 1, 'FlipFlop 1', '{"Value": 0 , "Label": ""}'), (82, 'FlipFlop2 (2 EingÃ¤nge)', 154, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert größer 0 ist. Ist der 2-te Eingangswert größer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Ist der 1-te Eingangswert und der 2-te Eingangswert größer 0, so wird der Ausgang invertiert, das heißt, ist er gleich 0, so nimmt er den Wert der 3-ten Eigenschaft an, sonst wird er 0.', 2, 1, 'FlipFlop 2', '{"Value": 0 , "Label": ""}'), (83, 'FlipFlop3 (2 EingÃ¤nge)', 155, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Der 2-te Eingang ist gegenüber dem 1-ten Eingang priorisiert.', 2, 1, 'FlipFlop 3', '{"Value": 0 , "Label": ""}'), (84, 'FlipFlop4 (2 EingÃ¤nge)', 156, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Der 1-te Eingang ist gegenüber dem 2-ten Eingang priorisiert.', 2, 1, 'FlipFlop 4', '{"Value": 0 , "Label": ""}'), (85, 'FlipFlop5 (2 EingÃ¤nge)', 157, 'Der Ausgang dieses Objekts nimmt den Wert der 3-ten Eigenschaft an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Ist der 1-te Eingangswert und der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang invertiert, das heißt, ist er gleich 0, so nimmt er den Wert der 3-ten Eigenschaft an, sonst wird er 0.', 2, 1, 'FlipFlop 5', '{"Value": 0 , "Label": ""}'), (86, 'FlipFlop1 (3 EingÃ¤nge)', 217, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert größer 0 ist. Ist der 2-te Eingangswert größer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Der 1-te Eingang ist gegenüber dem 2-ten Eingang priorisiert.', 3, 1, 'FlipFlop 1', '{"Label": ""}'), (87, 'FlipFlop2 (3 EingÃ¤nge)', 218, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert größer 0 ist. Ist der 2-te Eingangswert größer 0, so wird der Ausgang des Objekts auf 0 gesetzt. Ist der 1-te Eingangswert und der 2-te Eingangswert größer 0, so wird der Ausgang invertiert, das heißt, ist er gleich 0, so nimmt er den Wert des 3-ten Eingangs an, sonst wird er 0.', 3, 1, 'FlipFlop 2', '{"Label": ""}'), (88, 'FlipFlop3 (3 EingÃ¤nge)', 219, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Der 2-te Eingang ist gegenüber dem 1-ten Eingang priorisiert.', 3, 1, 'FlipFlop 3', '{"Label": ""}'), (89, 'FlipFlop4 (3 EingÃ¤nge)', 220, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Der 1-te Eingang ist gegenüber dem 2-ten Eingang priorisiert.', 3, 1, 'FlipFlop 4', '{"Label": ""}'), (90, 'FlipFlop5 (3 EingÃ¤nge)', 221, 'Der Ausgang dieses Objekts nimmt den Wert des 3-ten Eingangs an, wenn der 1-te Eingangswert gerade größer 0 geworden ist (steigende Flanke). Ist der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang des Objekts auf 0 gesetzt. Ist der 1-te Eingangswert und der 2-te Eingangswert gerade größer 0 geworden (steigende Flanke), so wird der Ausgang invertiert, das heißt, ist er gleich 0, so nimmt er den Wert des 3-ten Eingangs an, sonst wird er 0.', 3, 1, 'FlipFlop 5', '{"Label": ""}'), (91, 'Makros', 123, 'Ã„ndert sich der Eingangswert dieses Objekts, so wird bei einem Wert > 0 das "AN"  Makro aufgerufen. Bei einem Wert von 0 wird das "AUS" Makro aufgerufen.', 1, 0, 'Makro', '{"ON-Makro": 0, "OFF-Makro": 0, "Label": ""}');
REPLACE INTO `gui_types` VALUES (1,'Switch','HAP.Switch','On/Off-Switch','{}'),(3,'Slider','HAP.Slider','Used for setting values between 0 and 100','{}'),(4,'Value Layer','HAP.ValueLayer','Display Data-Values','{}'),(2,'Image Layer','HAP.ImageLayer','Configurable Image-Layer used for Standard-Images and Linked-Images','{}'),(5,'Chart','HAP.Chart','Draw nice charts','{}'),(6,'Chart5','HAP.Chart5','Draw nice HTML5 charts','{}'),(7,'Macro','HAP.Macro','Execute Macros','{}'),(8,'Trigger','HAP.Trigger','Modify triggers','{}'),(9,'Container','HAP.Container','DIV-Container','{}');
REPLACE INTO `lcd_types` VALUES (1,'Menu',1,'A menu contains menu entries',2,0,'Menu','{\"Label\": \"\", \"Is Root\": false, \"Is Default\": false}'),(2,'Menu Entry',0,'A menu entry always has a Menu-Parent',0,1,'Menu entry','{\"Label (14 max.)\": \"\"}'),(3,'Device',16,'Device',1,0,'Device','{\"Label (16 max.)\": \"\", \"HAP-Module\": 0, \"HAP-Device\": 0, \"Is Root\": false, \"Is Default\": false}'),(4,'Thermostat',32,'Thermostat',1,0,'Thermost.','{\"Label (16 max.)\": \"\", \"HAP-Module\": 0, \"HAP-Device\": 0, \"Is Root\": false, \"Is Default\": false, \"Refresh (s)\":30}');
REPLACE INTO `static_address` VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,11),(12,12),(13,13),(14,14),(15,15),(16,16),(17,17),(18,18),(19,19),(20,20),(21,21),(22,22),(23,23),(24,24),(25,25),(26,26),(27,27),(28,28),(29,29),(30,30),(31,31),(32,32),(33,33),(34,34),(35,35),(36,36),(37,37),(38,38),(39,39),(40,40),(41,41),(42,42),(43,43),(44,44),(45,45),(46,46),(47,47),(48,48),(49,49),(50,50),(51,51),(52,52),(53,53),(54,54),(55,55),(56,56),(57,57),(58,58),(59,59),(60,60),(61,61),(62,62),(63,63),(64,64),(65,65),(66,66),(67,67),(68,68),(69,69),(70,70),(71,71),(72,72),(73,73),(74,74),(75,75),(76,76),(77,77),(78,78),(79,79),(80,80),(81,81),(82,82),(83,83),(84,84),(85,85),(86,86),(87,87),(88,88),(89,89),(90,90),(91,91),(92,92),(93,93),(94,94),(95,95),(96,96),(97,97),(98,98),(99,99),(100,100),(101,101),(102,102),(103,103),(104,104),(105,105),(106,106),(107,107),(108,108),(109,109),(110,110),(111,111),(112,112),(113,113),(114,114),(115,115),(116,116),(117,117),(118,118),(119,119),(120,120),(121,121),(122,122),(123,123),(124,124),(125,125),(126,126),(127,127),(128,128),(129,129),(130,130),(131,131),(132,132),(133,133),(134,134),(135,135),(136,136),(137,137),(138,138),(139,139),(140,140),(141,141),(142,142),(143,143),(144,144),(145,145),(146,146),(147,147),(148,148),(149,149),(150,150),(151,151),(152,152),(153,153),(154,154),(155,155),(156,156),(157,157),(158,158),(159,159),(160,160),(161,161),(162,162),(163,163),(164,164),(165,165),(166,166),(167,167),(168,168),(169,169),(170,170),(171,171),(172,172),(173,173),(174,174),(175,175),(176,176),(177,177),(178,178),(179,179),(180,180),(181,181),(182,182),(183,183),(184,184),(185,185),(186,186),(187,187),(188,188),(189,189),(190,190),(191,191),(192,192),(193,193),(194,194),(195,195),(196,196),(197,197),(198,198),(199,199),(200,200),(201,201),(202,202),(203,203),(204,204),(205,205),(206,206),(207,207),(208,208),(209,209),(210,210),(211,211),(212,212),(213,213),(214,214),(215,215),(216,216),(217,217),(218,218),(219,219),(220,220),(221,221),(222,222),(223,223),(224,224),(225,225),(226,226),(227,227),(228,228),(229,229),(230,230),(231,231),(232,232),(233,233),(234,234),(235,235),(236,236),(237,237),(238,238),(239,239),(240,240),(241,241),(242,242),(243,243),(244,244),(245,245),(246,246),(247,247),(248,248),(249,249),(250,250),(251,251),(252,252),(253,253),(254,254),(255,255),(256,0);
REPLACE INTO `static_devicetypes` VALUES (1,'Buzzer',2,'buzzer','1-0'),(2,'IR-Receiver',3,'ir-receiver','3-4'),(4,'Switch',16,'switch',NULL),(5,'LCD-Data0',48,'lcd display-data 0',NULL),(6,'LCD-Data1',49,'lcd display-data 1',NULL),(7,'LCD-Data2',50,'lcd display-data 2',NULL),(8,'LCD-Data3',51,'lcd display-data 3',NULL),(9,'LCD-RW',56,'lcd read-write',NULL),(10,'LCD-RS',57,'lcd register-select',NULL),(11,'LCD-E',58,'lcd enable',NULL),(12,'Dimmer',64,'dimmer',NULL),(13,'Dimmer Softstart',65,'dimmer soft-delay',NULL),(14,'Dimmer Long Ignition',66,'dimmer long-ignition',NULL),(15,'Dimmer Long Ignition, Softstart',67,'dimmer long-ignition soft-delay',NULL),(16,'Dimmer Cut Off',72,'dimmer trailing-edge-princ ',NULL),(17,'Dimmer Cut Off, Softstart',73,'dimmer trailing-edge-princ soft-delay',NULL),(18,'LCD-Data4',52,'lcd display-data 4',NULL),(19,'LCD-Data5',53,'lcd display-data 5',NULL),(20,'LCD-Data6',54,'lcd display-data 6',NULL),(21,'LCD-Data7',55,'lcd display-data 7',NULL),(23,'Serial-Interface Receiver',4,'serial-interface receiver','3-0'),(24,'Serial-Interface Transmitter',5,'serial-interface transmitter','3-1'),(25,'SPI Slave Select',8,'spi-ss','1-4'),(26,'SPI Master out - Slave in',9,'spi-mosi','1-5'),(27,'SPI Master in - Slave out',10,'spi-miso','1-6'),(28,'SPI System Clock',11,'spi-sc','1-7'),(29,'TWI System Clock',12,'twi-sc','2-0'),(30,'TWI System Data',13,'twi-sd','2-1'),(31,'LCD-Backlight',59,'59',NULL),(32,'Dimmer, Switch-Restriction',68,'dimmer switch-restriction',NULL),(33,'Dimmer, Switch-Restriction, Long Ignition',70,'dimmer switch-restriction soft-delay',NULL),(34,'Dimmer, Switch-Restriction, Cut Off',76,'dimmer switch-restriction trailing-edge-princ',NULL);
REPLACE INTO `static_digitalinputtypes` VALUES (1,'Dallas DS18B20',1,'ds18b20'),(2,'Dallas DS18S20',2,'ds18s20');
REPLACE INTO `static_encryptionmodes` VALUES (1,'Full',3,'full'),(2,'Half',1,'half'),(3,'Off',0,'off');
REPLACE INTO `static_inputvaluetemplates` VALUES (1,'Push button released',8),(2,'Push button pushed',128),(3,'Push button short push',132),(4,'Push button medium long push',136),(5,'Push button long push',140);
REPLACE INTO `static_interfaces` VALUES (1,'Serial',4),(2,'CAN',8),(3,'Loopback',0);
REPLACE INTO `static_ircodes` VALUES (1,'Button 0',0,'button-0'),(2,'Button 1',1,'button-1'),(3,'Button 2',2,'button-2'),(4,'Button 3',3,'button-3'),(5,'Button 4',4,'button-4'),(6,'Button 5',5,'button-5'),(7,'Button 6',6,'button-6'),(8,'Button 7',7,'button-7'),(9,'Button 8',8,'button-8'),(10,'Button 9',9,'button-9'),(11,'All On',12,'all-on'),(12,'All Off',15,'all-off'),(13,'Macro',30,'makro'),(14,'Plus',32,'plus'),(15,'Minus',33,'minus'),(16,'Enter',38,'enter'),(17,'Ignore',62,'ignore');
REPLACE INTO `static_logicalinputtemplates` VALUES (1,'Rotary Encoder Push Button',158),(2,'Rotary Encoder A/B',151),(3,'Reed Contact',183),(4,'Push-Button',186);
REPLACE INTO `static_outputvaluetemplates` VALUES (1,'Invert',128),(2,'Plus',129),(3,'Minus',130),(4,'All on',131),(5,'All off',132),(6,'Dim up',133),(7,'Dim down',134),(8,'Dim stop',135),(9,'Dim start',136),(10,'Rotary Encoder left',137),(11,'Rotary Encoder right',138),(12,'Rotary Encoder short push',139),(13,'Rotary Encoder medium long push',140),(14,'Rotary Encoder long push',141),(15,'GUI Refresh',142),(16,'No Operation',255);
REPLACE INTO `static_portpin` VALUES (1,0,5),(2,0,1),(3,0,2),(4,0,3),(5,0,4),(6,0,0),(7,0,7),(8,0,6),(9,1,0),(10,1,1),(11,1,2),(12,1,3),(13,2,2),(14,2,3),(15,2,4),(16,2,5),(17,2,6),(18,2,7),(19,3,4),(20,3,5),(21,3,6),(22,3,7),(23,3,3),(24,3,0),(25,3,1),(29,1,4),(30,1,5),(31,1,6),(32,1,7);
REPLACE INTO `static_schedulercommands` VALUES (2,'hap-sendcmd.pl'),(3,'hap-configbuilder.pl'),(4,'hap-firmwarebuilder.pl'),(5,'hap-lcdguibuilder.pl'),(6,'hap-dbcleanup.pl');
REPLACE INTO `static_startmodes` VALUES (1,'Standard',217,'normal'),(2,'Default-Config',179,'default-config'),(3,'Full-Default-Config',0,'full-default-config');
REPLACE INTO `static_timebase` VALUES (1,'1/10s',0),(2,'Seconds',1),(3,'Minutes',2),(4,'Hours',3),(5,'Days',4),(6,'Weeks',5);
REPLACE INTO `static_weekdays` VALUES (1,'Monday',0),(2,'Tuesday',1),(3,'Wednesday',2),(4,'Thursday',3),(5,'Friday',4),(6,'Saturday',5),(7,'Sunday',6);
REPLACE INTO `static_homematicdevicetypes` VALUES(1,'HM-LC-Sw1-Pl-2','Wall Mount Switch'),(2,'HM-Sec-SC','Reed-Contact'), (3,'HM-Sec-RHS','Window rotary handle sensor'),(4,'HM-Sec-MDIR','Indoor motion indicator'),(5,'HM-PB-2-WM55','Push button 2-channel surface mount'),(6,'HM-LC-Sw1-FM','Switch actuator 1-channel flush-mount'),(7,'HM-Sen-MDIR-O','Outdoor motion detector');
REPLACE INTO `static_messagetypes` VALUES(1,'set',0),(2,'query',8), (3,'notify',16);
REPLACE INTO `roles` VALUES (1,'Read'),(2,'Write'),(3,'Delete'),(33,'GUI_Set'),(32,'GUI_Read'),(31,'Delete_Users'),(30,'Manage_Users'),(29,'Learn_IR'),(28,'Delete_Schedules'),(27,'Add_Schedules'),(26,'Reset_Module'),(25,'Push_Config'),(24,'Flash_Firmware');

REPLACE INTO users VALUES (5,"hap","5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8","","","");                                                                                                                   
REPLACE INTO users_roles VALUES (5,1),(5,2),(5,3),(5,24),(5,25),(5,26),(5,27),(5,28),(5,29),(5,30),(5,31),(5,32),(5,33);  


USE `mysql`;
REPLACE INTO user (Host,User,Password) VALUES("localhost","hap",PASSWORD("password"));
REPLACE INTO db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Alter_priv) VALUES("localhost","hap","hap","Y","Y","Y","Y","Y","Y","Y");
FLUSH PRIVILEGES;

