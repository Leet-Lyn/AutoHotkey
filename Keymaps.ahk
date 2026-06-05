; 请帮我写个 Autohotkey 脚本。

; 使用 ~ 修饰符，让 Win 键的原始功能仍然部分保留
~LWin Up::return
; Win+V → Ctrl+Alt+Shift+V，触发 Ditto 快捷键。
#v::
    Send {Blind}{LWin Up}{RWin Up}
    Send ^!+v
return
; Win+S → Ctrl+Alt+Shift+S，触发 PixPin 快捷键。
#s::
    Send {Blind}{LWin Up}{RWin Up}
    Send ^!+s
return
; Win+S → Ctrl+Alt+Shift+S，触发 PixPin 快捷键。
#m::
    Send {Blind}{LWin Up}{RWin Up}
    Send ^!+m
return

; 禁用 CapsLock 的切换功能，使其成为纯修饰键
SetCapsLockState, AlwaysOff
CapsLock & a::Send {Left}
CapsLock & d::Send {Right}
CapsLock & w::Send {Up}
CapsLock & s::Send {Down}
CapsLock & q::Send {Home}
CapsLock & e::Send {End}
CapsLock & r::Send {PgUp}
CapsLock & f::Send {PgDn}
; 单独按下 CapsLock 不做任何事（已由 SetCapsLockState 阻止切换）
CapsLock::return

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