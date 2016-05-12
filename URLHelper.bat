@ECHO OFF

:: Mise en place d'un gestionnaire d'URL compatible avec UltraVNC sous Windows.
:: Voir : https://vanclercq.me/blog/permalink/12.html

:: Initialisation et remise à zéro des paramètres utilisés durant l'exécution du script.
SET host=
SET password=
SET params=


:: Aucun paramètre n'a été passé au script, il ne sert à rien de poursuivre son exécution.
IF "%1" == "" (
	ECHO ParamŠtre manquant, arrˆt de l'ex‚cution...
	EXIT
)


:: Récupération de l'ensemble des paramètres passés au script et suppression du premier, 
::  il s'agit de la chaîne de connexion et sera dès lors traîtée différemment des autres.
:: Suppression des espaces entourant la chaîne (trim)
SET params=%*
CALL SET params=%%params:%1=%%%
FOR /f "tokens=* delims= " %%a IN ("%params%") DO SET params=%%a


:: Aucun paramètre n'a été passé, il semble alors judicieux de donner quelques paramètres 
::  par défaut (reconnexion automatique, masquage des barres d'outils, etc).
IF "%params%" == "" (SET params=-autoreconnect 15 -keepalive 120 -askexit -nostatus -notoolbar -shared -normalcursor -autoscaling)


:: Récupération du paramètre passé au script (quelque chose comme : vnc://password@hote), 
::  puis suppression du protocole du début de la chaîne ("vnc://") ainsi que de la barre 
::  oblique à la fin de celle-ci si elle est présente (insérée par le navigateur ?).
SET str=%1
SET str=%str:vnc://=%
SET str=%str:/=%


:: Séparation de la chaîne selon l'arobase pour obtenir l'hôte (le dernier élément qui a 
::  été récupéré) puis l'utilisateur et le mot de passe, s'ils existes (en soustrayant 
::  l'hôte de la chaîne originale afin de préserver d'éventuelles autres arobases dans le 
::  mot de passe).
FOR %%A IN (%str:@= %) DO set host=%%A
CALL SET str=%%str:@%host%=%%
FOR /f "tokens=1,2 delims=:" %%a in ("%str%") DO (
	IF "%%a" == "%str%" (
		SET user=
		SET password=
	) ELSE IF NOT "%%b" == "" (
		SET user=%%a
		SET password=%%b
	) ELSE (
		SET user=
		SET password=%%a
	)
)


:: Envoi des paramètres à l'exécutable de VNC Viewer (il serait temps) selon qu'un mot de 
::  passe ait été indiqué ou non, et sortie du script.
IF "%password%" == "" (
	START "" "%~dp0\vncviewer.exe" -connect %host% %params%
) ELSE IF "%user%" == "" (
	START "" "%~dp0\vncviewer.exe" -connect %host% -password %password% %params%
) ELSE (
	START "" "%~dp0\vncviewer.exe" -connect %host% -user %user% -password %password% %params%
)
EXIT