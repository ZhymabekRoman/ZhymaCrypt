; Source: https://www.autoitscript.com/forum/topic/196406-cryptodragon-obfuscator-v1401/
; WITH SOME MODIFICATIONS! SEE 260 and 613 LINE THERE !?!?!?!?!
;
; Title: CryptoDragon AutoIt Obfuscator
; Version: v1.4.0.1
; Requirements: AutoIt Version 3.1.1.0 (Beta is NOT required)
; Date: November 6th, 2018
; Authors: Freak, taurus905
; Purpose: This script obfuscates an AutoIt script by identifying, counting and replacing all
;          variables and functions within that script, as well as encrypting strings. according to the following notes.
; Notes: Variables that are all UPPERCASE, such as, $GUI_EVENT_CLOSE, will not be obfuscated.
;        All strings with single and double quotes are to be encrypted with a multikey XOR algo. (in order)
;        Add arguments in the "Functions_NOT_to_obfuscate_section:" to bypass these functions.
;        Uncomment: (in the script)
;             Global $Show_Messages = "Yes"
;                  to show Message Boxes and Array Displays during execution.
; Input:            An AutoIt Script --> OriginalScriptName.au3
; Output: Variables to be Obfuscated --> OriginalScriptName - Vars to Obfuscate.txt
;         Functions to be Obfuscated --> OriginalScriptName - Funcs to Obfuscate.txt
;                       Random Names --> OriginalScriptName - Random Names.txt
;           CryptoDragon Obfuscated Script --> OriginalScriptName - CryptoDragon Obfuscated.au3
; Modified by Freak to encrypt all strings in target program with multichar XOR, also added bug fixes.
; :::ChAnGeLoG::::
;  v1.2     - Original "Simple Obfuscator" by taurus905
;  v1.3     - Freak creates CryptoDragon project based off taurus905's "Simple Obfuscator"
;  v1.3.4   - Added improved speed
;  v1.3.5.1 - Improved functionality
;  v1.3.6   - Added string length to _CryptoDragon_Crypt function for improved stability handling funny strings in version
;  v1.4     - Improved security on encryption algorythm. Also obfuscator automatically writes encryption function to top of file automatically.
;  v1.4.0.1 - Fixed encrypt function writing process.
; ===================================================================================================
#include <GUIConstants.au3>
#include <Array.au3>
Func _CryptoDragon_Crypt($s_String, $s_Key, $iLen, $xorK2 = 0x12, $s_Level = 1.337)
    Local $s_Encrypted = "", $fin_Encrypted = "", $s_kc = 1
    If StringLen($s_Key) = 0 Or $s_Level < 1 Then Return 0
    $s_Key = StringSplit($s_Key, '')
    $s_String = StringSplit($s_String, '')
    For $x = 1 To $s_String[0]
        If $s_kc > $s_Key[0] Then $s_kc = 1
        $s_Encrypted = $s_Key[$s_kc]
        $s_Encrypted += Floor(Asc($s_Key[$s_kc]) * $s_Level);
        $s_Encrypted = BitNOT($s_Encrypted);
        $s_Encrypted = BitXOR($s_Encrypted, Floor(Asc($s_Key[$s_kc]) * $s_Level));
        $s_Encrypted += Floor(Asc($s_Key[$s_kc]) * $s_Level);
        $s_Encrypted -= Floor(Asc($s_Key[$s_kc]) * $s_Level);
        $s_Encrypted = BitXOR($s_Encrypted, Floor(Asc($s_Key[$s_kc]) * $s_Level));
        $s_Encrypted = $s_Encrypted - 1;
        $s_Encrypted = BitXOR($s_Encrypted, Floor(Asc($s_Key[$s_kc]) * $s_Level));
        $s_Encrypted = $s_Encrypted + 1;
        $s_Encrypted += Floor(Asc($s_Key[$s_kc]) * $s_Level);
        $s_Encrypted = BitXOR($s_Encrypted, $xorK2);
        $s_Encrypted = BitNOT($s_Encrypted);
        $s_Encrypted += Floor(Asc($s_Key[$s_kc]) * $s_Level);
        $fin_Encrypted &= Chr(BitXOR(Asc($s_String[$x]), Floor(Asc($s_Key[$s_kc]) * $s_Level)))
        $s_kc += 1
    Next
    Return StringLeft($fin_Encrypted, $iLen)
EndFunc   ;==>_CryptoDragon_Crypt
Global $Show_Messages = "No"
; Uncomment the following line to see progress messages and arrays during execution.
;Global $Show_Messages = "Yes"
; ===================================================================================================

Global $file_Script_to_Obfuscate
_Choose_Script_to_Obfuscate() ; Choose Script to Obfuscate

; ===================================================================================================
; Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines

Global $Num_of_Lines
_Count_Lines() ; Count Lines of Script to Obfuscate
If $Show_Messages = "Yes" Then MsgBox(0, "$Num_of_Lines", $Num_of_Lines)

Global $Array_of_Lines[$Num_of_Lines + 1]
_Read_Lines_to_Array() ; Read Lines to Array
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Lines, "$Array_of_Lines")

; Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines
; ===================================================================================================
; Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars

Global $Num_of_Vars
_Count_Vars() ; Count Variables in Script to Obfuscate
If $Show_Messages = "Yes" Then MsgBox(0, "$Num_of_Vars", $Num_of_Vars)

Global $Array_of_Vars[$Num_of_Vars + 1]
_Read_Vars_to_Array() ; Read Variables to Array
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Vars, "$Array_of_Vars")

_Sort_Array_of_Vars() ; Sort Array of Variables
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Vars, "$Array_of_Vars")

Global $Num_of_Unique_Vars
_Count_Unique_Vars() ; Count Unique Variables
If $Show_Messages = "Yes" Then MsgBox(0, "$Num_of_Unique_Vars", $Num_of_Unique_Vars)

Global $Array_of_Unique_Vars[$Num_of_Unique_Vars + 1]
_Read_Unique_Vars_to_Array() ; Read Unique Variables to Array
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Unique_Vars, "$Array_of_Unique_Vars")

_Write_Unique_Vars_to_File() ; Write Unique Variables to File

; Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars
; ===================================================================================================
; Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs

Global $Num_of_Funcs
_Count_Funcs() ; Count Functions in Script to Obfuscate
If $Show_Messages = "Yes" Then MsgBox(0, "$Num_of_Funcs", $Num_of_Funcs)

Global $Array_of_Funcs[$Num_of_Funcs + 1]
_Read_Funcs_to_Array() ; Read Functions to Array
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Funcs, "$Array_of_Funcs")

_Sort_Array_of_Funcs() ; Sort Array of Functions
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Funcs, "$Array_of_Funcs")

; Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs
; ===================================================================================================
; Random - Random - Random - Random - Random - Random - Random - Random - Random - Random - Random

Global $Num_of_Random_Names
_Find_Random_Name_Count() ; Find Random Name Count

Global $Random_Name[$Num_of_Random_Names + 1]
_Read_Random_Names_to_Array() ; Read Random Names to Array
If $Show_Messages = "Yes" Then _ArrayDisplay($Random_Name, "$Random_Name")

_Write_Random_Names_to_File() ; Write Random Names to File

; Random - Random - Random - Random - Random - Random - Random - Random - Random - Random - Random
; ===================================================================================================
; Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace

Global $New_Array_of_Lines[$Num_of_Lines + 1]
_Remove_Comments() ; Remove Comments
_ArraySortDblDel($Array_of_Unique_Vars)
_ArraySortDblDel($Array_of_Funcs)
$vars_finished = False
$func_finished = False
$Script_Data = _ArrayToString($Array_of_Lines, @CRLF)
For $iii = 0 To $Num_of_Lines
    For $jjj = UBound($Array_of_Unique_Vars) - 1 To 1 Step -1
        If $vars_finished Then ExitLoop
        If $Array_of_Unique_Vars[$jjj] <> $Array_of_Unique_Vars[1] Then
            If $Array_of_Unique_Vars[$jjj] <> "_" And $Array_of_Unique_Vars[$jjj] <> "$'" And StringLower($Array_of_Unique_Vars[$jjj]) <> "$cmdline" Then
                If StringInStr($Array_of_Unique_Vars[$jjj], ".") Then
                    $temp = StringSplit($Array_of_Unique_Vars[$jjj], ".")
                    $Array_of_Unique_Vars[$jjj] = $temp[1]
                EndIf
                If StringRight($Array_of_Unique_Vars[$jjj], 1) = "&" Then
                    $Array_of_Unique_Vars[$jjj] = StringTrimRight($Array_of_Unique_Vars[$jjj], 1)
                EndIf
                $Script_Data = StringReplace($Script_Data, $Array_of_Unique_Vars[$jjj], "$" & $Random_Name[$jjj])
                ConsoleWrite($Array_of_Unique_Vars[$jjj] & ":$" & $Random_Name[$jjj] & @CRLF)
            EndIf
        Else
            If $Array_of_Unique_Vars[$jjj] <> "_" And $Array_of_Unique_Vars[$jjj] <> "$'" Then
                If StringInStr($Array_of_Unique_Vars[$jjj], ".") Then
                    $temp = StringSplit($Array_of_Unique_Vars[$jjj], ".")
                    $Array_of_Unique_Vars[$jjj] = $temp[1]
                EndIf
                If StringRight($Array_of_Unique_Vars[$jjj], 1) = "&" Then
                    $Array_of_Unique_Vars[$jjj] = StringTrimRight($Array_of_Unique_Vars[$jjj], 1)
                EndIf
                $Script_Data = StringReplace($Script_Data, $Array_of_Unique_Vars[$jjj], "$" & $Random_Name[$jjj])
                ConsoleWrite($Array_of_Unique_Vars[$jjj] & ":$" & $Random_Name[$jjj] & @CRLF)
            EndIf
            $vars_finished = True
        EndIf
    Next
Next
For $iii = 0 To $Num_of_Lines
    For $jjj = UBound($Array_of_Funcs) - 1 To 1 Step -1
;       If StringLeft($Array_of_Funcs[$jjj], 1) = "_" Then ContinueLoop
        If $func_finished Then ExitLoop
        If $Array_of_Funcs[$jjj] <> $Array_of_Funcs[1] Then
            If StringInStr($Array_of_Funcs[$jjj], "=") Then ContinueLoop ; Au3wrapper, not a function.
            $Script_Data = StringReplace($Script_Data, $Array_of_Funcs[$jjj], $Random_Name[$jjj])
            ConsoleWrite($Array_of_Funcs[$jjj] & ":" & $Random_Name[$jjj] & @CRLF)
        Else
            If StringInStr($Array_of_Funcs[$jjj], "=") Then
                $func_finished = True
                ContinueLoop ; Au3wrapper, not a function.
            EndIf
            $Script_Data = StringReplace($Script_Data, $Array_of_Funcs[$jjj], $Random_Name[$jjj])
            ConsoleWrite($Array_of_Funcs[$jjj] & ":" & $Random_Name[$jjj] & @CRLF)
            $func_finished = True
        EndIf
    Next
Next
If $Show_Messages = "Yes" Then _ArrayDisplay($Array_of_Lines, "$New_Array_of_Lines")

; Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace
; ===================================================================================================

_Write_CryptoDragon_Obfuscated_File($Script_Data) ; Write CryptoDragon Obfuscated Script
Exit
Func _ArraySortDblDel(ByRef $ARRAY, $CASESENS=0, $iDESCENDING=0, $iDIM=0, $iSORT=0)
    Local $arTmp1D[1], $arTmp2D[1][2], $dbl = 0
    $arTmp1D[0] = ""
    $arTmp2D[0][0] = ""
    If $iDIM = 0 Then $iDIM = 1
    _ArraySort($ARRAY,$iDESCENDING,0,0,$iDIM,$iSORT)
    Switch $iDIM
        Case 1 ; 1D
            For $i = 0 To UBound($ARRAY)-1
                $dbl = 0
                For $k = 0 To UBound($arTmp1D)-1
                    Switch $CASESENS
                        Case 0
                            If $arTmp1D[$k] = $ARRAY[$i] Then $dbl = 1
                        Case 1
                            If $arTmp1D[$k] == $ARRAY[$i] Then $dbl = 1
                    EndSwitch
                Next
                If $dbl = 0 Then
                    If $arTmp1D[0] = "" Then
                        $arTmp1D[0] = $ARRAY[$i]
                    Else
                        _ArrayAdd($arTmp1D, $ARRAY[$i])
                    EndIf
                Else
                    $dbl = 0
                EndIf
            Next
            $ARRAY = $arTmp1D
        Case 2 ; 2D
            For $i = 0 To UBound($ARRAY)-1
                $dbl = 0
                For $k = 0 To UBound($arTmp2D)-1
                    Switch $CASESENS
                        Case 0
                            If  ( $arTmp2D[$k][0] = $ARRAY[$i][0] ) And _
                                ( $arTmp2D[$k][1] = $ARRAY[$i][1] ) Then $dbl = 1
                        Case 1
                            If  ( $arTmp2D[$k][0] == $ARRAY[$i][0] ) And _
                                ( $arTmp2D[$k][1] == $ARRAY[$i][1] ) Then $dbl = 1
                    EndSwitch
                Next
                If $dbl = 0 Then
                    If $arTmp2D[0][0] = "" Then
                        $arTmp2D[0][0] = $ARRAY[$i][0]
                        $arTmp2D[0][1] = $ARRAY[$i][1]
                    Else
                        ReDim $arTmp2D[UBound($arTmp2D)+1][2]
                        $arTmp2D[UBound($arTmp2D)-1][0] = $ARRAY[$i][0]
                        $arTmp2D[UBound($arTmp2D)-1][1] = $ARRAY[$i][1]
                    EndIf
                Else
                    $dbl = 0
                EndIf
            Next
            $ARRAY = $arTmp2D
    EndSwitch
EndFunc ; ==>_ArraySortDblDel
; ###################################################################################################
; ===================================================================================================
Func _Choose_Script_to_Obfuscate() ; Choose Script to Obfuscate
    $file_Script_to_Obfuscate = $cmdline[1]
	;$file_Script_to_Obfuscate = FileOpenDialog("Choose an AutoIt Script to Obfuscate:", @ScriptDir, "Scripts (*.au3)", 1 + 2)
    ;If @error Then Exit
EndFunc ; ==> _Choose_Script_to_Obfuscate
; ===================================================================================================
; Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines
Func _Count_Lines() ; Count Lines of Script to Obfuscate
    FileOpen($file_Script_to_Obfuscate, 0) ; Open File to Obfuscate
    $Num_of_Lines = 0
    While 1
        $Num_of_Lines = $Num_of_Lines + 1
        FileReadLine($file_Script_to_Obfuscate, $Num_of_Lines) ; Read All Lines for Count
        If @error = -1 Then ExitLoop
    WEnd
EndFunc ; ==> _Count_Lines
; ===================================================================================================
Func _Read_Lines_to_Array() ; Read Lines to Array
    For $iii = 1 To $Num_of_Lines
        $Array_of_Lines[$iii] = FileReadLine($file_Script_to_Obfuscate, $iii) ; Read All Lines
    Next
    FileClose($file_Script_to_Obfuscate) ; Close File to Obfuscate
EndFunc ; ==> _Read_Lines_to_Array
; Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines - Lines
; ===================================================================================================
; Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars
Func _Count_Vars() ; Count Variables in Script to Obfuscate
    $Num_of_Vars = 0
    For $iii = 1 To $Num_of_Lines
        Local $quote_on = "No"
        $Array_of_Lines[0] = $Array_of_Lines[$iii]
        Local $line_length = StringLen($Array_of_Lines[0])
        For $jjj = 1 To $line_length
            Local $char = StringLeft($Array_of_Lines[0], 1)
            If $char = Chr(34) And $quote_on = "No" Then
                $quote_on = "Yes"
            ElseIf $char = Chr(34) And $quote_on = "Yes" Then
                $quote_on = "No"
            EndIf
            If $char = ";" And $quote_on = "No" Then ExitLoop
            If $char = "$" And $quote_on = "No" Then $Num_of_Vars = $Num_of_Vars + 1
            $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
        Next
    Next
EndFunc ; ==> _Count_Vars
; ===================================================================================================
Func _Read_Vars_to_Array() ; Read Variables to Array
    Local $var_ct = 0
    For $iii = 1 To $Num_of_Lines
        Local $quote_on = "No"
        $Array_of_Lines[0] = $Array_of_Lines[$iii]
        Local $line_length = StringLen($Array_of_Lines[0])
        For $jjj = 1 To $line_length
            Local $char = StringLeft($Array_of_Lines[0], 1)
            If $char = Chr(34) And $quote_on = "No" Then
                $quote_on = "Yes"
            ElseIf $char = Chr(34) And $quote_on = "Yes" Then
                $quote_on = "No"
            EndIf
            If $char = ";" And $quote_on = "No" Then ExitLoop
            If $char = "$" And $quote_on = "No" Then ; Read One Variable
                $var_ct = $var_ct + 1
                $Array_of_Vars[$var_ct] = ""
                For $kkk = 1 To 256
                    $char = StringLeft($Array_of_Lines[0], 1)
                    If $char = " " Or _
                            $char = "   " Or _
                            $char = "=" Or _
                            $char = "[" Or _
                            $char = "]" Or _
                            $char = "," Or _
                            $char = ")" Or _
                            $char = ";" Or _
                            $char = "+" Or _
                            $char = "-" Or _
                            $char = "*" Or _
                            $char = "/" Or _
                            $char = Chr(34) Then ExitLoop
                    $Array_of_Vars[$var_ct] = $Array_of_Vars[$var_ct] & $char
                    $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
                Next
            EndIf
            $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
        Next
    Next
EndFunc ; ==> _Read_Vars_to_Array
; ===================================================================================================
Func _Sort_Array_of_Vars() ; Sort Array of Variables
    _ArraySortDblDel($Array_of_Vars)
EndFunc ; ==> _Sort_Array_of_Vars
; ===================================================================================================
Func _Count_Unique_Vars() ; Count Unique Variables
    $Num_of_Unique_Vars = 0
    For $iii = 1 To UBound($Array_of_Vars) - 1
        If $Array_of_Vars[$iii] <> $Array_of_Vars[$iii - 1] Then
            If StringIsUpper(StringTrimLeft(StringReplace($Array_of_Vars[$iii], "_", ""), 1)) Then ContinueLoop ; Don't write any system variables that are all UPPERCASE, such as, $GUI_EVENT_CLOSE
            $Num_of_Unique_Vars = $Num_of_Unique_Vars + 1
        EndIf
    Next
EndFunc ; ==> _Count_Unique_Vars
; ===================================================================================================
Func _Read_Unique_Vars_to_Array() ; Read Unique Variables to Array
    Local $var_unique_ct = 0
    For $iii = 1 To UBound($Array_of_Vars) - 1
        If $Array_of_Vars[$iii] <> $Array_of_Vars[$iii - 1] Then
            If StringIsUpper(StringTrimLeft(StringReplace($Array_of_Vars[$iii], "_", ""), 1)) Then ContinueLoop ; Don't read any System Variables that are all UPPERCASE, such as, $GUI_EVENT_CLOSE
            $var_unique_ct = $var_unique_ct + 1
            $Array_of_Unique_Vars[$var_unique_ct] = $Array_of_Vars[$iii]
        EndIf
    Next
EndFunc ; ==> _Read_Unique_Vars_to_Array
; ===================================================================================================
Func _Write_Unique_Vars_to_File() ; Write Unique Variables to File
    Local $file_Unique_Vars = StringTrimRight($file_Script_to_Obfuscate, 4) & " - Vars to Obfuscate.txt" ; Create Unique Variables Filename
    FileOpen($file_Unique_Vars, 2) ; Open File to Write Unique Variables
    For $iii = 1 To $Num_of_Unique_Vars
        FileWrite($file_Unique_Vars, $Array_of_Unique_Vars[$iii] & @CRLF)
    Next
    FileClose($file_Unique_Vars) ; Close Unique Variables File
EndFunc ; ==> _Write_Unique_Vars_to_File
; Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars - Vars
; ===================================================================================================
; Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs
Func _Count_Funcs() ; Count Functions in Script to Obfuscate
    $Num_of_Funcs = 0
    For $iii = 1 To $Num_of_Lines
        Local $quote_on = "No"
        Local $var_on = "No"
        Local $func_on = "No"
        $Array_of_Lines[0] = $Array_of_Lines[$iii]
        Local $line_length = StringLen($Array_of_Lines[0])
        For $jjj = 1 To $line_length
            Local $char = StringLeft($Array_of_Lines[0], 1)
            If $char = "(" Or $char = " " Then $func_on = "No"
            If $char = "$" And $quote_on = "No" Then $var_on = "Yes"
            If $char = "@" And $quote_on = "No" Then $var_on = "Yes"
            If $char = "<" And $quote_on = "No" Then $var_on = "Yes"
            If $char = " " And $quote_on = "No" Then $var_on = "No"
            If $char = Chr(34) And $quote_on = "No" Then
                $quote_on = "Yes"
            ElseIf $char = Chr(34) And $quote_on = "Yes" Then
                $quote_on = "No"
            EndIf
            If $char = ";" And $quote_on = "No" Then ExitLoop
            If $quote_on = "No" And $func_on = "No" And $var_on = "No" Then
                $func_on = "Yes"
                $Num_of_Funcs = $Num_of_Funcs + 1
            EndIf
            $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
        Next
    Next
EndFunc ; ==> _Count_Funcs
; ===================================================================================================
Func _Read_Funcs_to_Array() ; Read Functions to Array
    Local $func_ct = 0
    For $iii = 1 To $Num_of_Lines
        Local $quote_on = "No"
        Local $var_on = "No"
        Local $func_on = "No"
        $Array_of_Lines[0] = $Array_of_Lines[$iii]
        Local $line_length = StringLen($Array_of_Lines[0])
        For $jjj = 1 To $line_length
            Local $char = StringLeft($Array_of_Lines[0], 1)
            If $char = "(" Or $char = " " Then $func_on = "No"
            If $char = "$" And $quote_on = "No" Then $var_on = "Yes"
            If $char = "@" And $quote_on = "No" Then $var_on = "Yes"
            If $char = "<" And $quote_on = "No" Then $var_on = "Yes"
            If $char = " " And $quote_on = "No" Then $var_on = "No"
            If $char = Chr(34) And $quote_on = "No" Then
                $quote_on = "Yes"
            ElseIf $char = Chr(34) And $quote_on = "Yes" Then
                $quote_on = "No"
            EndIf
            If $char = ";" And $quote_on = "No" Then ExitLoop
            If $char = "_" And $quote_on = "No" And $func_on = "No" And $var_on = "No" Then ; Read One Function
                $func_ct = $func_ct + 1
                $Array_of_Funcs[$func_ct] = ""
                For $kkk = 1 To 256
                    $char = StringLeft($Array_of_Lines[0], 1)
                    If $char = " " Or $char = "(" Then ExitLoop
                    $Array_of_Funcs[$func_ct] = $Array_of_Funcs[$func_ct] & $char
                    $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
                Next
                ; Functions_NOT_to_obfuscate_section:
                ; Add functions to the following lines that start with an underscore "_" that you
                ;    do NOT want to be obfuscated. Example:
                ; If $Array_of_Funcs[$func_ct] = "_ArraySortDblDel" Or _
                If $Array_of_Funcs[$func_ct] = "_ArraySortDblDel" Or _
                        $Array_of_Funcs[$func_ct] = "_ArrayDisplay" Or _
                        $Array_of_Funcs[$func_ct] = "_ChooseColor" Or _
                        $Array_of_Funcs[$func_ct] = "_ChooseFont" Or _
                        $Array_of_Funcs[$func_ct] = "_ImageGetSize" Or _
                        $Array_of_Funcs[$func_ct] = "_IsPressed" Or _
                        $Array_of_Funcs[$func_ct] = "_StringEncrypt" Or _
                        $Array_of_Funcs[$func_ct] = "_" Then ; Do NOT Count Built-In Functions
                    $func_ct = $func_ct - 1
                EndIf
            EndIf
            $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
        Next
    Next
EndFunc ; ==> _Read_Funcs_to_Array
; ===================================================================================================
Func _Sort_Array_of_Funcs() ; Sort Array of Functions
    _ArraySortDblDel($Array_of_Funcs)
EndFunc ; ==> _Sort_Array_of_Funcs
; ===================================================================================================
; Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs - Funcs
; ===================================================================================================

Func _Find_Random_Name_Count() ; Find Random Name Count
    If $Num_of_Unique_Vars > $Num_of_Funcs Then
        $Num_of_Random_Names = $Num_of_Vars
    Else
        $Num_of_Random_Names = $Num_of_Funcs
    EndIf
EndFunc ; ==> _Find_Random_Name_Count
; ===================================================================================================
Func _Read_Random_Names_to_Array() ; Read Random Names to Array
    Local $random[16]
    For $iii = 1 To $Num_of_Random_Names
        $Random_Name[$iii] = ""
        For $jjj = 1 To Random(4, 15, 1) ; The number of random characters to use in each random name
            $random[$jjj] = Random(48, 122, 1)
            If $random[$jjj] > 64 And $random[$jjj] < 91 Or $random[$jjj] > 96 And $random[$jjj] < 123 Then
                $Random_Name[$iii] = $Random_Name[$iii] & Chr($random[$jjj])
            Else
                $jjj = $jjj - 1
                ContinueLoop
            EndIf
        Next
    Next
    Return $Random_Name
EndFunc ; ==> _Read_Random_Names_to_Array
; ===================================================================================================
Func _Write_Random_Names_to_File() ; Write Random Names to File
    Local $file_Random_Names = StringTrimRight($file_Script_to_Obfuscate, 4) & " - Random Names.txt" ; Create Random Names Filename
    FileOpen($file_Random_Names, 2) ; Open File to Write Random Names
    For $iii = 1 To $Num_of_Random_Names
        FileWrite($file_Random_Names, $Random_Name[$iii] & @CRLF)
    Next
    FileClose($file_Random_Names) ; Close Random Names File
    Return $Random_Name
EndFunc ; ==> _Write_Random_Names_to_File

; Random - Random - Random - Random - Random - Random - Random - Random - Random - Random - Random
; ===================================================================================================
; Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace

; ===================================================================================================
Func _Remove_Comments() ; Remove Comments
    For $iii = 1 To $Num_of_Lines
        Local $quote_on = "No"
        $Array_of_Lines[0] = $Array_of_Lines[$iii]
        Local $line_length = StringLen($Array_of_Lines[0])
        $New_Array_of_Lines[$iii] = ""
        For $jjj = 1 To $line_length
            Local $char = StringLeft($Array_of_Lines[0], 1)
            If $char = Chr(34) And $quote_on = "No" Then
                $quote_on = "Yes"
            ElseIf $char = Chr(34) And $quote_on = "Yes" Then
                $quote_on = "No"
            EndIf
            If $char = ";" And $quote_on = "No" Then ExitLoop
            $New_Array_of_Lines[$iii] = $New_Array_of_Lines[$iii] & $char
            $Array_of_Lines[0] = StringTrimLeft($Array_of_Lines[0], 1)
        Next
    Next
    Return $New_Array_of_Lines
EndFunc ; ==> _Remove_Comments

; Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace - Replace
; ===================================================================================================
Func _StringBetween($S_STRING, $S_START, $S_END, $V_CASE = -1)
    Local $S_CASE = ""
    If $V_CASE = Default Or $V_CASE = -1 Then $S_CASE = "(?i)"
    Local $S_PATTERN_ESCAPE = "(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)"
    $S_START = StringRegExpReplace($S_START, $S_PATTERN_ESCAPE, "\\$1")
    $S_END = StringRegExpReplace($S_END, $S_PATTERN_ESCAPE, "\\$1")
    If $S_START = "" Then $S_START = "\A"
    If $S_END = "" Then $S_END = "\z"
    Local $A_RET = StringRegExp($S_STRING, "(?s)" & $S_CASE & $S_START & "(.*?)" & $S_END, 3)
    If @error Then Return SetError(1, 0, 0)
    Return $A_RET
EndFunc   ;==>_STRINGBETWEEN
Func _Add_Strings($aList, $AU3, $splitChar)
    Global $sPass = ""
    Dim $sRndChr[3]
    Local $Digits = Random(4, 15, 1)
    For $i = 1 To $Digits
        $sRndChr[0] = Chr(Random(65, 90, 1))
        $sRndChr[1] = Chr(Random(97, 122, 1))
        $sRndChr[2] = Chr(Random(48, 57, 1))
        $sPass &= $sRndChr[Random(0, 2, 1)]
    Next
    Local $doneEncryption = False
    Local $newAU3 = $AU3
    _ArraySortDblDel($aList)
    For $A = 0 To UBound($aList) - 1
        If StringInStr($aList[$A], @CRLF) Then
            ContinueLoop
        ElseIf $aList[$A] <> "" And StringInStr($aList[$A], "_CryptoDragon_Crypt") = False And StringLeft($aList[$A], 1) <> "'" And StringRight($aList[$A], 1) <> "'" And StringLeft($aList[$A], 1) <> '"' And StringRight($aList[$A], 1) <> '"' And StringLen($aList[$A]) > 1 Then
            If StringInStr($aList[$A], "&") Then
                If StringRight($aList[$A], 1) = "&" Then
                    $newAU3 = StringReplace($newAU3, $splitChar & StringTrimRight($aList[$A], 1) & $splitChar, " & _CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimRight($aList[$A], 1), $sPass, StringLen(StringTrimRight($aList[$A], 1)))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 1) & ")&")
                    ConsoleWrite($splitChar & StringTrimRight($aList[$A], 1) & $splitChar & ":_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimRight($aList[$A], 1), $sPass, StringLen(StringTrimRight($aList[$A], 1)))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 1) & ")&" & @CRLF)
                ElseIf StringRight($aList[$A], 2) = "& " Then
                    $newAU3 = StringReplace($newAU3, $splitChar & StringTrimRight($aList[$A], 2) & $splitChar, "_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimRight($aList[$A], 2), $sPass, StringLen(String($aList[$A]) - 2))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 2) & ") & ")
                    ConsoleWrite($splitChar & StringTrimRight($aList[$A], 2) & $splitChar & ":_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimRight($aList[$A], 2), $sPass, StringLen(String($aList[$A]) - 2))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 2) & ") &" & @CRLF)
                ElseIf StringLeft($aList[$A], 1) = "&" Then
                    $newAU3 = StringReplace($newAU3, $splitChar & StringTrimLeft($aList[$A], 1) & $splitChar, "&_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimLeft($aList[$A], 2), $sPass, StringLen(String($aList[$A]) - 1))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 1) & ")")
                    ConsoleWrite($splitChar & StringTrimLeft($aList[$A], 1) & $splitChar & ":&_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimLeft($aList[$A], 1), $sPass, StringLen(String($aList[$A]) - 1))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 1) & ")" & @CRLF)
                ElseIf StringLeft($aList[$A], 2) = " &" Then
                    $newAU3 = StringReplace($newAU3, $splitChar & StringTrimLeft($aList[$A], 2) & $splitChar, " & _CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimLeft($aList[$A], 2), $sPass, StringLen(String($aList[$A]) - 2))) & "'), BinaryToString('" & StringToBinary($sPass) & "'))")
                    ConsoleWrite($splitChar & StringTrimLeft($aList[$A], 2) & $splitChar & ": & _CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt(StringTrimLeft($aList[$A], 2), $sPass, StringLen(String($aList[$A]) - 2))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A]) - 2) & ")" & @CRLF)
                Else
                    $newAU3 = StringReplace($newAU3, $splitChar & $aList[$A] & $splitChar, "_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt($aList[$A], $sPass, StringLen($aList[$A]))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A])) & ")")
                    ConsoleWrite($splitChar & $aList[$A] & $splitChar & ":_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt($aList[$A], $sPass, StringLen($aList[$A]))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A])) & ")" & @CRLF)
                EndIf
            Else
                $newAU3 = StringReplace($newAU3, $splitChar & $aList[$A] & $splitChar, "_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt($aList[$A], $sPass, StringLen($aList[$A]))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & StringLen($aList[$A]) & ")")
                ConsoleWrite($splitChar & $aList[$A] & $splitChar & ":_CryptoDragon_Crypt(BinaryToString('" & StringToBinary(_CryptoDragon_Crypt($aList[$A], $sPass, StringLen($aList[$A]))) & "'), BinaryToString('" & StringToBinary($sPass) & "'), " & String(StringLen($aList[$A])) & ")" & @CRLF)
            EndIf
        EndIf
    Next
    Return $newAU3
EndFunc   ;==>_ADD_STRINGS
Func base64($vCode, $bEncode = True, $bUrl = False)
    Local $oDM = ObjCreate("Microsoft.XMLDOM")
    If Not IsObj($oDM) Then Return SetError(1, 0, 1)
    Local $oEL = $oDM.createElement("Tmp")
    $oEL.DataType = "bin.base64"
    If $bEncode then
        $oEL.NodeTypedValue = Binary($vCode)
        If Not $bUrl Then Return $oEL.Text
        Return StringReplace(StringReplace(StringReplace($oEL.Text, "+", "-"),"/", "_"), @LF, "")
    Else
        If $bUrl Then $vCode = StringReplace(StringReplace($vCode, "-", "+"), "_", "/")
        $oEL.Text = $vCode
        Return BinaryToString($oEL.NodeTypedValue, 4)
    EndIf
EndFunc ;==>base64
Func _Encrypt_Strings($AU3, $file_Simple_Obfuscated)
    Local $sSTRINGS = _StringBetween($AU3, "'", "'")
    Local $newAU3 = _Add_Strings($sSTRINGS, $AU3, "'")
    Local $dSTRINGS = _StringBetween($newAU3, '"', '"')
    Local $epicAU3 = _Add_Strings($dSTRINGS, $newAU3, '"')
    Local $fileHandle = FileOpen($file_Simple_Obfuscated, 18)
    FileWrite($fileHandle, base64("RnVuYyBfQ3J5cHRvRHJhZ29uX0NyeXB0KCRzX1N0cmluZywgJHNfS2V5LCAkaUxlbiwgJHhvcksyID0gMHgxMiwgJHNfTGV2ZWwgPSAxLjMzNykKCUxvY2FsICRzX0VuY3J5cHRlZCA9ICIiLCAkZmluX0VuY3J5cHRlZCA9ICIiLCAkc19rYyA9IDEKCUlmIFN0cmluZ0xlbigkc19LZXkpID0gMCBPciAkc19MZXZlbCA8IDEgVGhlbiBSZXR1cm4gMAoJJHNfS2V5ID0gU3RyaW5nU3BsaXQoJHNfS2V5LCAnJykKCSRzX1N0cmluZyA9IFN0cmluZ1NwbGl0KCRzX1N0cmluZywgJycpCglGb3IgJHggPSAxIFRvICRzX1N0cmluZ1swXQoJCUlmICRzX2tjID4gJHNfS2V5WzBdIFRoZW4gJHNfa2MgPSAxCgkJJHNfRW5jcnlwdGVkID0gJHNfS2V5WyRzX2tjXQoJCSRzX0VuY3J5cHRlZCArPSBGbG9vcihBc2MoJHNfS2V5WyRzX2tjXSkgKiAkc19MZXZlbCk7CgkJJHNfRW5jcnlwdGVkID0gQml0Tk9UKCRzX0VuY3J5cHRlZCk7CgkJJHNfRW5jcnlwdGVkID0gQml0WE9SKCRzX0VuY3J5cHRlZCwgRmxvb3IoQXNjKCRzX0tleVskc19rY10pICogJHNfTGV2ZWwpKTsKCQkkc19FbmNyeXB0ZWQgKz0gRmxvb3IoQXNjKCRzX0tleVskc19rY10pICogJHNfTGV2ZWwpOwoJCSRzX0VuY3J5cHRlZCAtPSBGbG9vcihBc2MoJHNfS2V5WyRzX2tjXSkgKiAkc19MZXZlbCk7CgkJJHNfRW5jcnlwdGVkID0gQml0WE9SKCRzX0VuY3J5cHRlZCwgRmxvb3IoQXNjKCRzX0tleVskc19rY10pICogJHNfTGV2ZWwpKTsKCQkkc19FbmNyeXB0ZWQgPSAkc19FbmNyeXB0ZWQgLSAxOwoJCSRzX0VuY3J5cHRlZCA9IEJpdFhPUigkc19FbmNyeXB0ZWQsIEZsb29yKEFzYygkc19LZXlbJHNfa2NdKSAqICRzX0xldmVsKSk7CgkJJHNfRW5jcnlwdGVkID0gJHNfRW5jcnlwdGVkICsgMTsKCQkkc19FbmNyeXB0ZWQgKz0gRmxvb3IoQXNjKCRzX0tleVskc19rY10pICogJHNfTGV2ZWwpOwoJCSRzX0VuY3J5cHRlZCA9IEJpdFhPUigkc19FbmNyeXB0ZWQsICR4b3JLMik7CgkJJHNfRW5jcnlwdGVkID0gQml0Tk9UKCRzX0VuY3J5cHRlZCk7CgkJJHNfRW5jcnlwdGVkICs9IEZsb29yKEFzYygkc19LZXlbJHNfa2NdKSAqICRzX0xldmVsKTsKCQkkZmluX0VuY3J5cHRlZCAmPSBDaHIoQml0WE9SKEFzYygkc19TdHJpbmdbJHhdKSwgRmxvb3IoQXNjKCRzX0tleVskc19rY10pICogJHNfTGV2ZWwpKSkKCQkkc19rYyArPSAxCglOZXh0CglSZXR1cm4gU3RyaW5nTGVmdCgkZmluX0VuY3J5cHRlZCwgJGlMZW4pCkVuZEZ1bmMgICA7PT0+X0NyeXB0b0RyYWdvbl9DcnlwdA==", False))
    FileWrite($fileHandle, $epicAU3)
    FileClose($fileHandle)
EndFunc   ;==>_ENCRYPT_STRINGS
Func _Write_CryptoDragon_Obfuscated_File($AU3) ; Write CryptoDragon Obfuscated File
    Local $file_Simple_Obfuscated = StringTrimRight($file_Script_to_Obfuscate, 4) & "-Obfuscated.au3" ; Create CryptoDragon Obfuscated Filename
    _Encrypt_Strings($AU3, $file_Simple_Obfuscated)
EndFunc ; ==> _Write_CryptoDragon_Obfuscated_File
; ===================================================================================================