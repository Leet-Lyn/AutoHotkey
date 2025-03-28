; 请帮我写个 Autohotkey 脚本。
; 重新映射些键位。

; 按下 Alt + 鼠标左键 发送 Enter
!LButton::Send {Enter}

; 按下 Alt + 鼠标右键 发送 Del
!RButton::Send {Del}

; 按下 Alt + 鼠标中键 发送 Backspace
!MButton::Send {Backspace}

; 按下 Alt + 鼠标滚轮向上 发送 PageUp
!WheelUp::Send {PgUp}

; 按下 Alt + 鼠标滚轮向下 发送 PageDown
!WheelDown::Send {PgDn}

; 按下 Alt + 鼠标前进键 (XButton2) 发送 Home
!XButton2::Send {Home}

; 按下 Alt + 鼠标后退键 (XButton1) 发送 End
!XButton1::Send {End}