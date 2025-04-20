; 请帮我写个 Autohotkey 脚本。
; 重新映射些键位。

; 按下 Alt＋鼠标左键，发送 Enter。
!LButton::Send {Enter}

; 按下 Alt＋鼠标右键，发送 Del。
!RButton::Send {Del}

; 按下 Alt＋鼠标中键，发送 Backspace。
!MButton::Send {Backspace}

; 按下 Alt＋鼠标滚轮向上，发送 Home。
!WheelUp::Send {Home}

; 按下 Alt＋鼠标滚轮向下，发送 End。
!WheelDown::Send {End}

; 同时按下鼠标左键和右键，发送 ESC 键。
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

; Ctrl＋Esc，映射为虚拟的 F13 键。
^Esc::Send {F13}

; Ctrl＋Shift＋X，则依次触发 Home，Shift＋End，Ctrl＋X，删除一行；当我按 Ctrl＋Shift＋C，则依次触发 Home，Shift＋End，Ctrl＋C，复制一行。当我按 Ctrl＋Shift＋V，则将剪贴板内的内容，以无格式文字粘贴。
^+x::
    SendInput {Home}           ; 移动到行首
    SendInput +{End}           ; 选中到行尾
    SendInput ^{x}             ; 剪切选中内容
return
^+c::
    SendInput {Home}           ; 移动到行首
    SendInput +{End}           ; 选中到行尾
    SendInput ^{c}             ; 复制选中内容
return
^+v::
    ; 备份原始剪贴板内容
    originalClipboard := ClipboardAll
    
    ; 将剪贴板内容转换为纯文本
    Clipboard := Clipboard     ; 自动移除格式信息
    ClipWait, 1                ; 等待剪贴板数据就绪
    
    ; 执行普通粘贴操作
    SendInput ^v
    
    ; 短暂延迟后恢复剪贴板内容
    Sleep, 100
    Clipboard := originalClipboard
    originalClipboard := ""    ; 清空变量释放内存
return