Unter Umständen kann es hinderlich sein, jedesmal die Login-Daten für die Web-GUI eingeben zu müssen (z.B. auf einem Handy).

Dies kann umgangen werden, indem folgende URL aufgerufen wird:

`http://ihr-server:8090/login/checkGui?user=IhrLogin&pass=IhrPasswort`

Achtung: Diese Art des Logins ist natürlich unsicher und es sollte immer darauf geachtet werden, dass die Browser-History gelöscht wird, falls das Gerät auch von anderen Personen verwendet wird.

Es lassen sich über die URL auch direkt Scenes und Views anspringen:

Die Scene 100 in der View 12 der Config 4711 anspringen:

`http://ihr-server:8090/login/checkGui/4711/12/100?...`

Die View 12 in der Config 4711 anspringen:

`http://ihr-server:8090/login/checkGui/4711/12?user...`

Einziges Problem hierbei:
Die IDs muss man sich aus der Datenbank fischen.


---


Einfacher Login auf die Default Seite:

Wenn ihr in eurem Backup `*.sql` nach der Default Scene (hier "Meine\_Startseite") sucht findet ihr sowas:

`(133,18,1,NULL,NULL,'Meine_Startseite',133)`

---> `http://ihr-server:8090login/checkGui/133/18?user=xxxx&pass=xxxx`