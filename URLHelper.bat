@ECHO OFF

:: Mise en place d'un gestionnaire d'URL compatible avec UltraVNC sous Windows.
:: Voir : https://vanclercq.me/blog/permalink/12.html

:: Initialisation et remise � z�ro des param�tres utilis�s durant l'ex�cution du script.
SET host=
SET password=
SET params=


:: Aucun param�tre n'a �t� pass� au script, il ne sert � rien de poursuivre son ex�cution.
IF "%1" == "" (
	ECHO Param�tre manquant, arr�t de l'ex�cution...
	EXIT
)


:: R�cup�ration de l'ensemble des param�tres pass�s au script et suppression du premier, 
::  il s'agit de la cha�ne de connexion et sera d�s lors tra�t�e diff�remment des autres.
:: Suppression des espaces entourant la cha�ne (trim)
SET params=%*
CALL SET params=%%params:%1=%%%
FOR /f "tokens=* delims= " %%a IN ("%params%") DO SET params=%%a


:: Aucun param�tre n'a �t� pass�, il semble alors judicieux de donner quelques param�tres 
::  par d�faut (reconnexion automatique, masquage des barres d'outils, etc).
IF "%params%" == "" (SET params=-autoreconnect 15 -keepalive 120 -askexit -nostatus -notoolbar -shared -normalcursor -autoscaling)


:: R�cup�ration du param�tre pass� au script (quelque chose comme : vnc://password@hote), 
::  puis suppression du protocole du d�but de la cha�ne ("vnc://") ainsi que de la barre 
::  oblique � la fin de celle-ci si elle est pr�sente (ins�r�e par le navigateur ?).
SET str=%1
SET str=%str:vnc://=%
SET str=%str:/=%


:: S�paration de la cha�ne selon l'arobase pour obtenir l'h�te (le dernier �l�ment qui a 
::  �t� r�cup�r�) puis l'utilisateur et le mot de passe, s'ils existes (en soustrayant 
::  l'h�te de la cha�ne originale afin de pr�server d'�ventuelles autres arobases dans le 
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


:: Envoi des param�tres � l'ex�cutable de VNC Viewer (il serait temps) selon qu'un mot de 
::  passe ait �t� indiqu� ou non, et sortie du script.
IF "%password%" == "" (
	START "" "%~dp0\vncviewer.exe" -connect %host% %params%
) ELSE IF "%user%" == "" (
	START "" "%~dp0\vncviewer.exe" -connect %host% -password %password% %params%
) ELSE (
	START "" "%~dp0\vncviewer.exe" -connect %host% -user %user% -password %password% %params%
)
EXIT