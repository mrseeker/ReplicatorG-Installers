
;--------------------------------

!include nsDialogs.nsh
!include LogicLib.nsh
!include x64.nsh

; The name of the installer
Name "ReplicatorG 0033 Installer"

; The file to write
OutFile "ReplicatorG-0033-Install.exe"

; The default installation directory
InstallDir $DOCUMENTS\ReplicatorG

; Request application privileges for Windows Vista
RequestExecutionLevel highest

ShowInstDetails show

Var pythonDialog
Var pythonCheckText
Var pythonCheckAskText
Var pythonCheckFoundText
Var pythonCheckDownloadButton
Var congratuWellDone
Var congratuWellDoneText

;--------------------------------

; Pages

Page directory
Page custom pythonCheckPage
Page instfiles
Page custom congratulationsPage

;--------------------------------

Function pythonCheckPage
	
	nsDialogs::Create 1018
	Pop $pythonDialog
	
	${If} pythonDialog == error
		Abort
	${EndIf}
	
	${NSD_CreateLabel} 0 0 100% 12u "Checking for Python..."
	Pop $pythonCheckText
	
#CheckPythonPath:
	ExpandEnvStrings $0 "%PYTHONPATH%"
	StrCmp $0 "%PYTHONPATH%" CheckPythonSearch HasPython
CheckPythonSearch:
	SearchPath $0 "python.exe"
	StrCmp $0 "" ChekPythonDefault HasPython
ChekPythonDefault:
	IfFileExists "C:\Python*\*.*" HasPython
#NoPython:
	${NSD_CreateLabel} 0 13u 100% 52u \
	"It looks like you don't have Python. \
	Python is needed for Skeinforge (our slicing engine) to run.$\n\
	If you already have Python, or don't wish to download it now, \
	you can set the path to it in ReplicatorG's preferences. $\n\
	You can download Python now using the button below.$\n\
	Click 'Install' to install ReplicatorG without getting Python."
	Pop $pythonCheckAskText
	
	${NSD_CreateButton} 20% 65u 60% 12u "Open python download page in browser."
	Pop $pythonCheckDownloadButton
	${NSD_OnClick} $pythonCheckDownloadButton getPython
	
	Goto End
  
HasPython:
	${NSD_CreateLabel} 0 13u 100% 12u "Python found!"
	Pop $pythonCheckFoundText
	
End:
	Nop
	

	nsDialogs::Show
	
FunctionEnd

Function getPython
	ExecShell "open" "http://www.python.org/download/"
FunctionEnd

Function congratulationsPage

	nsDialogs::Create 1018
	Pop $congratuWellDone
	
	${If} congratuWellDone == error
		Abort
	${EndIf}
	
	${NSD_CreateLabel} 0 0 100% 50u \
	"Congratuwelldone!$\nYou've installed ReplicatorG!$\n$\n\
	Don't forget to visit Thingiverse.com"
	Pop $congratuWellDoneText
		
FunctionEnd

;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r "..\dist-all\windows\replicatorg-*"
  
  ; Set output path to the driver directory.
  SetOutPath "$INSTDIR\drivers\"
  File "drivers\"
  File /r "drivers\FTDI USB Drivers\"
  File /r "drivers\Arduino Mega 2560 usbser Driver\"
  File /r "drivers\Makerbot\"
  
  ${If} ${RunningX64}
    ExecWait '"$INSTDIR\drivers\dpinst64.exe" /lm'
  ${Else}
    ExecWait '"$INSTDIR\drivers\dpinst32.exe" /lm'
  ${EndIf}
  
SectionEnd ; end the section

;;; From http://nsis.sourceforge.net/Shortcuts_removal_fails_on_Windows_Vista 
Section Shortcuts ; shortcut generation

  ;Set output path to the installation directory.
  SetOutPath "$INSTDIR\replicatorg-0033"
  # create a shortcut in the start menu programs directory
  # point the new shortcut at the program
  Delete "$SMPROGRAMS\ReplicatorG.lnk"
  createShortCut "$SMPROGRAMS\ReplicatorG.lnk" "$INSTDIR\replicatorg-0033\ReplicatorG.exe"
  ;WriteUninstaller replicatorg-0033-unist.exe

SectionEnd

;Section uninstall
;  SetShellVarContext all
;  RMDir "$INSTDIR\."
;  RMDir "$DOCUMENTS\.replicatorg"
;  Delete "$SMPROGRAMS\ReplicatorG.lnk"
;SectionEnd
