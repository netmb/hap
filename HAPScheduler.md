# HAP-Scheduler #

Der HAP- Scheduler ermöglicht das Setzen oder Abfragen von einzelnen Datenwerten als Cron-Job.

Hier ein Bespiele, bei dem jeweils alle 15Minuten die 3 Werte abfragt werden.

![http://hap.googlecode.com/svn/wiki/images/Scheduler.png](http://hap.googlecode.com/svn/wiki/images/Scheduler.png)


'''Cron'''        : Eingabe wie bei jedem Cron-Job [Wiki CronJob](http://de.wikipedia.org/wiki/Cronjob)


'''Command''': hap-sendcommand für Setzen oder Abfragen von Werten


'''Argument''':

Wert abfragen :   -c "destination MODUL\_ADDRESS query device ADDRESS"

Wert schreiben:   -c "destination MODUL\_ADDRESS set device ADDRESS value VALUE"

MODUL\_ADDRESS: CU Modul Adresse

ADDRESS: Adresse der jeweiligen Komponente