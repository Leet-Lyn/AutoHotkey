; 请帮我写个 Autohotkey 脚本。

; 鼠标前进键 (XButton2)，映射为 Ctrl 键。
XButton2::Send {Ctrl Down}
XButton2 Up::Send {Ctrl Up}

; 鼠标后退键 (XButton1)，映射为 Alt 键。
XButton1::Send {Alt Down}
XButton1 Up::Send {Alt Up}

; 狙击键映射 (XButton3)，映射为 Shift 键。
; XButton3::Send {Shift Down}
; XButton3 Up::Send {Shift Up}

; 按下 Alt＋鼠标左键，发送 Enter 键。
!LButton::Send {Enter}

; 按下 Alt＋鼠标右键，发送 Del 键。
!RButton::Send {Del}

; 按下 Alt＋鼠标中键，发送 Backspace 键。
!MButton::Send {Backspace}

; 按下 Alt＋鼠标滚轮向上，发送 Home 键。
!WheelUp::Send {Home}

; 按下 Alt＋鼠标滚轮向下，发送 End 键。
!WheelDown::Send {End}

; Alt＋前进键，映射为浏览器前进
; !XButton2::Send {Browser_Forward}

; Alt＋后退键，映射为浏览器后退
; !XButton1::Send {Browser_Back}

; 同时按下鼠标左键和右键，发送 ESC 键。
~LButton & RButton::
~RButton & LButton::
Send, {Esc}
return

; 同时按下 XButton1 和鼠标中键，发送“浏览器返回键”。
XButton1 & MButton::
    Send {Browser_Back}
return

; 同时按下 XButton2 和鼠标中键，发送“媒体快进键”。
; XButton2 & MButton::
;     Send {Media_Forward}
; return

; Ctrl＋Esc，映射为虚拟的 F13 键（Vim 用）。
^Esc::Send {F13}

; Ctrl＋Shift＋X，映射为删除一行。
^+x::
    SendInput {Home}
    SendInput +{End}
    SendInput ^{x}
return

; Ctrl＋Shift＋C，映射为复制一行。
^+c::
    SendInput {Home}
    SendInput +{End}
    SendInput ^{c}
return

; Ctrl＋Shift＋V，映射为无格式粘贴。
^+v::
    originalClipboard := ClipboardAll
    Clipboard := Clipboard
    ClipWait, 1
    SendInput ^v
    Sleep, 100
    Clipboard := originalClipboard
    originalClipboard := ""
return