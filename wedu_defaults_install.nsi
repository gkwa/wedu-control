!include "WinMessages.nsh"
!include LogicLib.nsh
!include FileFunc.nsh
!include MUI2.NSH
!include WordFunc.nsh

Name "${name}"
OutFile "${outfile}"

XPStyle on
ShowInstDetails show
ShowUninstDetails show
RequestExecutionLevel admin
Caption "Streambox $(^Name) Installer"

# use this as installdir
InstallDir '$PROGRAMFILES\Streambox\${name}'
#...butif this reg key exists, use this installdir instead of the above line
InstallDirRegKey HKLM 'Software\Streambox\${name}' InstallDir

VIAddVersionKey ProductName "${name}"
VIAddVersionKey FileDescription ""
VIAddVersionKey Language "English"
VIAddVersionKey LegalCopyright ""
VIAddVersionKey CompanyName ""
VIAddVersionKey ProductVersion "${version}"
VIAddVersionKey FileVersion "${version}"
VIProductVersion "${version}"

;--------------------------------
; docs
# http://nsis.sourceforge.net/Docs
# http://nsis.sourceforge.net/Macro_vs_Function
# http://nsis.sourceforge.net/Adding_custom_installer_pages
# http://nsis.sourceforge.net/ConfigWrite
# loops
# http://nsis.sourceforge.net/Docs/Chapter2.html#\2.3.6

;--------------------------------
Var sysdrive
var debug

;--------------------------------
;Interface Configuration

# !define MUI_WELCOMEPAGE_TITLE "Welcome to the Streambox setup wizard."
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
# !define MUI_HEADERIMAGE_BITMAP ${NSISDIR}\Graphics\sblogo.bmp
# !define MUI_WELCOMEFINISHPAGE_BITMAP ${NSISDIR}\Graphics\sbside.bmp
# !define MUI_UNWELCOMEFINISHPAGE_BITMAP ${NSISDIR}\Graphics\sbside.bmp
!define MUI_ABORTWARNING
!define MUI_ICON Olympics-2014-Sochi-Official-Alpine-Skiing.ico

;--------------------------------
;Pages

!insertmacro MUI_PAGE_INSTFILES # this macro is the macro that invokes the Sections

;--------------------------------
; Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Functions

Function .onInit
	StrCpy $sysdrive $WINDIR 1

	SetAutoClose true
	##############################
	# did we call with "/debug"
	StrCpy $debug 0
	${GetParameters} $0
	ClearErrors
	${GetOptions} $0 '/debug' $1
	${IfNot} ${Errors}
		StrCpy $debug 1
		SetAutoClose false #leave installer window open when /debug
	${EndIf}
	ClearErrors

FunctionEnd

Section section_show_banner_if_no_prereq

	${IfNot} ${FileExists} '$PROGRAMFILES32\Windows Embedded Standard 7\DSSP1'
	${AndIfNot} ${FileExists} '$PROGRAMFILES32\Windows Embedded Standard 7\DS64SP1'

		Banner::show /set 76 "Checking for Standard 7 SP1 Toolkit.iso..." "Please install that first"
		Banner::getWindow
		Pop $R1
		Sleep 4000
		Banner::destroy
		Quit

	${EndIf}

SectionEnd

Section section1 section_payload

	##############################
	# Download and install WEDU.msi - Windows Embedded Devloper Update
	# http://www.microsoft.com/en-us/download/details.aspx?id=23004
	##############################
	SetOutPath $TEMP\${name}
	DetailPrint 'Downloading WEDU.msi...'
	nsExec::ExecToLog 'powershell -NoProfile -inputformat none -executionpolicy bypass -command "(new-object System.Net.WebClient).DownloadFile($\'http://download.microsoft.com/download/8/5/4/854F176A-5C4A-4918-AA49-DFC5847BE34F/WEDU.msi$\',$\'WEDU.msi$\')"'
	DetailPrint 'Installing WEDU.msi...'
	nsExec::ExecToLog 'msiexec /I WEDU.msi /qn /L*v "$TEMP\wedu_install.log"'

	##############################
	SetOutPath $LOCALAPPDATA\Microsoft\WEDU\956cee85-997f-4aaf-aefe-34c9dd317fba

	FileOpen $R1 Targets.xml w

	FileWrite $R1 '<?xml version="1.0" encoding="utf-8"?>'
	FileWrite $R1 '$\r$\n'

	FileWrite $R1 '<Targets>'
	FileWrite $R1 '$\r$\n'

	${If} ${FileExists} '$PROGRAMFILES32\Windows Embedded Standard 7\DSSP1'
		File EEF1B74C_history.xml
		FileWrite $R1 '<Target Hash="EEF1B74C" Name="DSSP1" TargetLocation="$PROGRAMFILES32\Windows Embedded Standard 7\DSSP1" />'
		FileWrite $R1 '$\r$\n'
	${EndIf}

	${If} ${FileExists} '$PROGRAMFILES32\Windows Embedded Standard 7\DS64SP1'
		File 40C4C298_history.xml
		FileWrite $R1 '<Target Hash="40C4C298" Name="DS64SP1" TargetLocation="$PROGRAMFILES32\Windows Embedded Standard 7\DS64SP1" />'
		FileWrite $R1 '$\r$\n'
	${EndIf}

	FileWrite $R1 '</Targets>'
	FileWrite $R1 '$\r$\n'
	FileClose $R1
	##############################

SectionEnd

;--------------------------------
; this must remain after the Section definitions

# Emacs vars
# Local Variables: ***
# comment-column:0 ***
# tab-width: 2 ***
# comment-start:"# " ***
# End: ***
