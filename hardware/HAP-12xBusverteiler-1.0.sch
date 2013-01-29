<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE eagle SYSTEM "eagle.dtd">
<eagle version="6.4">
<drawing>
<settings>
<setting alwaysvectorfont="no"/>
<setting verticaltext="up"/>
</settings>
<grid distance="0.1" unitdist="inch" unit="inch" style="lines" multiple="1" display="no" altdistance="0.01" altunitdist="inch" altunit="inch"/>
<layers>
<layer number="1" name="Top" color="4" fill="1" visible="no" active="no"/>
<layer number="16" name="Bottom" color="1" fill="1" visible="no" active="no"/>
<layer number="17" name="Pads" color="2" fill="1" visible="no" active="no"/>
<layer number="18" name="Vias" color="2" fill="1" visible="no" active="no"/>
<layer number="19" name="Unrouted" color="6" fill="1" visible="no" active="no"/>
<layer number="20" name="Dimension" color="15" fill="1" visible="no" active="no"/>
<layer number="21" name="tPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="22" name="bPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="23" name="tOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="24" name="bOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="25" name="tNames" color="7" fill="1" visible="no" active="no"/>
<layer number="26" name="bNames" color="7" fill="1" visible="no" active="no"/>
<layer number="27" name="tValues" color="7" fill="1" visible="no" active="no"/>
<layer number="28" name="bValues" color="7" fill="1" visible="no" active="no"/>
<layer number="29" name="tStop" color="7" fill="3" visible="no" active="no"/>
<layer number="30" name="bStop" color="7" fill="6" visible="no" active="no"/>
<layer number="31" name="tCream" color="7" fill="4" visible="no" active="no"/>
<layer number="32" name="bCream" color="7" fill="5" visible="no" active="no"/>
<layer number="33" name="tFinish" color="6" fill="3" visible="no" active="no"/>
<layer number="34" name="bFinish" color="6" fill="6" visible="no" active="no"/>
<layer number="35" name="tGlue" color="7" fill="4" visible="no" active="no"/>
<layer number="36" name="bGlue" color="7" fill="5" visible="no" active="no"/>
<layer number="37" name="tTest" color="7" fill="1" visible="no" active="no"/>
<layer number="38" name="bTest" color="7" fill="1" visible="no" active="no"/>
<layer number="39" name="tKeepout" color="4" fill="11" visible="no" active="no"/>
<layer number="40" name="bKeepout" color="1" fill="11" visible="no" active="no"/>
<layer number="41" name="tRestrict" color="4" fill="10" visible="no" active="no"/>
<layer number="42" name="bRestrict" color="1" fill="10" visible="no" active="no"/>
<layer number="43" name="vRestrict" color="2" fill="10" visible="no" active="no"/>
<layer number="44" name="Drills" color="7" fill="1" visible="no" active="no"/>
<layer number="45" name="Holes" color="7" fill="1" visible="no" active="no"/>
<layer number="46" name="Milling" color="3" fill="1" visible="no" active="no"/>
<layer number="47" name="Measures" color="7" fill="1" visible="no" active="no"/>
<layer number="48" name="Document" color="7" fill="1" visible="no" active="no"/>
<layer number="49" name="Reference" color="7" fill="1" visible="no" active="no"/>
<layer number="50" name="dxf" color="7" fill="1" visible="no" active="no"/>
<layer number="51" name="tDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="52" name="bDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="91" name="Nets" color="2" fill="1" visible="yes" active="yes"/>
<layer number="92" name="Busses" color="1" fill="1" visible="yes" active="yes"/>
<layer number="93" name="Pins" color="2" fill="1" visible="no" active="yes"/>
<layer number="94" name="Symbols" color="4" fill="1" visible="yes" active="yes"/>
<layer number="95" name="Names" color="7" fill="1" visible="yes" active="yes"/>
<layer number="96" name="Values" color="7" fill="1" visible="yes" active="yes"/>
<layer number="97" name="Info" color="7" fill="1" visible="yes" active="yes"/>
<layer number="98" name="Guide" color="6" fill="1" visible="yes" active="yes"/>
</layers>
<schematic xreflabel="%F%N/%S.%C%R" xrefpart="/%S.%C%R">
<libraries>
<library name="frames">
<packages>
</packages>
<symbols>
<symbol name="DINA4_L">
<wire x1="264.16" y1="0" x2="264.16" y2="180.34" width="0.4064" layer="94"/>
<wire x1="264.16" y1="180.34" x2="0" y2="180.34" width="0.4064" layer="94"/>
<wire x1="0" y1="180.34" x2="0" y2="0" width="0.4064" layer="94"/>
<wire x1="0" y1="0" x2="264.16" y2="0" width="0.4064" layer="94"/>
</symbol>
<symbol name="DOCFIELD">
<wire x1="0" y1="0" x2="71.12" y2="0" width="0.254" layer="94"/>
<wire x1="101.6" y1="15.24" x2="87.63" y2="15.24" width="0.254" layer="94"/>
<wire x1="0" y1="0" x2="0" y2="5.08" width="0.254" layer="94"/>
<wire x1="0" y1="5.08" x2="71.12" y2="5.08" width="0.254" layer="94"/>
<wire x1="0" y1="5.08" x2="0" y2="15.24" width="0.254" layer="94"/>
<wire x1="101.6" y1="15.24" x2="101.6" y2="5.08" width="0.254" layer="94"/>
<wire x1="71.12" y1="5.08" x2="71.12" y2="0" width="0.254" layer="94"/>
<wire x1="71.12" y1="5.08" x2="87.63" y2="5.08" width="0.254" layer="94"/>
<wire x1="71.12" y1="0" x2="101.6" y2="0" width="0.254" layer="94"/>
<wire x1="87.63" y1="15.24" x2="87.63" y2="5.08" width="0.254" layer="94"/>
<wire x1="87.63" y1="15.24" x2="0" y2="15.24" width="0.254" layer="94"/>
<wire x1="87.63" y1="5.08" x2="101.6" y2="5.08" width="0.254" layer="94"/>
<wire x1="101.6" y1="5.08" x2="101.6" y2="0" width="0.254" layer="94"/>
<wire x1="0" y1="15.24" x2="0" y2="22.86" width="0.254" layer="94"/>
<wire x1="101.6" y1="35.56" x2="0" y2="35.56" width="0.254" layer="94"/>
<wire x1="101.6" y1="35.56" x2="101.6" y2="22.86" width="0.254" layer="94"/>
<wire x1="0" y1="22.86" x2="101.6" y2="22.86" width="0.254" layer="94"/>
<wire x1="0" y1="22.86" x2="0" y2="35.56" width="0.254" layer="94"/>
<wire x1="101.6" y1="22.86" x2="101.6" y2="15.24" width="0.254" layer="94"/>
<text x="1.27" y="1.27" size="2.54" layer="94" font="vector">Date:</text>
<text x="12.7" y="1.27" size="2.54" layer="94" font="vector">&gt;LAST_DATE_TIME</text>
<text x="72.39" y="1.27" size="2.54" layer="94" font="vector">Sheet:</text>
<text x="86.36" y="1.27" size="2.54" layer="94" font="vector">&gt;SHEET</text>
<text x="88.9" y="11.43" size="2.54" layer="94" font="vector">REV:</text>
<text x="1.27" y="19.05" size="2.54" layer="94" font="vector">TITLE:</text>
<text x="1.27" y="11.43" size="2.54" layer="94" font="vector">Document Number:</text>
<text x="17.78" y="19.05" size="2.54" layer="94" font="vector">&gt;DRAWING_NAME</text>
</symbol>
</symbols>
<devicesets>
<deviceset name="DINA4_L" prefix="FRAME">
<description>&lt;b&gt;FRAME&lt;/b&gt;&lt;p&gt;
DIN A4, landscape with extra doc field</description>
<gates>
<gate name="G$1" symbol="DINA4_L" x="0" y="0"/>
<gate name="G$2" symbol="DOCFIELD" x="162.56" y="0" addlevel="must"/>
</gates>
<devices>
<device name="">
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
<library name="con-wago">
<description>&lt;b&gt;Wago Connectors&lt;/b&gt;&lt;p&gt;
Types:&lt;p&gt;
 233&lt;p&gt;
 234&lt;p&gt;
 255 - 5.0; 5.08; 7.5; 7.62, 10.0; 10.16 mm&lt;p&gt;
 254&lt;p&gt;
&lt;author&gt;Created by librarian@cadsoft.de&lt;/author&gt;</description>
<packages>
<package name="233-512">
<description>&lt;b&gt;WAGO Cage Clamp&lt;/b&gt;</description>
<wire x1="-16.22" y1="4.8" x2="-16.22" y2="4.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="4.25" x2="-16.57" y2="4.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="4.25" x2="-16.57" y2="3.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="3.25" x2="-16.22" y2="3.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="3.25" x2="-16.22" y2="-1.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="-1.25" x2="-16.57" y2="-1.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="-1.25" x2="-16.57" y2="-3.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="-3.25" x2="-16.22" y2="-3.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="-3.25" x2="-16.22" y2="-5.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="-5.25" x2="-16.57" y2="-5.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="-5.25" x2="-16.57" y2="-6.25" width="0.2032" layer="21"/>
<wire x1="-16.57" y1="-6.25" x2="-16.22" y2="-6.25" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="-6.25" x2="-16.22" y2="-7.1" width="0.2032" layer="21"/>
<wire x1="-16.22" y1="-7.1" x2="15.995" y2="-7.1" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-7.1" x2="15.995" y2="-6.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-5.25" x2="15.995" y2="-3.75" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-3.75" x2="15.995" y2="-3.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-1.25" x2="15.995" y2="3.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="4.25" x2="15.995" y2="4.8" width="0.2032" layer="21"/>
<wire x1="15.995" y1="4.8" x2="-16.22" y2="4.8" width="0.2032" layer="21"/>
<wire x1="-14.72" y1="3.75" x2="-14.72" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-14.72" y1="1.25" x2="-14.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-14.47" y1="1.25" x2="-13.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-13.47" y1="1.25" x2="-13.22" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-13.22" y1="1.25" x2="-13.22" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-13.22" y1="3.75" x2="-14.72" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-16.22" y1="-3.75" x2="15.995" y2="-3.75" width="0.2032" layer="21"/>
<wire x1="-14.47" y1="-4.25" x2="-14.47" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-14.47" y1="-5.75" x2="-13.47" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-13.47" y1="-5.75" x2="-13.47" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-13.47" y1="-4.25" x2="-14.47" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="4.25" x2="15.645" y2="4.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="4.25" x2="15.645" y2="3.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="3.25" x2="15.995" y2="3.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-1.25" x2="15.645" y2="-1.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="-1.25" x2="15.645" y2="-3.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="-3.25" x2="15.995" y2="-3.25" width="0.2032" layer="21"/>
<wire x1="15.995" y1="-5.25" x2="15.645" y2="-5.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="-5.25" x2="15.645" y2="-6.25" width="0.2032" layer="21"/>
<wire x1="15.645" y1="-6.25" x2="15.995" y2="-6.25" width="0.2032" layer="21"/>
<wire x1="-14.47" y1="3.25" x2="-14.47" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-14.47" y1="1.75" x2="-13.47" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-13.47" y1="1.75" x2="-13.47" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-13.47" y1="3.25" x2="-14.47" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-14.47" y1="1.25" x2="-14.47" y2="-1" width="0.2032" layer="51"/>
<wire x1="-14.47" y1="-1" x2="-13.47" y2="-1" width="0.2032" layer="51"/>
<wire x1="-13.47" y1="-1" x2="-13.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-15.24" y1="-6.985" x2="-15.24" y2="4.699" width="0.2032" layer="21"/>
<wire x1="-12.18" y1="3.75" x2="-12.18" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-12.18" y1="1.25" x2="-11.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-11.93" y1="1.25" x2="-10.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-10.93" y1="1.25" x2="-10.68" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-10.68" y1="1.25" x2="-10.68" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-10.68" y1="3.75" x2="-12.18" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-11.93" y1="-4.25" x2="-11.93" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-11.93" y1="-5.75" x2="-10.93" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-10.93" y1="-5.75" x2="-10.93" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-10.93" y1="-4.25" x2="-11.93" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-11.93" y1="3.25" x2="-11.93" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-11.93" y1="1.75" x2="-10.93" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-10.93" y1="1.75" x2="-10.93" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-10.93" y1="3.25" x2="-11.93" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-11.93" y1="1.25" x2="-11.93" y2="-1" width="0.2032" layer="51"/>
<wire x1="-11.93" y1="-1" x2="-10.93" y2="-1" width="0.2032" layer="51"/>
<wire x1="-10.93" y1="-1" x2="-10.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-12.7" y1="-6.985" x2="-12.7" y2="4.699" width="0.2032" layer="21"/>
<wire x1="-9.64" y1="3.75" x2="-9.64" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-9.64" y1="1.25" x2="-9.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-9.39" y1="1.25" x2="-8.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-8.39" y1="1.25" x2="-8.14" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-8.14" y1="1.25" x2="-8.14" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-8.14" y1="3.75" x2="-9.64" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-9.39" y1="-4.25" x2="-9.39" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-9.39" y1="-5.75" x2="-8.39" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-8.39" y1="-5.75" x2="-8.39" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-8.39" y1="-4.25" x2="-9.39" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-9.39" y1="3.25" x2="-9.39" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-9.39" y1="1.75" x2="-8.39" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-8.39" y1="1.75" x2="-8.39" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-8.39" y1="3.25" x2="-9.39" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-9.39" y1="1.25" x2="-9.39" y2="-1" width="0.2032" layer="51"/>
<wire x1="-9.39" y1="-1" x2="-8.39" y2="-1" width="0.2032" layer="51"/>
<wire x1="-8.39" y1="-1" x2="-8.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-10.16" y1="-6.985" x2="-10.16" y2="4.699" width="0.2032" layer="21"/>
<wire x1="-7.1" y1="3.75" x2="-7.1" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-7.1" y1="1.25" x2="-6.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-6.85" y1="1.25" x2="-5.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-5.85" y1="1.25" x2="-5.6" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-5.6" y1="1.25" x2="-5.6" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-5.6" y1="3.75" x2="-7.1" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-6.85" y1="-4.25" x2="-6.85" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-6.85" y1="-5.75" x2="-5.85" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-5.85" y1="-5.75" x2="-5.85" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-5.85" y1="-4.25" x2="-6.85" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-6.85" y1="3.25" x2="-6.85" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-6.85" y1="1.75" x2="-5.85" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-5.85" y1="1.75" x2="-5.85" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-5.85" y1="3.25" x2="-6.85" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-6.85" y1="1.25" x2="-6.85" y2="-1" width="0.2032" layer="51"/>
<wire x1="-6.85" y1="-1" x2="-5.85" y2="-1" width="0.2032" layer="51"/>
<wire x1="-5.85" y1="-1" x2="-5.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-7.62" y1="-6.985" x2="-7.62" y2="4.699" width="0.2032" layer="21"/>
<wire x1="-4.56" y1="3.75" x2="-4.56" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-4.56" y1="1.25" x2="-4.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-4.31" y1="1.25" x2="-3.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-3.31" y1="1.25" x2="-3.06" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-3.06" y1="1.25" x2="-3.06" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-3.06" y1="3.75" x2="-4.56" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-4.31" y1="-4.25" x2="-4.31" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-4.31" y1="-5.75" x2="-3.31" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-3.31" y1="-5.75" x2="-3.31" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-3.31" y1="-4.25" x2="-4.31" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-4.31" y1="3.25" x2="-4.31" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-4.31" y1="1.75" x2="-3.31" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-3.31" y1="1.75" x2="-3.31" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-3.31" y1="3.25" x2="-4.31" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-4.31" y1="1.25" x2="-4.31" y2="-1" width="0.2032" layer="51"/>
<wire x1="-4.31" y1="-1" x2="-3.31" y2="-1" width="0.2032" layer="51"/>
<wire x1="-3.31" y1="-1" x2="-3.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-5.08" y1="-6.985" x2="-5.08" y2="4.699" width="0.2032" layer="21"/>
<wire x1="-2.02" y1="3.75" x2="-2.02" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-2.02" y1="1.25" x2="-1.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-1.77" y1="1.25" x2="-0.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-0.77" y1="1.25" x2="-0.52" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-0.52" y1="1.25" x2="-0.52" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-0.52" y1="3.75" x2="-2.02" y2="3.75" width="0.2032" layer="51"/>
<wire x1="-1.77" y1="-4.25" x2="-1.77" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-1.77" y1="-5.75" x2="-0.77" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="-0.77" y1="-5.75" x2="-0.77" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-0.77" y1="-4.25" x2="-1.77" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="-1.77" y1="3.25" x2="-1.77" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-1.77" y1="1.75" x2="-0.77" y2="1.75" width="0.2032" layer="51"/>
<wire x1="-0.77" y1="1.75" x2="-0.77" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-0.77" y1="3.25" x2="-1.77" y2="3.25" width="0.2032" layer="51"/>
<wire x1="-1.77" y1="1.25" x2="-1.77" y2="-1" width="0.2032" layer="51"/>
<wire x1="-1.77" y1="-1" x2="-0.77" y2="-1" width="0.2032" layer="51"/>
<wire x1="-0.77" y1="-1" x2="-0.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="-2.54" y1="-6.985" x2="-2.54" y2="4.699" width="0.2032" layer="21"/>
<wire x1="0.52" y1="3.75" x2="0.52" y2="1.25" width="0.2032" layer="51"/>
<wire x1="0.52" y1="1.25" x2="0.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="0.77" y1="1.25" x2="1.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="1.77" y1="1.25" x2="2.02" y2="1.25" width="0.2032" layer="51"/>
<wire x1="2.02" y1="1.25" x2="2.02" y2="3.75" width="0.2032" layer="51"/>
<wire x1="2.02" y1="3.75" x2="0.52" y2="3.75" width="0.2032" layer="51"/>
<wire x1="0.77" y1="-4.25" x2="0.77" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="0.77" y1="-5.75" x2="1.77" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="1.77" y1="-5.75" x2="1.77" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="1.77" y1="-4.25" x2="0.77" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="0.77" y1="3.25" x2="0.77" y2="1.75" width="0.2032" layer="51"/>
<wire x1="0.77" y1="1.75" x2="1.77" y2="1.75" width="0.2032" layer="51"/>
<wire x1="1.77" y1="1.75" x2="1.77" y2="3.25" width="0.2032" layer="51"/>
<wire x1="1.77" y1="3.25" x2="0.77" y2="3.25" width="0.2032" layer="51"/>
<wire x1="0.77" y1="1.25" x2="0.77" y2="-1" width="0.2032" layer="51"/>
<wire x1="0.77" y1="-1" x2="1.77" y2="-1" width="0.2032" layer="51"/>
<wire x1="1.77" y1="-1" x2="1.77" y2="1.25" width="0.2032" layer="51"/>
<wire x1="0" y1="-6.985" x2="0" y2="4.699" width="0.2032" layer="21"/>
<wire x1="3.06" y1="3.75" x2="3.06" y2="1.25" width="0.2032" layer="51"/>
<wire x1="3.06" y1="1.25" x2="3.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="3.31" y1="1.25" x2="4.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="4.31" y1="1.25" x2="4.56" y2="1.25" width="0.2032" layer="51"/>
<wire x1="4.56" y1="1.25" x2="4.56" y2="3.75" width="0.2032" layer="51"/>
<wire x1="4.56" y1="3.75" x2="3.06" y2="3.75" width="0.2032" layer="51"/>
<wire x1="3.31" y1="-4.25" x2="3.31" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="3.31" y1="-5.75" x2="4.31" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="4.31" y1="-5.75" x2="4.31" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="4.31" y1="-4.25" x2="3.31" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="3.31" y1="3.25" x2="3.31" y2="1.75" width="0.2032" layer="51"/>
<wire x1="3.31" y1="1.75" x2="4.31" y2="1.75" width="0.2032" layer="51"/>
<wire x1="4.31" y1="1.75" x2="4.31" y2="3.25" width="0.2032" layer="51"/>
<wire x1="4.31" y1="3.25" x2="3.31" y2="3.25" width="0.2032" layer="51"/>
<wire x1="3.31" y1="1.25" x2="3.31" y2="-1" width="0.2032" layer="51"/>
<wire x1="3.31" y1="-1" x2="4.31" y2="-1" width="0.2032" layer="51"/>
<wire x1="4.31" y1="-1" x2="4.31" y2="1.25" width="0.2032" layer="51"/>
<wire x1="2.54" y1="-6.985" x2="2.54" y2="4.699" width="0.2032" layer="21"/>
<wire x1="5.6" y1="3.75" x2="5.6" y2="1.25" width="0.2032" layer="51"/>
<wire x1="5.6" y1="1.25" x2="5.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="5.85" y1="1.25" x2="6.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="6.85" y1="1.25" x2="7.1" y2="1.25" width="0.2032" layer="51"/>
<wire x1="7.1" y1="1.25" x2="7.1" y2="3.75" width="0.2032" layer="51"/>
<wire x1="7.1" y1="3.75" x2="5.6" y2="3.75" width="0.2032" layer="51"/>
<wire x1="5.85" y1="-4.25" x2="5.85" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="5.85" y1="-5.75" x2="6.85" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="6.85" y1="-5.75" x2="6.85" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="6.85" y1="-4.25" x2="5.85" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="5.85" y1="3.25" x2="5.85" y2="1.75" width="0.2032" layer="51"/>
<wire x1="5.85" y1="1.75" x2="6.85" y2="1.75" width="0.2032" layer="51"/>
<wire x1="6.85" y1="1.75" x2="6.85" y2="3.25" width="0.2032" layer="51"/>
<wire x1="6.85" y1="3.25" x2="5.85" y2="3.25" width="0.2032" layer="51"/>
<wire x1="5.85" y1="1.25" x2="5.85" y2="-1" width="0.2032" layer="51"/>
<wire x1="5.85" y1="-1" x2="6.85" y2="-1" width="0.2032" layer="51"/>
<wire x1="6.85" y1="-1" x2="6.85" y2="1.25" width="0.2032" layer="51"/>
<wire x1="5.08" y1="-6.985" x2="5.08" y2="4.699" width="0.2032" layer="21"/>
<wire x1="8.14" y1="3.75" x2="8.14" y2="1.25" width="0.2032" layer="51"/>
<wire x1="8.14" y1="1.25" x2="8.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="8.39" y1="1.25" x2="9.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="9.39" y1="1.25" x2="9.64" y2="1.25" width="0.2032" layer="51"/>
<wire x1="9.64" y1="1.25" x2="9.64" y2="3.75" width="0.2032" layer="51"/>
<wire x1="9.64" y1="3.75" x2="8.14" y2="3.75" width="0.2032" layer="51"/>
<wire x1="8.39" y1="-4.25" x2="8.39" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="8.39" y1="-5.75" x2="9.39" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="9.39" y1="-5.75" x2="9.39" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="9.39" y1="-4.25" x2="8.39" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="8.39" y1="3.25" x2="8.39" y2="1.75" width="0.2032" layer="51"/>
<wire x1="8.39" y1="1.75" x2="9.39" y2="1.75" width="0.2032" layer="51"/>
<wire x1="9.39" y1="1.75" x2="9.39" y2="3.25" width="0.2032" layer="51"/>
<wire x1="9.39" y1="3.25" x2="8.39" y2="3.25" width="0.2032" layer="51"/>
<wire x1="8.39" y1="1.25" x2="8.39" y2="-1" width="0.2032" layer="51"/>
<wire x1="8.39" y1="-1" x2="9.39" y2="-1" width="0.2032" layer="51"/>
<wire x1="9.39" y1="-1" x2="9.39" y2="1.25" width="0.2032" layer="51"/>
<wire x1="7.62" y1="-6.985" x2="7.62" y2="4.699" width="0.2032" layer="21"/>
<wire x1="10.68" y1="3.75" x2="10.68" y2="1.25" width="0.2032" layer="51"/>
<wire x1="10.68" y1="1.25" x2="10.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="10.93" y1="1.25" x2="11.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="11.93" y1="1.25" x2="12.18" y2="1.25" width="0.2032" layer="51"/>
<wire x1="12.18" y1="1.25" x2="12.18" y2="3.75" width="0.2032" layer="51"/>
<wire x1="12.18" y1="3.75" x2="10.68" y2="3.75" width="0.2032" layer="51"/>
<wire x1="10.93" y1="-4.25" x2="10.93" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="10.93" y1="-5.75" x2="11.93" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="11.93" y1="-5.75" x2="11.93" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="11.93" y1="-4.25" x2="10.93" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="10.93" y1="3.25" x2="10.93" y2="1.75" width="0.2032" layer="51"/>
<wire x1="10.93" y1="1.75" x2="11.93" y2="1.75" width="0.2032" layer="51"/>
<wire x1="11.93" y1="1.75" x2="11.93" y2="3.25" width="0.2032" layer="51"/>
<wire x1="11.93" y1="3.25" x2="10.93" y2="3.25" width="0.2032" layer="51"/>
<wire x1="10.93" y1="1.25" x2="10.93" y2="-1" width="0.2032" layer="51"/>
<wire x1="10.93" y1="-1" x2="11.93" y2="-1" width="0.2032" layer="51"/>
<wire x1="11.93" y1="-1" x2="11.93" y2="1.25" width="0.2032" layer="51"/>
<wire x1="10.16" y1="-6.985" x2="10.16" y2="4.699" width="0.2032" layer="21"/>
<wire x1="13.22" y1="3.75" x2="13.22" y2="1.25" width="0.2032" layer="51"/>
<wire x1="13.22" y1="1.25" x2="13.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="13.47" y1="1.25" x2="14.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="14.47" y1="1.25" x2="14.72" y2="1.25" width="0.2032" layer="51"/>
<wire x1="14.72" y1="1.25" x2="14.72" y2="3.75" width="0.2032" layer="51"/>
<wire x1="14.72" y1="3.75" x2="13.22" y2="3.75" width="0.2032" layer="51"/>
<wire x1="13.47" y1="-4.25" x2="13.47" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="13.47" y1="-5.75" x2="14.47" y2="-5.75" width="0.2032" layer="21"/>
<wire x1="14.47" y1="-5.75" x2="14.47" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="14.47" y1="-4.25" x2="13.47" y2="-4.25" width="0.2032" layer="21"/>
<wire x1="13.47" y1="3.25" x2="13.47" y2="1.75" width="0.2032" layer="51"/>
<wire x1="13.47" y1="1.75" x2="14.47" y2="1.75" width="0.2032" layer="51"/>
<wire x1="14.47" y1="1.75" x2="14.47" y2="3.25" width="0.2032" layer="51"/>
<wire x1="14.47" y1="3.25" x2="13.47" y2="3.25" width="0.2032" layer="51"/>
<wire x1="13.47" y1="1.25" x2="13.47" y2="-1" width="0.2032" layer="51"/>
<wire x1="13.47" y1="-1" x2="14.47" y2="-1" width="0.2032" layer="51"/>
<wire x1="14.47" y1="-1" x2="14.47" y2="1.25" width="0.2032" layer="51"/>
<wire x1="12.7" y1="-6.985" x2="12.7" y2="4.699" width="0.2032" layer="21"/>
<wire x1="15.24" y1="-6.985" x2="15.24" y2="4.699" width="0.2032" layer="21"/>
<pad name="A1" x="-13.97" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B1" x="-13.97" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A2" x="-11.43" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B2" x="-11.43" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A3" x="-8.89" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B3" x="-8.89" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A4" x="-6.35" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B4" x="-6.35" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A5" x="-3.81" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B5" x="-3.81" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A6" x="-1.27" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B6" x="-1.27" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A7" x="1.27" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B7" x="1.27" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A8" x="3.81" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B8" x="3.81" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A9" x="6.35" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B9" x="6.35" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A10" x="8.89" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B10" x="8.89" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A11" x="11.43" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B11" x="11.43" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="A12" x="13.97" y="2.5" drill="1.2" shape="long" rot="R90"/>
<pad name="B12" x="13.97" y="-2.5" drill="1.2" shape="long" rot="R90"/>
<text x="-14.07" y="5.25" size="1.27" layer="25">&gt;NAME</text>
<text x="-4.82" y="5.25" size="1.27" layer="27">&gt;VALUE</text>
<text x="-14.12" y="-6.85" size="0.8128" layer="21">1</text>
<text x="-4.087" y="-6.85" size="0.8128" layer="21">5</text>
<text x="8.232" y="-6.85" size="0.8128" layer="21">10</text>
</package>
</packages>
<symbols>
<symbol name="KL-12">
<wire x1="-2.54" y1="12.954" x2="-2.54" y2="12.446" width="0.254" layer="94"/>
<wire x1="-2.54" y1="12.446" x2="-1.016" y2="12.446" width="0.254" layer="94"/>
<wire x1="-1.016" y1="12.446" x2="-1.016" y2="12.954" width="0.254" layer="94"/>
<wire x1="-1.016" y1="12.954" x2="-2.54" y2="12.954" width="0.254" layer="94"/>
<wire x1="-2.54" y1="10.414" x2="-2.54" y2="9.906" width="0.254" layer="94"/>
<wire x1="-2.54" y1="9.906" x2="-1.016" y2="9.906" width="0.254" layer="94"/>
<wire x1="-1.016" y1="9.906" x2="-1.016" y2="10.414" width="0.254" layer="94"/>
<wire x1="-1.016" y1="10.414" x2="-2.54" y2="10.414" width="0.254" layer="94"/>
<wire x1="-2.54" y1="7.874" x2="-2.54" y2="7.366" width="0.254" layer="94"/>
<wire x1="-2.54" y1="7.366" x2="-1.016" y2="7.366" width="0.254" layer="94"/>
<wire x1="-1.016" y1="7.366" x2="-1.016" y2="7.874" width="0.254" layer="94"/>
<wire x1="-1.016" y1="7.874" x2="-2.54" y2="7.874" width="0.254" layer="94"/>
<wire x1="-2.54" y1="5.334" x2="-2.54" y2="4.826" width="0.254" layer="94"/>
<wire x1="-2.54" y1="4.826" x2="-1.016" y2="4.826" width="0.254" layer="94"/>
<wire x1="-1.016" y1="4.826" x2="-1.016" y2="5.334" width="0.254" layer="94"/>
<wire x1="-1.016" y1="5.334" x2="-2.54" y2="5.334" width="0.254" layer="94"/>
<wire x1="-2.54" y1="2.794" x2="-2.54" y2="2.286" width="0.254" layer="94"/>
<wire x1="-2.54" y1="2.286" x2="-1.016" y2="2.286" width="0.254" layer="94"/>
<wire x1="-1.016" y1="2.286" x2="-1.016" y2="2.794" width="0.254" layer="94"/>
<wire x1="-1.016" y1="2.794" x2="-2.54" y2="2.794" width="0.254" layer="94"/>
<wire x1="-2.54" y1="0.254" x2="-2.54" y2="-0.254" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-0.254" x2="-1.016" y2="-0.254" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-0.254" x2="-1.016" y2="0.254" width="0.254" layer="94"/>
<wire x1="-1.016" y1="0.254" x2="-2.54" y2="0.254" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-2.286" x2="-2.54" y2="-2.794" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-2.794" x2="-1.016" y2="-2.794" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-2.794" x2="-1.016" y2="-2.286" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-2.286" x2="-2.54" y2="-2.286" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-4.826" x2="-2.54" y2="-5.334" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-5.334" x2="-1.016" y2="-5.334" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-5.334" x2="-1.016" y2="-4.826" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-4.826" x2="-2.54" y2="-4.826" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-7.366" x2="-2.54" y2="-7.874" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-7.874" x2="-1.016" y2="-7.874" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-7.874" x2="-1.016" y2="-7.366" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-7.366" x2="-2.54" y2="-7.366" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-9.906" x2="-2.54" y2="-10.414" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-10.414" x2="-1.016" y2="-10.414" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-10.414" x2="-1.016" y2="-9.906" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-9.906" x2="-2.54" y2="-9.906" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-12.446" x2="-2.54" y2="-12.954" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-12.954" x2="-1.016" y2="-12.954" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-12.954" x2="-1.016" y2="-12.446" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-12.446" x2="-2.54" y2="-12.446" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-14.986" x2="-2.54" y2="-15.494" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-15.494" x2="-1.016" y2="-15.494" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-15.494" x2="-1.016" y2="-14.986" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-14.986" x2="-2.54" y2="-14.986" width="0.254" layer="94"/>
<text x="-5.08" y="15.24" size="1.778" layer="95">&gt;NAME</text>
<text x="-5.08" y="-19.05" size="1.778" layer="96">&gt;VALUE</text>
<pin name="-1" x="-5.08" y="12.7" visible="pin" length="short" direction="pas"/>
<pin name="-2" x="-5.08" y="10.16" visible="pin" length="short" direction="pas"/>
<pin name="-3" x="-5.08" y="7.62" visible="pin" length="short" direction="pas"/>
<pin name="-4" x="-5.08" y="5.08" visible="pin" length="short" direction="pas"/>
<pin name="-5" x="-5.08" y="2.54" visible="pin" length="short" direction="pas"/>
<pin name="-6" x="-5.08" y="0" visible="pin" length="short" direction="pas"/>
<pin name="-7" x="-5.08" y="-2.54" visible="pin" length="short" direction="pas"/>
<pin name="-8" x="-5.08" y="-5.08" visible="pin" length="short" direction="pas"/>
<pin name="-9" x="-5.08" y="-7.62" visible="pin" length="short" direction="pas"/>
<pin name="-10" x="-5.08" y="-10.16" visible="pin" length="short" direction="pas"/>
<pin name="-11" x="-5.08" y="-12.7" visible="pin" length="short" direction="pas"/>
<pin name="-12" x="-5.08" y="-15.24" visible="pin" length="short" direction="pas"/>
<pin name="B-12" x="-7.62" y="-15.24" visible="off" length="short" direction="pas"/>
<pin name="B-1" x="-7.62" y="12.7" visible="off" length="short" direction="pas"/>
<pin name="B-2" x="-7.62" y="10.16" visible="off" length="short" direction="pas"/>
<pin name="B-3" x="-7.62" y="7.62" visible="off" length="short" direction="pas"/>
<pin name="B-4" x="-7.62" y="5.08" visible="off" length="short" direction="pas"/>
<pin name="B-5" x="-7.62" y="2.54" visible="off" length="short" direction="pas"/>
<pin name="B-6" x="-7.62" y="0" visible="off" length="short" direction="pas"/>
<pin name="B-7" x="-7.62" y="-2.54" visible="off" length="short" direction="pas"/>
<pin name="B-8" x="-7.62" y="-5.08" visible="off" length="short" direction="pas"/>
<pin name="B-9" x="-7.62" y="-7.62" visible="off" length="short" direction="pas"/>
<pin name="B-10" x="-7.62" y="-10.16" visible="off" length="short" direction="pas"/>
<pin name="B-11" x="-7.62" y="-12.7" visible="off" length="short" direction="pas"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="233-512" prefix="X" uservalue="yes">
<description>&lt;b&gt;WAGO Cage Clamp&lt;/b&gt;</description>
<gates>
<gate name="G$1" symbol="KL-12" x="0" y="0"/>
</gates>
<devices>
<device name="" package="233-512">
<connects>
<connect gate="G$1" pin="-1" pad="A1"/>
<connect gate="G$1" pin="-10" pad="A10"/>
<connect gate="G$1" pin="-11" pad="A11"/>
<connect gate="G$1" pin="-12" pad="A12"/>
<connect gate="G$1" pin="-2" pad="A2"/>
<connect gate="G$1" pin="-3" pad="A3"/>
<connect gate="G$1" pin="-4" pad="A4"/>
<connect gate="G$1" pin="-5" pad="A5"/>
<connect gate="G$1" pin="-6" pad="A6"/>
<connect gate="G$1" pin="-7" pad="A7"/>
<connect gate="G$1" pin="-8" pad="A8"/>
<connect gate="G$1" pin="-9" pad="A9"/>
<connect gate="G$1" pin="B-1" pad="B1"/>
<connect gate="G$1" pin="B-10" pad="B10"/>
<connect gate="G$1" pin="B-11" pad="B11"/>
<connect gate="G$1" pin="B-12" pad="B12"/>
<connect gate="G$1" pin="B-2" pad="B2"/>
<connect gate="G$1" pin="B-3" pad="B3"/>
<connect gate="G$1" pin="B-4" pad="B4"/>
<connect gate="G$1" pin="B-5" pad="B5"/>
<connect gate="G$1" pin="B-6" pad="B6"/>
<connect gate="G$1" pin="B-7" pad="B7"/>
<connect gate="G$1" pin="B-8" pad="B8"/>
<connect gate="G$1" pin="B-9" pad="B9"/>
</connects>
<technologies>
<technology name="">
<attribute name="MF" value="Wago Corporation" constant="no"/>
<attribute name="MPN" value="0233-0512" constant="no"/>
<attribute name="OC_FARNELL" value="1777102" constant="no"/>
<attribute name="OC_NEWARK" value="79K2055" constant="no"/>
</technology>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
<library name="jumper">
<description>&lt;b&gt;Jumpers&lt;/b&gt;&lt;p&gt;
&lt;author&gt;Created by librarian@cadsoft.de&lt;/author&gt;</description>
<packages>
<package name="JP1">
<description>&lt;b&gt;JUMPER&lt;/b&gt;</description>
<wire x1="-1.016" y1="0" x2="-1.27" y2="0.254" width="0.1524" layer="21"/>
<wire x1="-1.016" y1="0" x2="-1.27" y2="-0.254" width="0.1524" layer="21"/>
<wire x1="1.016" y1="0" x2="1.27" y2="0.254" width="0.1524" layer="21"/>
<wire x1="1.016" y1="0" x2="1.27" y2="-0.254" width="0.1524" layer="21"/>
<wire x1="1.27" y1="-0.254" x2="1.27" y2="-2.286" width="0.1524" layer="21"/>
<wire x1="1.016" y1="-2.54" x2="1.27" y2="-2.286" width="0.1524" layer="21"/>
<wire x1="1.27" y1="2.286" x2="1.016" y2="2.54" width="0.1524" layer="21"/>
<wire x1="1.27" y1="2.286" x2="1.27" y2="0.254" width="0.1524" layer="21"/>
<wire x1="1.016" y1="2.54" x2="-1.016" y2="2.54" width="0.1524" layer="21"/>
<wire x1="-1.27" y1="2.286" x2="-1.016" y2="2.54" width="0.1524" layer="21"/>
<wire x1="-1.27" y1="2.286" x2="-1.27" y2="0.254" width="0.1524" layer="21"/>
<wire x1="-1.27" y1="-0.254" x2="-1.27" y2="-2.286" width="0.1524" layer="21"/>
<wire x1="-1.016" y1="-2.54" x2="-1.27" y2="-2.286" width="0.1524" layer="21"/>
<wire x1="-1.016" y1="-2.54" x2="1.016" y2="-2.54" width="0.1524" layer="21"/>
<pad name="1" x="0" y="-1.27" drill="0.9144" shape="long"/>
<pad name="2" x="0" y="1.27" drill="0.9144" shape="long"/>
<text x="-1.651" y="-2.54" size="1.27" layer="25" ratio="10" rot="R90">&gt;NAME</text>
<text x="2.921" y="-2.54" size="1.27" layer="27" ratio="10" rot="R90">&gt;VALUE</text>
<rectangle x1="-0.3048" y1="0.9652" x2="0.3048" y2="1.5748" layer="51"/>
<rectangle x1="-0.3048" y1="-1.5748" x2="0.3048" y2="-0.9652" layer="51"/>
</package>
</packages>
<symbols>
<symbol name="JP2E">
<wire x1="0" y1="0" x2="0" y2="1.27" width="0.1524" layer="94"/>
<wire x1="0" y1="2.54" x2="0" y2="1.27" width="0.4064" layer="94"/>
<wire x1="2.54" y1="0" x2="2.54" y2="1.27" width="0.1524" layer="94"/>
<wire x1="2.54" y1="2.54" x2="2.54" y2="1.27" width="0.4064" layer="94"/>
<wire x1="-0.635" y1="0" x2="3.175" y2="0" width="0.4064" layer="94"/>
<wire x1="3.175" y1="0" x2="3.175" y2="0.635" width="0.4064" layer="94"/>
<wire x1="3.175" y1="0.635" x2="-0.635" y2="0.635" width="0.4064" layer="94"/>
<wire x1="-0.635" y1="0.635" x2="-0.635" y2="0" width="0.4064" layer="94"/>
<text x="-1.27" y="0" size="1.778" layer="95" rot="R90">&gt;NAME</text>
<text x="5.715" y="0" size="1.778" layer="96" rot="R90">&gt;VALUE</text>
<pin name="1" x="0" y="-2.54" visible="pad" length="short" direction="pas" rot="R90"/>
<pin name="2" x="2.54" y="-2.54" visible="pad" length="short" direction="pas" rot="R90"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="JP1E" prefix="JP" uservalue="yes">
<description>&lt;b&gt;JUMPER&lt;/b&gt;</description>
<gates>
<gate name="A" symbol="JP2E" x="2.54" y="0"/>
</gates>
<devices>
<device name="" package="JP1">
<connects>
<connect gate="A" pin="1" pad="1"/>
<connect gate="A" pin="2" pad="2"/>
</connects>
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
</libraries>
<attributes>
</attributes>
<variantdefs>
</variantdefs>
<classes>
<class number="0" name="default" width="0.4064" drill="0">
<clearance class="0" value="0.1016"/>
</class>
<class number="1" name="12V" width="0.8128" drill="0">
<clearance class="1" value="0.254"/>
</class>
<class number="2" name="GND" width="0.8128" drill="0">
<clearance class="2" value="0.254"/>
</class>
</classes>
<parts>
<part name="FRAME1" library="frames" deviceset="DINA4_L" device=""/>
<part name="X13" library="con-wago" deviceset="233-512" device=""/>
<part name="X14" library="con-wago" deviceset="233-512" device=""/>
<part name="X15" library="con-wago" deviceset="233-512" device=""/>
<part name="X1" library="con-wago" deviceset="233-512" device=""/>
<part name="X2" library="con-wago" deviceset="233-512" device=""/>
<part name="X3" library="con-wago" deviceset="233-512" device=""/>
<part name="JP1" library="jumper" deviceset="JP1E" device=""/>
<part name="JP2" library="jumper" deviceset="JP1E" device=""/>
<part name="JP3" library="jumper" deviceset="JP1E" device=""/>
<part name="JP4" library="jumper" deviceset="JP1E" device=""/>
<part name="JP5" library="jumper" deviceset="JP1E" device=""/>
<part name="JP6" library="jumper" deviceset="JP1E" device=""/>
<part name="JP7" library="jumper" deviceset="JP1E" device=""/>
<part name="JP8" library="jumper" deviceset="JP1E" device=""/>
<part name="JP9" library="jumper" deviceset="JP1E" device=""/>
<part name="JP10" library="jumper" deviceset="JP1E" device=""/>
<part name="JP11" library="jumper" deviceset="JP1E" device=""/>
<part name="JP12" library="jumper" deviceset="JP1E" device=""/>
<part name="JP13" library="jumper" deviceset="JP1E" device=""/>
<part name="JP14" library="jumper" deviceset="JP1E" device=""/>
<part name="JP15" library="jumper" deviceset="JP1E" device=""/>
<part name="JP16" library="jumper" deviceset="JP1E" device=""/>
<part name="JP17" library="jumper" deviceset="JP1E" device=""/>
<part name="JP18" library="jumper" deviceset="JP1E" device=""/>
<part name="JP19" library="jumper" deviceset="JP1E" device=""/>
<part name="JP20" library="jumper" deviceset="JP1E" device=""/>
<part name="JP21" library="jumper" deviceset="JP1E" device=""/>
<part name="JP22" library="jumper" deviceset="JP1E" device=""/>
<part name="JP23" library="jumper" deviceset="JP1E" device=""/>
<part name="JP24" library="jumper" deviceset="JP1E" device=""/>
</parts>
<sheets>
<sheet>
<plain>
<text x="167.64" y="27.94" size="2.1844" layer="91">HAP-12xBusverteiler-1.0</text>
<text x="254" y="7.62" size="2.1844" layer="91">1.0</text>
</plain>
<instances>
<instance part="FRAME1" gate="G$1" x="0" y="0"/>
<instance part="FRAME1" gate="G$2" x="162.56" y="0"/>
<instance part="X13" gate="G$1" x="137.16" y="149.86"/>
<instance part="X14" gate="G$1" x="137.16" y="114.3"/>
<instance part="X15" gate="G$1" x="137.16" y="78.74"/>
<instance part="X1" gate="G$1" x="93.98" y="149.86"/>
<instance part="X2" gate="G$1" x="93.98" y="114.3"/>
<instance part="X3" gate="G$1" x="93.98" y="78.74"/>
<instance part="JP1" gate="A" x="76.2" y="154.94" rot="R90"/>
<instance part="JP2" gate="A" x="76.2" y="149.86" rot="R90"/>
<instance part="JP3" gate="A" x="76.2" y="139.7" rot="R90"/>
<instance part="JP4" gate="A" x="76.2" y="134.62" rot="R90"/>
<instance part="JP5" gate="A" x="76.2" y="119.38" rot="R90"/>
<instance part="JP6" gate="A" x="76.2" y="114.3" rot="R90"/>
<instance part="JP7" gate="A" x="76.2" y="104.14" rot="R90"/>
<instance part="JP8" gate="A" x="76.2" y="99.06" rot="R90"/>
<instance part="JP9" gate="A" x="76.2" y="83.82" rot="R90"/>
<instance part="JP10" gate="A" x="76.2" y="78.74" rot="R90"/>
<instance part="JP11" gate="A" x="76.2" y="68.58" rot="R90"/>
<instance part="JP12" gate="A" x="76.2" y="63.5" rot="R90"/>
<instance part="JP13" gate="A" x="119.38" y="154.94" rot="R90"/>
<instance part="JP14" gate="A" x="119.38" y="149.86" rot="R90"/>
<instance part="JP15" gate="A" x="119.38" y="139.7" rot="R90"/>
<instance part="JP16" gate="A" x="119.38" y="134.62" rot="R90"/>
<instance part="JP17" gate="A" x="119.38" y="119.38" rot="R90"/>
<instance part="JP18" gate="A" x="119.38" y="114.3" rot="R90"/>
<instance part="JP19" gate="A" x="119.38" y="104.14" rot="R90"/>
<instance part="JP20" gate="A" x="119.38" y="99.06" rot="R90"/>
<instance part="JP21" gate="A" x="119.38" y="83.82" rot="R90"/>
<instance part="JP22" gate="A" x="119.38" y="78.74" rot="R90"/>
<instance part="JP23" gate="A" x="119.38" y="68.58" rot="R90"/>
<instance part="JP24" gate="A" x="119.38" y="63.5" rot="R90"/>
</instances>
<busses>
<bus name="GND,12V,H,HB,L,LB">
<segment>
<wire x1="60.96" y1="165.1" x2="60.96" y2="60.96" width="0.762" layer="92"/>
<wire x1="106.68" y1="165.1" x2="106.68" y2="60.96" width="0.762" layer="92"/>
</segment>
</bus>
</busses>
<nets>
<net name="12V" class="1">
<segment>
<pinref part="X2" gate="G$1" pin="B-1"/>
<wire x1="86.36" y1="127" x2="60.96" y2="127" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X3" gate="G$1" pin="B-1"/>
<wire x1="86.36" y1="91.44" x2="60.96" y2="91.44" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X2" gate="G$1" pin="B-7"/>
<wire x1="86.36" y1="111.76" x2="60.96" y2="111.76" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X3" gate="G$1" pin="B-7"/>
<wire x1="86.36" y1="76.2" x2="60.96" y2="76.2" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X1" gate="G$1" pin="B-1"/>
<wire x1="86.36" y1="162.56" x2="60.96" y2="162.56" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X1" gate="G$1" pin="B-7"/>
<wire x1="86.36" y1="147.32" x2="60.96" y2="147.32" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X13" gate="G$1" pin="B-1"/>
<wire x1="129.54" y1="162.56" x2="106.68" y2="162.56" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X13" gate="G$1" pin="B-7"/>
<wire x1="129.54" y1="147.32" x2="106.68" y2="147.32" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X14" gate="G$1" pin="B-1"/>
<wire x1="129.54" y1="127" x2="106.68" y2="127" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X14" gate="G$1" pin="B-7"/>
<wire x1="129.54" y1="111.76" x2="106.68" y2="111.76" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X15" gate="G$1" pin="B-1"/>
<wire x1="129.54" y1="91.44" x2="106.68" y2="91.44" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X15" gate="G$1" pin="B-7"/>
<wire x1="129.54" y1="76.2" x2="106.68" y2="76.2" width="0.1524" layer="91"/>
</segment>
</net>
<net name="GND" class="2">
<segment>
<pinref part="X2" gate="G$1" pin="B-2"/>
<wire x1="86.36" y1="124.46" x2="60.96" y2="124.46" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X3" gate="G$1" pin="B-2"/>
<wire x1="86.36" y1="88.9" x2="60.96" y2="88.9" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X2" gate="G$1" pin="B-8"/>
<wire x1="86.36" y1="109.22" x2="60.96" y2="109.22" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X3" gate="G$1" pin="B-8"/>
<wire x1="86.36" y1="73.66" x2="60.96" y2="73.66" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X1" gate="G$1" pin="B-2"/>
<wire x1="86.36" y1="160.02" x2="60.96" y2="160.02" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X1" gate="G$1" pin="B-8"/>
<wire x1="86.36" y1="144.78" x2="60.96" y2="144.78" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X13" gate="G$1" pin="B-2"/>
<wire x1="129.54" y1="160.02" x2="106.68" y2="160.02" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X13" gate="G$1" pin="B-8"/>
<wire x1="129.54" y1="144.78" x2="106.68" y2="144.78" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X14" gate="G$1" pin="B-2"/>
<wire x1="129.54" y1="124.46" x2="106.68" y2="124.46" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X14" gate="G$1" pin="B-8"/>
<wire x1="129.54" y1="109.22" x2="106.68" y2="109.22" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X15" gate="G$1" pin="B-2"/>
<wire x1="129.54" y1="88.9" x2="106.68" y2="88.9" width="0.1524" layer="91"/>
</segment>
<segment>
<pinref part="X15" gate="G$1" pin="B-8"/>
<wire x1="129.54" y1="73.66" x2="106.68" y2="73.66" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$1" class="0">
<segment>
<pinref part="X1" gate="G$1" pin="B-4"/>
<wire x1="86.36" y1="154.94" x2="81.28" y2="154.94" width="0.1524" layer="91"/>
<pinref part="JP1" gate="A" pin="1"/>
<pinref part="X1" gate="G$1" pin="B-9"/>
<pinref part="JP3" gate="A" pin="2"/>
<wire x1="81.28" y1="154.94" x2="78.74" y2="154.94" width="0.1524" layer="91"/>
<wire x1="78.74" y1="142.24" x2="81.28" y2="142.24" width="0.1524" layer="91"/>
<wire x1="81.28" y1="142.24" x2="86.36" y2="142.24" width="0.1524" layer="91"/>
<wire x1="81.28" y1="154.94" x2="81.28" y2="142.24" width="0.1524" layer="91"/>
<junction x="81.28" y="154.94"/>
<junction x="81.28" y="142.24"/>
</segment>
</net>
<net name="N$2" class="0">
<segment>
<pinref part="X1" gate="G$1" pin="B-10"/>
<pinref part="JP3" gate="A" pin="1"/>
<wire x1="78.74" y1="139.7" x2="81.28" y2="139.7" width="0.1524" layer="91"/>
<pinref part="JP5" gate="A" pin="2"/>
<pinref part="X2" gate="G$1" pin="B-3"/>
<wire x1="81.28" y1="139.7" x2="86.36" y2="139.7" width="0.1524" layer="91"/>
<wire x1="78.74" y1="121.92" x2="81.28" y2="121.92" width="0.1524" layer="91"/>
<wire x1="81.28" y1="121.92" x2="86.36" y2="121.92" width="0.1524" layer="91"/>
<wire x1="81.28" y1="139.7" x2="81.28" y2="121.92" width="0.1524" layer="91"/>
<junction x="81.28" y="139.7"/>
<junction x="81.28" y="121.92"/>
</segment>
</net>
<net name="N$12" class="0">
<segment>
<pinref part="X1" gate="G$1" pin="B-6"/>
<wire x1="86.36" y1="149.86" x2="83.82" y2="149.86" width="0.1524" layer="91"/>
<pinref part="JP2" gate="A" pin="1"/>
<pinref part="X1" gate="G$1" pin="B-11"/>
<wire x1="83.82" y1="149.86" x2="78.74" y2="149.86" width="0.1524" layer="91"/>
<wire x1="78.74" y1="137.16" x2="83.82" y2="137.16" width="0.1524" layer="91"/>
<pinref part="JP4" gate="A" pin="2"/>
<wire x1="83.82" y1="137.16" x2="86.36" y2="137.16" width="0.1524" layer="91"/>
<wire x1="83.82" y1="149.86" x2="83.82" y2="137.16" width="0.1524" layer="91"/>
<junction x="83.82" y="149.86"/>
<junction x="83.82" y="137.16"/>
</segment>
</net>
<net name="N$13" class="0">
<segment>
<pinref part="X1" gate="G$1" pin="B-12"/>
<wire x1="86.36" y1="134.62" x2="83.82" y2="134.62" width="0.1524" layer="91"/>
<pinref part="JP4" gate="A" pin="1"/>
<pinref part="JP6" gate="A" pin="2"/>
<pinref part="X2" gate="G$1" pin="B-5"/>
<wire x1="83.82" y1="134.62" x2="78.74" y2="134.62" width="0.1524" layer="91"/>
<wire x1="78.74" y1="116.84" x2="83.82" y2="116.84" width="0.1524" layer="91"/>
<wire x1="83.82" y1="116.84" x2="86.36" y2="116.84" width="0.1524" layer="91"/>
<wire x1="83.82" y1="134.62" x2="83.82" y2="116.84" width="0.1524" layer="91"/>
<junction x="83.82" y="134.62"/>
<junction x="83.82" y="116.84"/>
</segment>
</net>
<net name="N$23" class="0">
<segment>
<pinref part="JP1" gate="A" pin="2"/>
<pinref part="X1" gate="G$1" pin="B-3"/>
<wire x1="78.74" y1="157.48" x2="86.36" y2="157.48" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$24" class="0">
<segment>
<pinref part="JP2" gate="A" pin="2"/>
<pinref part="X1" gate="G$1" pin="B-5"/>
<wire x1="78.74" y1="152.4" x2="86.36" y2="152.4" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$4" class="0">
<segment>
<pinref part="JP5" gate="A" pin="1"/>
<pinref part="X2" gate="G$1" pin="B-4"/>
<wire x1="78.74" y1="119.38" x2="81.28" y2="119.38" width="0.1524" layer="91"/>
<pinref part="JP7" gate="A" pin="2"/>
<pinref part="X2" gate="G$1" pin="B-9"/>
<wire x1="81.28" y1="119.38" x2="86.36" y2="119.38" width="0.1524" layer="91"/>
<wire x1="78.74" y1="106.68" x2="81.28" y2="106.68" width="0.1524" layer="91"/>
<wire x1="81.28" y1="106.68" x2="86.36" y2="106.68" width="0.1524" layer="91"/>
<wire x1="81.28" y1="119.38" x2="81.28" y2="106.68" width="0.1524" layer="91"/>
<junction x="81.28" y="119.38"/>
<junction x="81.28" y="106.68"/>
</segment>
</net>
<net name="N$14" class="0">
<segment>
<pinref part="JP6" gate="A" pin="1"/>
<pinref part="X2" gate="G$1" pin="B-6"/>
<wire x1="78.74" y1="114.3" x2="83.82" y2="114.3" width="0.1524" layer="91"/>
<pinref part="JP8" gate="A" pin="2"/>
<pinref part="X2" gate="G$1" pin="B-11"/>
<wire x1="83.82" y1="114.3" x2="86.36" y2="114.3" width="0.1524" layer="91"/>
<wire x1="78.74" y1="101.6" x2="83.82" y2="101.6" width="0.1524" layer="91"/>
<wire x1="83.82" y1="101.6" x2="86.36" y2="101.6" width="0.1524" layer="91"/>
<wire x1="83.82" y1="114.3" x2="83.82" y2="101.6" width="0.1524" layer="91"/>
<junction x="83.82" y="114.3"/>
<junction x="83.82" y="101.6"/>
</segment>
</net>
<net name="N$16" class="0">
<segment>
<pinref part="JP7" gate="A" pin="1"/>
<pinref part="X2" gate="G$1" pin="B-10"/>
<wire x1="78.74" y1="104.14" x2="81.28" y2="104.14" width="0.1524" layer="91"/>
<pinref part="JP9" gate="A" pin="2"/>
<pinref part="X3" gate="G$1" pin="B-3"/>
<wire x1="81.28" y1="104.14" x2="86.36" y2="104.14" width="0.1524" layer="91"/>
<wire x1="78.74" y1="86.36" x2="81.28" y2="86.36" width="0.1524" layer="91"/>
<wire x1="81.28" y1="86.36" x2="86.36" y2="86.36" width="0.1524" layer="91"/>
<wire x1="81.28" y1="104.14" x2="81.28" y2="86.36" width="0.1524" layer="91"/>
<junction x="81.28" y="104.14"/>
<junction x="81.28" y="86.36"/>
</segment>
</net>
<net name="N$28" class="0">
<segment>
<pinref part="JP8" gate="A" pin="1"/>
<pinref part="X2" gate="G$1" pin="B-12"/>
<wire x1="78.74" y1="99.06" x2="83.82" y2="99.06" width="0.1524" layer="91"/>
<pinref part="JP10" gate="A" pin="2"/>
<pinref part="X3" gate="G$1" pin="B-5"/>
<wire x1="83.82" y1="99.06" x2="86.36" y2="99.06" width="0.1524" layer="91"/>
<wire x1="78.74" y1="81.28" x2="83.82" y2="81.28" width="0.1524" layer="91"/>
<wire x1="83.82" y1="81.28" x2="86.36" y2="81.28" width="0.1524" layer="91"/>
<wire x1="83.82" y1="99.06" x2="83.82" y2="81.28" width="0.1524" layer="91"/>
<junction x="83.82" y="99.06"/>
<junction x="83.82" y="81.28"/>
</segment>
</net>
<net name="N$30" class="0">
<segment>
<pinref part="JP9" gate="A" pin="1"/>
<pinref part="X3" gate="G$1" pin="B-4"/>
<wire x1="78.74" y1="83.82" x2="81.28" y2="83.82" width="0.1524" layer="91"/>
<pinref part="JP11" gate="A" pin="2"/>
<pinref part="X3" gate="G$1" pin="B-9"/>
<wire x1="81.28" y1="83.82" x2="86.36" y2="83.82" width="0.1524" layer="91"/>
<wire x1="78.74" y1="71.12" x2="81.28" y2="71.12" width="0.1524" layer="91"/>
<wire x1="81.28" y1="71.12" x2="86.36" y2="71.12" width="0.1524" layer="91"/>
<wire x1="81.28" y1="83.82" x2="81.28" y2="71.12" width="0.1524" layer="91"/>
<junction x="81.28" y="83.82"/>
<junction x="81.28" y="71.12"/>
</segment>
</net>
<net name="N$32" class="0">
<segment>
<pinref part="JP10" gate="A" pin="1"/>
<pinref part="X3" gate="G$1" pin="B-6"/>
<wire x1="78.74" y1="78.74" x2="83.82" y2="78.74" width="0.1524" layer="91"/>
<pinref part="JP12" gate="A" pin="2"/>
<pinref part="X3" gate="G$1" pin="B-11"/>
<wire x1="83.82" y1="78.74" x2="86.36" y2="78.74" width="0.1524" layer="91"/>
<wire x1="78.74" y1="66.04" x2="83.82" y2="66.04" width="0.1524" layer="91"/>
<wire x1="83.82" y1="66.04" x2="86.36" y2="66.04" width="0.1524" layer="91"/>
<wire x1="83.82" y1="78.74" x2="83.82" y2="66.04" width="0.1524" layer="91"/>
<junction x="83.82" y="78.74"/>
<junction x="83.82" y="66.04"/>
</segment>
</net>
<net name="N$34" class="0">
<segment>
<pinref part="JP11" gate="A" pin="1"/>
<pinref part="X3" gate="G$1" pin="B-10"/>
<wire x1="78.74" y1="68.58" x2="81.28" y2="68.58" width="0.1524" layer="91"/>
<wire x1="81.28" y1="68.58" x2="86.36" y2="68.58" width="0.1524" layer="91"/>
<wire x1="81.28" y1="68.58" x2="81.28" y2="58.42" width="0.1524" layer="91"/>
<wire x1="81.28" y1="58.42" x2="101.6" y2="58.42" width="0.1524" layer="91"/>
<wire x1="101.6" y1="58.42" x2="101.6" y2="167.64" width="0.1524" layer="91"/>
<wire x1="101.6" y1="167.64" x2="124.46" y2="167.64" width="0.1524" layer="91"/>
<pinref part="X13" gate="G$1" pin="B-3"/>
<pinref part="JP13" gate="A" pin="2"/>
<wire x1="129.54" y1="157.48" x2="124.46" y2="157.48" width="0.1524" layer="91"/>
<wire x1="124.46" y1="157.48" x2="121.92" y2="157.48" width="0.1524" layer="91"/>
<wire x1="124.46" y1="167.64" x2="124.46" y2="157.48" width="0.1524" layer="91"/>
<junction x="124.46" y="157.48"/>
<junction x="81.28" y="68.58"/>
</segment>
</net>
<net name="N$36" class="0">
<segment>
<pinref part="JP12" gate="A" pin="1"/>
<pinref part="X3" gate="G$1" pin="B-12"/>
<wire x1="78.74" y1="63.5" x2="83.82" y2="63.5" width="0.1524" layer="91"/>
<wire x1="83.82" y1="63.5" x2="86.36" y2="63.5" width="0.1524" layer="91"/>
<wire x1="83.82" y1="63.5" x2="83.82" y2="60.96" width="0.1524" layer="91"/>
<wire x1="83.82" y1="60.96" x2="99.06" y2="60.96" width="0.1524" layer="91"/>
<wire x1="99.06" y1="60.96" x2="99.06" y2="170.18" width="0.1524" layer="91"/>
<wire x1="99.06" y1="170.18" x2="127" y2="170.18" width="0.1524" layer="91"/>
<pinref part="JP14" gate="A" pin="2"/>
<pinref part="X13" gate="G$1" pin="B-5"/>
<wire x1="121.92" y1="152.4" x2="127" y2="152.4" width="0.1524" layer="91"/>
<wire x1="127" y1="152.4" x2="129.54" y2="152.4" width="0.1524" layer="91"/>
<wire x1="127" y1="170.18" x2="127" y2="152.4" width="0.1524" layer="91"/>
<junction x="127" y="152.4"/>
<junction x="83.82" y="63.5"/>
</segment>
</net>
<net name="N$5" class="0">
<segment>
<pinref part="JP13" gate="A" pin="1"/>
<pinref part="X13" gate="G$1" pin="B-4"/>
<wire x1="121.92" y1="154.94" x2="124.46" y2="154.94" width="0.1524" layer="91"/>
<pinref part="JP15" gate="A" pin="2"/>
<pinref part="X13" gate="G$1" pin="B-9"/>
<wire x1="124.46" y1="154.94" x2="129.54" y2="154.94" width="0.1524" layer="91"/>
<wire x1="121.92" y1="142.24" x2="124.46" y2="142.24" width="0.1524" layer="91"/>
<wire x1="124.46" y1="142.24" x2="129.54" y2="142.24" width="0.1524" layer="91"/>
<wire x1="124.46" y1="154.94" x2="124.46" y2="142.24" width="0.1524" layer="91"/>
<junction x="124.46" y="154.94"/>
<junction x="124.46" y="142.24"/>
</segment>
</net>
<net name="N$7" class="0">
<segment>
<pinref part="JP14" gate="A" pin="1"/>
<pinref part="X13" gate="G$1" pin="B-6"/>
<wire x1="121.92" y1="149.86" x2="127" y2="149.86" width="0.1524" layer="91"/>
<pinref part="JP16" gate="A" pin="2"/>
<pinref part="X13" gate="G$1" pin="B-11"/>
<wire x1="127" y1="149.86" x2="129.54" y2="149.86" width="0.1524" layer="91"/>
<wire x1="121.92" y1="137.16" x2="127" y2="137.16" width="0.1524" layer="91"/>
<wire x1="127" y1="137.16" x2="129.54" y2="137.16" width="0.1524" layer="91"/>
<wire x1="127" y1="149.86" x2="127" y2="137.16" width="0.1524" layer="91"/>
<junction x="127" y="149.86"/>
<junction x="127" y="137.16"/>
</segment>
</net>
<net name="N$9" class="0">
<segment>
<pinref part="JP15" gate="A" pin="1"/>
<pinref part="X13" gate="G$1" pin="B-10"/>
<wire x1="121.92" y1="139.7" x2="124.46" y2="139.7" width="0.1524" layer="91"/>
<pinref part="JP17" gate="A" pin="2"/>
<pinref part="X14" gate="G$1" pin="B-3"/>
<wire x1="124.46" y1="139.7" x2="129.54" y2="139.7" width="0.1524" layer="91"/>
<wire x1="121.92" y1="121.92" x2="124.46" y2="121.92" width="0.1524" layer="91"/>
<wire x1="124.46" y1="121.92" x2="129.54" y2="121.92" width="0.1524" layer="91"/>
<wire x1="124.46" y1="139.7" x2="124.46" y2="121.92" width="0.1524" layer="91"/>
<junction x="124.46" y="139.7"/>
<junction x="124.46" y="121.92"/>
</segment>
</net>
<net name="N$11" class="0">
<segment>
<pinref part="JP16" gate="A" pin="1"/>
<pinref part="X13" gate="G$1" pin="B-12"/>
<wire x1="121.92" y1="134.62" x2="127" y2="134.62" width="0.1524" layer="91"/>
<pinref part="JP18" gate="A" pin="2"/>
<pinref part="X14" gate="G$1" pin="B-5"/>
<wire x1="127" y1="134.62" x2="129.54" y2="134.62" width="0.1524" layer="91"/>
<wire x1="121.92" y1="116.84" x2="127" y2="116.84" width="0.1524" layer="91"/>
<wire x1="127" y1="116.84" x2="129.54" y2="116.84" width="0.1524" layer="91"/>
<wire x1="127" y1="134.62" x2="127" y2="116.84" width="0.1524" layer="91"/>
<junction x="127" y="134.62"/>
<junction x="127" y="116.84"/>
</segment>
</net>
<net name="N$17" class="0">
<segment>
<pinref part="JP17" gate="A" pin="1"/>
<pinref part="X14" gate="G$1" pin="B-4"/>
<wire x1="121.92" y1="119.38" x2="124.46" y2="119.38" width="0.1524" layer="91"/>
<pinref part="JP19" gate="A" pin="2"/>
<pinref part="X14" gate="G$1" pin="B-9"/>
<wire x1="124.46" y1="119.38" x2="129.54" y2="119.38" width="0.1524" layer="91"/>
<wire x1="121.92" y1="106.68" x2="124.46" y2="106.68" width="0.1524" layer="91"/>
<wire x1="124.46" y1="106.68" x2="129.54" y2="106.68" width="0.1524" layer="91"/>
<wire x1="124.46" y1="119.38" x2="124.46" y2="106.68" width="0.1524" layer="91"/>
<junction x="124.46" y="119.38"/>
<junction x="124.46" y="106.68"/>
</segment>
</net>
<net name="N$19" class="0">
<segment>
<pinref part="JP18" gate="A" pin="1"/>
<pinref part="X14" gate="G$1" pin="B-6"/>
<wire x1="121.92" y1="114.3" x2="127" y2="114.3" width="0.1524" layer="91"/>
<pinref part="JP20" gate="A" pin="2"/>
<pinref part="X14" gate="G$1" pin="B-11"/>
<wire x1="127" y1="114.3" x2="129.54" y2="114.3" width="0.1524" layer="91"/>
<wire x1="121.92" y1="101.6" x2="127" y2="101.6" width="0.1524" layer="91"/>
<wire x1="127" y1="101.6" x2="129.54" y2="101.6" width="0.1524" layer="91"/>
<wire x1="127" y1="114.3" x2="127" y2="101.6" width="0.1524" layer="91"/>
<junction x="127" y="114.3"/>
<junction x="127" y="101.6"/>
</segment>
</net>
<net name="N$21" class="0">
<segment>
<pinref part="JP19" gate="A" pin="1"/>
<pinref part="X14" gate="G$1" pin="B-10"/>
<wire x1="121.92" y1="104.14" x2="124.46" y2="104.14" width="0.1524" layer="91"/>
<pinref part="JP21" gate="A" pin="2"/>
<pinref part="X15" gate="G$1" pin="B-3"/>
<wire x1="124.46" y1="104.14" x2="129.54" y2="104.14" width="0.1524" layer="91"/>
<wire x1="121.92" y1="86.36" x2="124.46" y2="86.36" width="0.1524" layer="91"/>
<wire x1="124.46" y1="86.36" x2="129.54" y2="86.36" width="0.1524" layer="91"/>
<wire x1="124.46" y1="104.14" x2="124.46" y2="86.36" width="0.1524" layer="91"/>
<junction x="124.46" y="104.14"/>
<junction x="124.46" y="86.36"/>
</segment>
</net>
<net name="N$25" class="0">
<segment>
<pinref part="JP20" gate="A" pin="1"/>
<wire x1="121.92" y1="99.06" x2="127" y2="99.06" width="0.1524" layer="91"/>
<pinref part="JP22" gate="A" pin="2"/>
<pinref part="X15" gate="G$1" pin="B-5"/>
<wire x1="127" y1="99.06" x2="129.54" y2="99.06" width="0.1524" layer="91"/>
<wire x1="121.92" y1="81.28" x2="127" y2="81.28" width="0.1524" layer="91"/>
<wire x1="127" y1="81.28" x2="129.54" y2="81.28" width="0.1524" layer="91"/>
<wire x1="127" y1="99.06" x2="127" y2="81.28" width="0.1524" layer="91"/>
<pinref part="X14" gate="G$1" pin="B-12"/>
<junction x="127" y="99.06"/>
<junction x="127" y="81.28"/>
</segment>
</net>
<net name="N$27" class="0">
<segment>
<pinref part="JP21" gate="A" pin="1"/>
<pinref part="X15" gate="G$1" pin="B-4"/>
<wire x1="121.92" y1="83.82" x2="124.46" y2="83.82" width="0.1524" layer="91"/>
<pinref part="JP23" gate="A" pin="2"/>
<pinref part="X15" gate="G$1" pin="B-9"/>
<wire x1="124.46" y1="83.82" x2="129.54" y2="83.82" width="0.1524" layer="91"/>
<wire x1="121.92" y1="71.12" x2="124.46" y2="71.12" width="0.1524" layer="91"/>
<wire x1="124.46" y1="71.12" x2="129.54" y2="71.12" width="0.1524" layer="91"/>
<wire x1="124.46" y1="83.82" x2="124.46" y2="71.12" width="0.1524" layer="91"/>
<junction x="124.46" y="83.82"/>
<junction x="124.46" y="71.12"/>
</segment>
</net>
<net name="N$31" class="0">
<segment>
<pinref part="JP22" gate="A" pin="1"/>
<pinref part="X15" gate="G$1" pin="B-6"/>
<wire x1="121.92" y1="78.74" x2="127" y2="78.74" width="0.1524" layer="91"/>
<pinref part="JP24" gate="A" pin="2"/>
<pinref part="X15" gate="G$1" pin="B-11"/>
<wire x1="127" y1="78.74" x2="129.54" y2="78.74" width="0.1524" layer="91"/>
<wire x1="121.92" y1="66.04" x2="127" y2="66.04" width="0.1524" layer="91"/>
<wire x1="127" y1="66.04" x2="129.54" y2="66.04" width="0.1524" layer="91"/>
<wire x1="127" y1="78.74" x2="127" y2="66.04" width="0.1524" layer="91"/>
<junction x="127" y="78.74"/>
<junction x="127" y="66.04"/>
</segment>
</net>
<net name="N$35" class="0">
<segment>
<pinref part="JP23" gate="A" pin="1"/>
<pinref part="X15" gate="G$1" pin="B-10"/>
<wire x1="121.92" y1="68.58" x2="129.54" y2="68.58" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$38" class="0">
<segment>
<pinref part="JP24" gate="A" pin="1"/>
<pinref part="X15" gate="G$1" pin="B-12"/>
<wire x1="121.92" y1="63.5" x2="129.54" y2="63.5" width="0.1524" layer="91"/>
</segment>
</net>
</nets>
</sheet>
</sheets>
</schematic>
</drawing>
</eagle>
