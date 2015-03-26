# Introduction #

Es soll bei Eingang eines Multicast 247 eine E-Mail versandt werden.

# Details #
Der User ist hap und die Einrichtung von emailx ist sehr gut unter

http://wiki.ubuntuusers.de/postfix

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
Das folgende Bash Script wird in der Perldatei ausgeführt, um die email zu versenden

#!/bin/bash
# Sendmail
```
mailx -s "Email kommt an" aaa@bbb.de  < test.txt
```
Weitere Einstellungen, damit es keine Probleme mit Providern wie GMX gibt und leerem Absender:


Im Ordner /etc/postfix

Main.cf

```
# See /usr/share/postfix/main.cf.dist for a commented, more complete version


# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtp_tls_security_level = may


# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

myhostname = xxxxx
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination = xxxx , localhost.localdomain, localhost
relayhost = mail.gmx.net
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 51200000
recipient_delimiter = +
inet_interfaces = loopback-only
inet_protocols = all

smtp_sender_dependent_authentication = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_connection_cache_on_demand = no
smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
sender_dependent_relayhost_maps = hash:/etc/postfix/sender_dependent
sender_canonical_maps = hash:/etc/postfix/sender_canonical
smtp_generic_maps = regexp:/etc/postfix/generic

# smtp_sasl_auth_enable = yes
# noplaintext weglassen, wenn Passwörter im Klartext übertragen werden müssen:
# (nicht empfohlen, nur wenn's anders nicht funktioniert)
#smtp_sasl_security_options = noanonymous
#smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
#sender_canonical_maps = hash:/etc/postfix/sender_canonical

```

sasl\_password
```
mail.gmx.net email@gmx.de:password
```

sender\_dependent

```
email@gmx.de mail.gmx.net
```

generic
```
/(.)*/ email@gmx.de
```
sender\_canonical
```
hap email@gmx.de
root email@gmx.de
```

Im Ordner /etc

aliases
```
postmaster:    email@gmx.de
root:	email@gmx.de
hap: email@gmx.de
```


mailname
```
email@gmx.de
```

Um das ganze zu laden:sudo chmod 600 /etc/postfix/sasl_password 
sudo postmap /etc/postfix/sender_canonical
sudo postmap /etc/postfix/generic
sudo postmap /etc/aliases
sudo postmap /etc/mailname
sudo postmap /etc/postfix/sender_dependent
sudo postmap hash:/etc/postfix/sasl_password 
sudo /etc/init.d/postfix restart ```