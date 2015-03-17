# Introduction #

Email bei Multicast verschicken

# Details #
Der User ist hap und es soll bei Eingang eines Multicast 247 eine Email versandt werden. Die Einrichtung von emailx ist sehr gut unter:
Howto Emailx - Postfix
erklärt. Die folgende Datei ist das Perl-Script zum ausführen des Bash-Scripts, um die eigentliche Email zu versenden.
```
#!/usr/bin/perl -w

# MulticastAlert.pl
# Eingangsparameter: 
# Destination: $ARGV[0]
# Source:      $ARGV[1]
# Device:      $ARGV[2]
# Value:       $ARGV[3]
#
# Beispiel:

if ($ARGV[0] == 247) { 
system("bash sendmail");
}
```
Rechte der Dateien:
-rwxr-xr-x 1 hap hap sendmail
-rwxr-xr-x 1 hap hap MulticastAlert.pl

Das folgende Bash Script wird in der Perldatei ausgeführt, um die email zu versenden
```
#!/bin/bash
# Sendmail

mailx -s "Email kommt an" aaa@bbb.de  < test.txt
```