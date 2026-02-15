;#SingleInstance force
;@Ahk2Exe-ExeName %A_ScriptDir%\CompiledHotkeys\GlobalHotkeys.exe

#Requires AutoHotkey v2.0

; --- Google Chrome, Opera GX ---
#HotIf WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe opera.exe") || WinActive("ahk_exe msedge.exe")
!1::Send "^1"
!2::Send "^2"
!3::Send "^3"
!4::Send "^4"
!5::Send "^5"
!6::Send "^6"
!7::Send "^7"
!8::Send "^8"
!9::Send "^9"
!w::Send "^w"
!t::Send "^t"
!c::Send "^c"
!v::Send "^v"
!a::Send "^a"
!x::Send "^x"
!r::Send "^r"
!Backspace::Send "+{Home}{Del}"


; --- Microsoft Teams ---
#HotIf WinActive("ahk_exe ms-teams.exe")
!1::Send "^1"
!2::Send "^2"
!3::Send "^3"
!4::Send "^4"
!5::Send "^5"
!6::Send "^6"

; --- Windows Terminal ---
#HotIf WinActive("ahk_exe WindowsTerminal.exe")
!1::Send "^!1"
!2::Send "^!2"
!3::Send "^!3"
!4::Send "^!4"
!5::Send "^!5"
!6::Send "^!6"
!7::Send "^!7"
!8::Send "^!8"
!9::Send "^!9"
^w::Send "^+w"


#HotIf ; Reset hotkey criteria for any future additions
