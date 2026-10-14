#Requires AutoHotkey v2.0

; ============================================================
; Keymaps.ahk
;
; 鼠标前进键 (XButton2) → Ctrl
; 鼠标后退键 (XButton1) → Alt
; 狙击键          → Shift
;
; Alt＋鼠标左键    → Enter
; Alt＋鼠标右键    → Delete
; Alt＋鼠标中键    → Backspace
; Alt＋滚轮向上    → Home
; Alt＋滚轮向下    → End
; Alt＋前进键      → 浏览器前进
; Alt＋后退键      → 浏览器后退
;
; 左键＋右键同时   → Esc
; Ctrl＋Esc        → F13
;
; Ctrl＋Shift＋X   → 删除一行
; Ctrl＋Shift＋C   → 复制一行
; Ctrl＋Shift＋V   → 无格式粘贴
;
; Win＋R           → Ctrl＋Alt＋R
; Win＋V           → Ctrl＋Alt＋V
; Win＋G           → Ctrl＋Alt＋G
; Win＋M           → Ctrl＋Alt＋M
;
; CapsLock 导航模式（切换式）：
;   Caps＋A  → Left      Caps＋D  → Right
;   Caps＋W  → Up        Caps＋S  → Down
;   Caps＋Q  → Home      Caps＋E  → End
;   Caps＋R  → PageUp    Caps＋F  → PageDown
; ============================================================

; ============================================================
; 狙击键配置
; 根据鼠标驱动中狙击键的实际映射修改此项：
;   常见值: F20, SC12A, 或鼠标驱动设置的自定义键
; ============================================================
SniperKey := "F20"

; ============================================================
; 鼠标按钮重映射
; ============================================================

; 后退键 → Alt
XButton1:: {
    if GetKeyState("LAlt", "P") {
        ; 物理 Alt 已按下 + 后退键 → 浏览器后退
        Send("{Browser_Back}")
    } else {
        Send("{Blind}{LAlt DownR}")
        KeyWait("XButton1")
        Send("{Blind}{LAlt Up}")
    }
}

; 前进键 → Ctrl
XButton2:: {
    if GetKeyState("LAlt", "P") || GetKeyState("XButton1", "P") {
        ; Alt 按下 + 前进键 → 浏览器前进
        Send("{Browser_Forward}")
    } else {
        Send("{Blind}{LCtrl DownR}")
        KeyWait("XButton2")
        Send("{Blind}{LCtrl Up}")
    }
}

; 狙击键 → Shift
Hotkey(SniperKey, SniperDown, "On")
SniperDown(*) {
    Send("{Blind}{LShift DownR}")
    KeyWait(SniperKey)
    Send("{Blind}{LShift Up}")
}

; ============================================================
; Alt + 鼠标按键（物理 Alt 或 XButton1 均生效）
; ============================================================

; --- 物理 Alt 系列 ---
~LAlt & LButton::MouseAction("Enter")
~LAlt & RButton::MouseAction("Delete")
~LAlt & MButton::MouseAction("Backspace")
~LAlt & WheelUp::MouseAction("Home")
~LAlt & WheelDown::MouseAction("End")

; --- XButton1（后退键）系列 ---
XButton1 & LButton::MouseAction("Enter")
XButton1 & RButton::MouseAction("Delete")
XButton1 & MButton::MouseAction("Backspace")
XButton1 & WheelUp::MouseAction("Home")
XButton1 & WheelDown::MouseAction("End")

MouseAction(key) {
    Send("{" key "}")
}

; ============================================================
; 左键 + 右键同时 → Esc
; ============================================================
~LButton & RButton::Send("{Esc}")
~RButton & LButton::Send("{Esc}")

; ============================================================
; Ctrl + Esc → F13（Vim 用）
; ============================================================
^Esc::Send("{F13}")

; ============================================================
; Ctrl + Shift 编辑器快捷操作
; ============================================================

; Ctrl+Shift+X → 删除一行
^+x::Send("{Home}+{End}{Delete}")

; Ctrl+Shift+C → 复制一行
^+c::Send("{Home}+{End}^c{End}")

; Ctrl+Shift+V → 无格式粘贴
^+v:: {
    saved := ClipboardAll()
    plainText := A_Clipboard
    if (plainText != "") {
        A_Clipboard := plainText
        ClipWait(0.3)
        Send("^v")
        Sleep(100)
        A_Clipboard := saved
    } else {
        Send("^v")
    }
}

; ============================================================
; Win 组合键 → Ctrl+Alt(+Shift) 映射
; 前提：已在 Windows 设置中关闭 Game Bar (Win+G) 和剪贴板历史 (Win+V)
; ============================================================

#r::Send("^!r")
#v::Send("^!v")
#g::Send("^!g")
#m::Send("^!m")

; ============================================================
; CapsLock 方向键导航（切换式）
;
; ⚠ 你的键盘在硬件/驱动层拦截了 CapsLock 按键事件，
;   AHK 完全看不到 CapsLock 的按下/松开，只能用切换状态做触发。
;
; 用法：
;   按 CapsLock → 灯亮 = 导航模式，字母变成方向键
;   再按一次   → 灯灭 = 正常打字模式
;
; 不想用导航模式又想切换大小写 → Shift+CapsLock
; ============================================================

#HotIf GetKeyState("CapsLock", "T")
a::Send("{Left}")
d::Send("{Right}")
w::Send("{Up}")
s::Send("{Down}")
q::Send("{Home}")
e::Send("{End}")
r::Send("{PgUp}")
f::Send("{PgDn}")
#HotIf
