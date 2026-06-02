; 请帮我写个 Autohotkey 脚本。

; ==================================================
; 按住 左 Alt 再按以下键，实现方向/翻页/首尾操作
; 不会触发输入法或系统菜单，按住期间可连续切换字母
; ==================================================

; 方向键
LAlt & a::Send {Left}
LAlt & d::Send {Right}
LAlt & w::Send {Up}
LAlt & s::Send {Down}

; 行首 / 行尾
LAlt & q::Send {Home}
LAlt & e::Send {End}

; 上一页 / 下一页
LAlt & r::Send {PgUp}
LAlt & f::Send {PgDn}

; 可选：屏蔽单独按左 Alt 时激活系统菜单栏（不影响组合键）
; 若不需要此行为，请注释或删除下行
; LAlt::return


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