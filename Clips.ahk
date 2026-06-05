; 请帮我写个 Autohotkey 脚本。
; 当我按下 Win + C，读取并显示当前目录下 Clips.txt。根据后续选择写入剪贴板。再触发一次 Ctrl＋V，粘贴。

; Win+C 剪贴板记录快速选择

; 全局变量
Global g_Clips := []             ; 原始条目（纯文本）
Global g_LastClickTime := 0
Global g_LastClickItem := ""
Global g_ShortcutKeys := {}      ; 按键字符 -> 纯名称
Global g_GuiHwnd := 0
Global g_ActiveHwnd := 0         ; 触发热键时的原窗口句柄

; 注册键盘消息钩子（0-9/a-z 快捷键 + ESC 退出）
OnMessage(0x0100, "OnGuiKey")

; Win+C 热键
#c::
    WinGet, g_ActiveHwnd, ID, A
    ShowClipSelector()
return

; 显示剪贴板选择器
ShowClipSelector()
{
    Global g_Clips, g_LastClickTime, g_LastClickItem
    Global g_ShortcutKeys, g_GuiHwnd

    g_LastClickTime := 0
    g_LastClickItem := ""

    clipsFile := "e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Clips.txt"

    ; 读取文件
    FileRead, fileContent, *P65001 %clipsFile%
    if ErrorLevel
    {
        MsgBox, 无法读取：%clipsFile%
        return
    }

    ; 解析条目（纯文本，每行一条）
    g_Clips := []
    Loop, Parse, fileContent, `n, `r
    {
        Line := Trim(A_LoopField)
        if (Line != "")
            g_Clips.Push(Line)
    }

    if (g_Clips.Length() = 0)
    {
        MsgBox, Clips.txt 中没有有效内容！
        return
    }

    ; 构建带快捷键前缀的显示列表
    shortcutChars := "0123456789abcdefghijklmnopqrstuvwxyz"
    g_ShortcutKeys := {}
    DisplayItems := []

    Loop % g_Clips.Length()
    {
        Text := g_Clips[A_Index]
        if (A_Index <= 36)
        {
            Char := SubStr(shortcutChars, A_Index, 1)
            g_ShortcutKeys[Char] := Text
            DisplayItems.Push("[" Char "] " Text)
        }
        else
        {
            DisplayItems.Push("    " Text)
        }
    }

    ; 销毁旧窗口
    Gui, ClipSelect:Destroy

    ; 创建图形界面
    Gui, ClipSelect:New
    Gui, ClipSelect:+AlwaysOnTop +ToolWindow
    Gui, ClipSelect:Font, s10, Segoe UI
    Gui, ClipSelect:Add, Text, w420 Center, 选择剪贴板内容（0-9/a-z 直达，空格执行，ESC 退出）：

    ListItems := JoinArray(DisplayItems, "|")
    Gui, ClipSelect:Add, ListBox, w640 h480 vSelectedItem gOnItemSelect Choose1, %ListItems%

    Gui, ClipSelect:Add, Button, w150 h35 Default gExecuteSelection, 粘贴(&P)
    Gui, ClipSelect:Add, Button, x+20 w150 h35 gCancelSelector, 取消(&C)
    Gui, ClipSelect:Show, , 选择剪贴板内容

    ; 捕获 HWND
    g_GuiHwnd := WinExist("A")
    return
}

; 项目选择事件（支持双击）
OnItemSelect:
    Gui, ClipSelect:Submit, NoHide
    Global g_LastClickTime, g_LastClickItem

    CurrentTime := A_TickCount
    If (g_LastClickItem = SelectedItem && CurrentTime - g_LastClickTime < 500)
    {
        g_LastClickTime := 0
        g_LastClickItem := ""
        GoSub, ExecuteSelection
    }
    Else
    {
        g_LastClickTime := CurrentTime
        g_LastClickItem := SelectedItem
    }
    return

; 执行粘贴
ExecuteSelection:
    Global g_Clips, g_GuiHwnd, g_ActiveHwnd

    Gui, ClipSelect:Submit, NoHide
    if (SelectedItem = "")
    {
        MsgBox, 请选择一个条目！
        return
    }

    ; 剥离快捷键前缀 "[x] "
    Text := SelectedItem
    if (SubStr(Text, 1, 1) = "[" && SubStr(Text, 3, 2) = "] ")
        Text := SubStr(Text, 5)

    ; 写入剪贴板
    Clipboard := Text
    ClipWait, 1

    if (Clipboard != Text)
    {
        MsgBox, 复制失败！
        return
    }

    ; 隐藏 GUI
    g_GuiHwnd := 0
    Gui, ClipSelect:Hide

    ; 反馈
    ToolTip, 已复制：%Text%
    SetTimer, RemoveToolTip, -2000

    ; 激活原窗口并粘贴
    WinActivate, ahk_id %g_ActiveHwnd%
    Sleep, 150
    Send, ^v

    Gui, ClipSelect:Destroy
    return

; 取消 / 关闭
CancelSelector:
GuiClose:
GuiEscape:
    Global g_GuiHwnd
    g_GuiHwnd := 0
    Gui, ClipSelect:Destroy
    return

; 工具提示清除
RemoveToolTip:
    ToolTip
    return

; 辅助函数
JoinArray(Array, Delimiter)
{
    Result := ""
    for Index, Value in Array
    {
        if (Index = 1)
            Result := Value
        else
            Result := Result . Delimiter . Value
    }
    return Result
}

; ==================== 键盘钩子 ====================
OnGuiKey(wParam, lParam, msg, hwnd)
{
    Global g_GuiHwnd, g_ShortcutKeys, SelectedItem

    ; GUI 未打开 -> 放行
    if (!g_GuiHwnd)
        return

    ; ESC -> 关闭 GUI
    if (wParam = 0x1B)
    {
        g_GuiHwnd := 0
        Gui, ClipSelect:Destroy
        return 0
    }

    ; 只拦截 GUI 为前台时
    if (!WinActive("ahk_id " g_GuiHwnd))
        return

    ; 空格键 -> 执行当前项
    if (wParam = 0x20)
    {
        SetTimer, ExecuteSelection, -10
        return 0
    }

    key := ""

    ; 数字 0-9
    if (wParam >= 0x30 && wParam <= 0x39)
        key := Chr(wParam)

    ; 字母 a-z
    if (wParam >= 0x41 && wParam <= 0x5A)
        key := Chr(wParam + 32)

    if (key = "")
        return

    ; 匹配快捷键 -> 选中并执行
    if (g_ShortcutKeys.HasKey(key))
    {
        GuiControl, ChooseString, SelectedItem, % g_ShortcutKeys[key]
        SetTimer, ExecuteSelection, -10
        return 0
    }

    return
}