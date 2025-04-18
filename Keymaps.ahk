; 请帮我写个 Autohotkey 脚本。
; 重新映射些键位。

; 按下 Alt + 鼠标左键 发送 Enter
!LButton::Send {Enter}

; 按下 Alt + 鼠标右键 发送 Del
!RButton::Send {Del}

; 按下 Alt + 鼠标中键 发送 Backspace
!MButton::Send {Backspace}

; 按下 Alt + 鼠标滚轮向上 发送 Home
!WheelUp::Send {Home}

; 按下 Alt + 鼠标滚轮向下 发送 End
!WheelDown::Send {End}

; 同时按下鼠标左键和右键，发送 ESC 键
~LButton & RButton::
~RButton & LButton::
Send, {Esc}
return

; 鼠标前进键 (XButton2) 映射为 Ctrl
XButton2::Send {Ctrl Down}
XButton2 Up::Send {Ctrl Up}

; 鼠标后退键 (XButton1) 映射为 Alt
XButton1::Send {Alt Down}
XButton1 Up::Send {Alt Up}

; 狙击键映射 (XButton3) -> Shift
; XButton3::Send {Shift Down}
; XButton3 Up::Send {Shift Up}

; 浏览器功能恢复（需按住Alt时触发）
; Alt + 前进键 -> 浏览器前进
!XButton2::Send {Browser_Forward}

; Alt + 后退键 -> 浏览器后退
!XButton1::Send {Browser_Back}