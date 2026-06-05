; 请帮我写个 Autohotkey 脚本。
; 1. 如果当前应用为 Total Commander，按 Alt＋X，则弹出图形界面。读取"e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Total Commander Ultima Prime Shortcut.txt"，每一行为一个地址，如："Downloads=d:\Downloads\"，弹出图形界面，可选择：Downloads，将"d:\Downloads\"写入参数，运行命令：""d:\ProApps\Total Commander Ultima Prime\TOTALCMD64.EXE" /S %1"。目的是在激活到一栏（Total Commander 有两栏）打开"d:\Downloads\"。
; 2. 如果当前应用为 Cmder.exe，按 Alt＋X，则弹出图形界面。读取"e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Cmder Shortcut.txt"，每一行为一个命令，如："cd e:\Documents\Creations\Scripts\Python\"，弹出图形界面，可选择："cd e:\Documents\Creations\Scripts\Python\"，将其写入剪贴板，粘贴到 Cmder.exe。
; 3. 如果当前应用为 Xshell.exe，按 Alt＋X，则弹出图形界面。读取"e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Xshell Shortcut.txt"，每一行为一个命令，如："docker compose up -d"，弹出图形界面，可选择："docker compose up -d"，将其写入剪贴板，粘贴到 Xshell.exe。
; 4. 如果当前应用为 Notepad4.exe，按 Alt＋X，则弹出图形界面。读取"e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Notepad4 Shortcut.txt"，每一行为一个地址，如："Clips.txt=e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Clips.txt"，弹出图形界面，可选择：Clips.txt，将"e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Clips.txt" 用 Notepad4.exe 用新的窗口打开。
; 预设默认为第一行。

; Total Commander, Cmder, Xshell 和 Notepad4 Win+X 快速命令

; 全局变量
Global g_Commands := {}
Global g_ConfigFile := ""
Global g_GuiTitle := ""
Global g_AppType := "" ; "TC", "CMDER", "XSHELL", "NOTEPAD4"
Global g_LastClickTime := 0
Global g_LastClickItem := ""
Global g_ShortcutKeys := {}  ; 按键字符 -> 纯名称
Global g_GuiHwnd := 0

; 注册键盘消息钩子（0-9/a-z 快捷键 + ESC 退出）
OnMessage(0x0100, "OnGuiKey")

; Total Commander 热键
#IfWinActive, ahk_class TTOTAL_CMD
#x::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Total Commander Ultima Prime Shortcut.txt"
    g_GuiTitle := "Total Commander 快速跳转"
    g_AppType := "TC"
    ShowCommandSelector()
return
#IfWinActive

; Cmder 热键
#If WinActive("ahk_exe Cmder.exe") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_class ConsoleWindowClass")
#x::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Cmder Shortcut.txt"
    g_GuiTitle := "Cmder 快速命令"
    g_AppType := "CMDER"
    ShowCommandSelector()
return
#If

; Xshell 热键
#IfWinActive, ahk_exe Xshell.exe
#x::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Xshell Shortcut.txt"
    g_GuiTitle := "Xshell 快速命令"
    g_AppType := "XSHELL"
    ShowCommandSelector()
return
#IfWinActive

; Notepad4 热键
#IfWinActive, ahk_exe Notepad4.exe
#x::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachments\AutoHotkey\Notepad4 Shortcut.txt"
    g_GuiTitle := "Notepad4 快速打开"
    g_AppType := "NOTEPAD4"
    ShowCommandSelector()
return
#IfWinActive

; 显示命令选择器
ShowCommandSelector()
{
    Global g_Commands, g_ConfigFile, g_GuiTitle, g_AppType
    Global g_LastClickTime, g_LastClickItem
    Global g_ShortcutKeys, g_GuiHwnd

    g_LastClickTime := 0
    g_LastClickItem := ""

    ; 读取配置文件
    FileRead, ConfigContent, *P65001 %g_ConfigFile%
    if ErrorLevel
    {
        MsgBox, 无法读取配置文件：%g_ConfigFile%
        return
    }

    ; 解析配置文件
    MenuItems := []
    g_Commands := {}

    Loop, Parse, ConfigContent, `n, `r
    {
        if (A_LoopField = "")
            continue

        Pos := InStr(A_LoopField, "=")
        if (Pos > 0)
        {
            Name := Trim(SubStr(A_LoopField, 1, Pos-1))
            Command := Trim(SubStr(A_LoopField, Pos+1))
            if (Name = "")
                Name := Command
            MenuItems.Push(Name)
            g_Commands[Name] := Command
        }
        else
        {
            Name := Trim(A_LoopField)
            Command := Trim(A_LoopField)
            MenuItems.Push(Name)
            g_Commands[Name] := Command
        }
    }

    if (MenuItems.Length() = 0)
    {
        MsgBox, 配置文件中没有找到有效的项！
        return
    }

    ; 构建带快捷键前缀的显示列表，同时建 key->名称 映射
    shortcutChars := "0123456789abcdefghijklmnopqrstuvwxyz"
    g_ShortcutKeys := {}
    DisplayItems := []

    Loop % MenuItems.Length()
    {
        Name := MenuItems[A_Index]
        if (A_Index <= 36)
        {
            Char := SubStr(shortcutChars, A_Index, 1)
            g_ShortcutKeys[Char] := Name
            DisplayItems.Push("[" Char "] " Name)
        }
        else
        {
            DisplayItems.Push("    " Name)
        }
    }

    ; 销毁旧窗口
    Gui, CommandSelector:Destroy

    ; 创建图形界面
    Gui, CommandSelector:New
    Gui, CommandSelector:+AlwaysOnTop +ToolWindow
    Gui, CommandSelector:Font, s10, Segoe UI
    Gui, CommandSelector:Add, Text, w420 Center, 选择要执行的命令（0-9/a-z 直达，空格执行，ESC 退出）：

    ListItems := JoinArray(DisplayItems, "|")
    Gui, CommandSelector:Add, ListBox, w640 h480 vSelectedItem gOnItemSelect Choose1, %ListItems%

    Gui, CommandSelector:Add, Button, w150 h35 Default gExecuteCommand, 执行命令
    Gui, CommandSelector:Add, Button, x+20 w150 h35 gCancelSelector, 取消
    Gui, CommandSelector:Show, , %g_GuiTitle%

    ; 用 WinExist 捕获刚创建窗口的 HWND
    g_GuiHwnd := WinExist("A")
    return
}

; 项目选择事件（支持双击）
OnItemSelect:
    Gui, CommandSelector:Submit, NoHide
    Global g_LastClickTime, g_LastClickItem

    CurrentTime := A_TickCount
    If (g_LastClickItem = SelectedItem && CurrentTime - g_LastClickTime < 500)
    {
        g_LastClickTime := 0
        g_LastClickItem := ""
        GoSub, ExecuteCommand
    }
    Else
    {
        g_LastClickTime := CurrentTime
        g_LastClickItem := SelectedItem
    }
    return

; 执行命令
ExecuteCommand:
    Global g_Commands, g_AppType
    Global g_GuiHwnd

    Gui, CommandSelector:Submit, NoHide
    if (SelectedItem = "")
    {
        MsgBox, 请选择一个命令！
        return
    }

    ; 剥离快捷键前缀 "[x] "（4字符 -> 纯名称）
    CleanName := SelectedItem
    if (SubStr(CleanName, 1, 1) = "[" && SubStr(CleanName, 3, 2) = "] ")
        CleanName := SubStr(CleanName, 5)

    Command := g_Commands[CleanName]

    ; 根据应用类型执行
    if (g_AppType = "TC")
    {
        TCExe := "d:\ProApps\Total Commander Ultima Prime\TOTALCMD64.EXE"
        Run, "%TCExe%" /S "%Command%"
    }
    else if (g_AppType = "CMDER" or g_AppType = "XSHELL")
    {
        ; 先隐藏 GUI，确保焦点转移到终端
        g_GuiHwnd := 0
        Gui, CommandSelector:Hide

        Clipboard := Command
        ClipWait, 1

        if (g_AppType = "CMDER")
        {
            IfWinExist, ahk_exe Cmder.exe
                WinActivate
            else IfWinExist, ahk_class VirtualConsoleClass
                WinActivate
            else IfWinExist, ahk_class ConsoleWindowClass
                WinActivate
        }
        else if (g_AppType = "XSHELL")
        {
            WinActivate, ahk_exe Xshell.exe
        }

        Sleep, 150
        Send, ^v
    }
    else if (g_AppType = "NOTEPAD4")
    {
        Notepad4Exe := "d:\ProApps\Notepad4\Notepad4.exe"
        Run, "%Notepad4Exe%" "%Command%"
    }

    Gui, CommandSelector:Destroy
    return

; 取消 / 关闭
CancelSelector:
GuiClose:
GuiEscape:
    Global g_GuiHwnd
    g_GuiHwnd := 0
    Gui, CommandSelector:Destroy
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
        Gui, CommandSelector:Destroy
        return 0
    }

    ; 只拦截 GUI 为前台时
    if (!WinActive("ahk_id " g_GuiHwnd))
        return

    ; 空格键 -> 执行当前项
    if (wParam = 0x20)
    {
        SetTimer, ExecuteCommand, -10
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
        SetTimer, ExecuteCommand, -10
        return 0
    }

    return
}