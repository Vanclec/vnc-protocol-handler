@ECHO OFF

:: Mise en place d'un gestionnaire d'URL compatible avec UltraVNC sous Windows.
:: Voir : https://vanclercq.me/blog/permalink/12.html

:: Initialisation et remise … z‚ro des paramŠtres utilis‚s durant l'ex‚cution du script.
set host=
set password=
set params=


:: Aucun paramŠtre n'a ‚t‚ pass‚ au script, il ne sert … rien de poursuivre son ex‚cution.
IF "%1" == "" (
	ECHO ParamŠtre manquant, arrˆt de l'ex‚cution...
	EXIT
)


:: R‚cup‚ration de l'ensemble des paramŠtres pass‚s au script et suppression du premier, 
::  il s'agit de la chaŒne de connexion et sera dŠs lors traŒt‚ diff‚remment des autres.
:: Suppression des espaces entourant la chaŒne (trim)
SET params=%*
CALL SET params=%%params:%1=%%%
FOR /f "tokens=* delims= " %%a in ("%params%") do set params=%%a


:: Aucun paramŠtre n'a ‚t‚ pass‚, il semble alors judicieux de donner quelques paramŠtres 
::  par d‚faut (reconnexion automatique, masquage des barres d'outils, etc).
IF "%params%" == "" (SET params=-autoreconnect 15 -keepalive 120 -askexit -nostatus -notoolbar -shared -normalcursor -autoscaling)


:: R‚cup‚ration du paramŠtre pass‚ au script (quelque chose comme : vnc://password@hote), 
::  puis suppression du protocole du d‚but de la chaŒne ("vnc://") ainsi que de la barre 
::  oblique … la fin de celle-ci si elle est pr‚sente (ins‚r‚e par le navigateur ?).
SET str=%1
SET str=%str:vnc://=%
SET str=%str:/=%


:: S‚paration de la chaŒne selon l'arobase pour obtenir l'h“te (le dernier ‚l‚ment qui a 
::  ‚t‚ r‚cup‚r‚) puis le mot de passe, s'il existe (en soustrayant l'h“te de la chaŒne 
::  originale afin de pr‚server d'‚ventuelles autres arobases dans le mot de passe).
FOR %%A IN (%str:@= %) DO set host=%%A
CALL SET password=%%str:@%host%=%%


:: Envoi des paramŠtres … l'ex‚cutable de VNC Viewer (il serait temps) selon qu'un mot de 
::  passe ait ‚t‚ indiqu‚ ou non, et sortie du script.
IF "%password%" == "" (
	START "" "%~dp0\vncviewer.exe" -connect %host% %params%
) ELSE (
	START "" "%~dp0\vncviewer.exe" -connect %host% -password %password% %params%
)
EXIT