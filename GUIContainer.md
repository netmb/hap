Also neue Funktion in HAP gibt es jetzt einen Container, der es ermöglicht, weitere HTML Inhalte innerhalb der HAP Weboberfläche zu integrieren.

Damit können bspw. Videostreams oder ansonsten nicht in HAP verfügbare Daten vom Server eingebunden werden. Parallel sind noch Uhrzeit oder Wetter interessant aber JAVA schein noch nicht zu klappen.

**Bespiele:**

# Integration eines Videostreams #

**Zunächst muss über den Object Explorer das Symbol "Container" in die GUI gewegt werden.** Inner-HTML ist der eigentlich Ort zum einfügen des HTML Codes.

```
<p>Video stream IP-front cam</p>
<embed height="240" width="320"
flashvars="height=240&width=320&file=http://192.168.xx.xx/video.mjpg&searchbar=false&showicons=false"                 
allowfullscreen="true" allowscriptaccess="always"
src="http://192.168.xx.xx/video.mjpg"></embed>                     
</body></html>
```

# Integration Uhrzeit #

```
<!DOCTYPE html>
<html>
<head>
<script>
function readTime()
{
var timenow=new Date();
var h=timenow.getHours();
var m=timenow.getMinutes();
var s=timenow.getSeconds();
m=checkdigit(m);
s=checkdigit(s);
document.getElementById('txt').innerHTML=h+":"+m+":"+s;
t=setTimeout(function(){readTime()},500);
}

function checkdigit(i)
{
	if (i<10)
  	{
	i="0" + i;
	}
	return i;
}
</script>
</head>

<body onload="readTime()">
<div id="txt"></div>
</body>
</html>
```
JAVA scheint aber noch nicht zu funktionieren...

# Integration Wettter #

Sofern die HAP Oberfläche im Flur auf nem Tablett läuft, will man es meistens für mehr nutzen und so kann auch einfach bspw. das aktuelle Wetter eingebunden werden.

Einfache HTML Generierung findet man bspw. unter http://www.wetter.com/apps_und_mehr/website/wetterbutton/.

JAVA scheint aber noch nicht zu funktionieren...