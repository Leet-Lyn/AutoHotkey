#Requires AutoHotkey v2.0

; ============================================================
; Shortcut.ahk
; Win+X — 根据当前应用弹出对应快捷命令菜单
;   应用 → 行为:
;     Total Commander → 用 TC 打开目标路径
;     Cmder / Xshell  → 写剪贴板 → Ctrl+V 粘贴到终端
;     Notepad4        → 用 Notepad4 打开目标文件
;   索引: 0~9, a~z (最多36项)
;   空格/回车/双击 → 执行命令
; ============================================================

; ---------- 配置文件路径 ----------
ConfigFiles := Map(
    "TC",       A_ScriptDir "\Shortcut Total Commander Ultima Prime.txt",
    "CMDER",    A_ScriptDir "\Shortcut Cmder.txt",
    "XSHELL",   A_ScriptDir "\Shortcut Xshell.txt",
    "NOTEPAD4", A_ScriptDir "\Shortcut Notepad4.txt"
)

Titles := Map(
    "TC",       "Total Commander 快速跳转",
    "CMDER",    "Cmder 快速命令",
    "XSHELL",   "Xshell 快速命令",
    "NOTEPAD4", "Notepad4 快速打开"
)

; ---------- 热键: Total Commander ----------
#HotIf WinActive("ahk_class TTOTAL_CMD")
#x:: ShowShortcutGUI("TC")
#HotIf

; ---------- 热键: Cmder ----------
#HotIf WinActive("ahk_exe Cmder.exe") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_class ConsoleWindowClass")
#x:: ShowShortcutGUI("CMDER")
#HotIf

; ---------- 热键: Xshell ----------
#HotIf WinActive("ahk_exe Xshell.exe")
#x:: ShowShortcutGUI("XSHELL")
#HotIf

; ---------- 热键: Notepad4 ----------
#HotIf WinActive("ahk_exe Notepad4.exe")
#x:: ShowShortcutGUI("NOTEPAD4")
#HotIf

; ============================================================
; 显示快捷命令选择器
; ============================================================
ShowShortcutGUI(appType) {
    configFile := ConfigFiles[appType]
    guiTitle := Titles[appType]

    ; ---------- 读取配置文件 ----------
    if !FileExist(configFile) {
        MsgBox("无法读取配置文件：`n" configFile, "错误", "Icon!")
        return
    }

    configContent := FileRead(configFile, "UTF-8")

    ; 解析: 每行 "名称=命令" 或纯命令
    menuItems := []
    commands := Map()

    for _, line in StrSplit(configContent, "`n", "`r") {
        if (line = "")
            continue

        pos := InStr(line, "=")
        if (pos > 0) {
            name := Trim(SubStr(line, 1, pos - 1))
            cmd := Trim(SubStr(line, pos + 1))
            if (name = "")
                name := cmd
        } else {
            name := Trim(line)
            cmd := Trim(line)
        }
        menuItems.Push(name)
        commands[name] := cmd
    }

    if !menuItems.Length {
        MsgBox("配置文件中没有找到有效的项！", "提示", "Iconi")
        return
    }

    if menuItems.Length > 36
        menuItems.Length := 36

    ; 索引标签
    labels := []
    loop 10
        labels.Push(Mod(A_Index - 1, 10))
    loop 26
        labels.Push(Chr(Ord("a") + A_Index - 1))

    ; ---------- 创建 GUI ----------
    g := Gui()
    g.Title := guiTitle "  [0-9 a-z 导航 | 空格/回车执行 | Esc 关闭]"
    g.SetFont("s10", "Microsoft YaHei")
    g.MarginX := 12
    g.MarginY := 10

    g.AddText("", "索引 `t命令（双击或回车/空格 直接执行）")
    g.AddText("", "————————————————————————————————————————————")

    LV := g.AddListView("r18 w700 -Hdr Grid NoSort", ["Idx", "命令"])
    LV.ModifyCol(1, 45)
    LV.ModifyCol(2, 640)

    for i, name in menuItems {
        idx := i <= labels.Length ? labels[i] : "?"
        LV.Add(, idx, name)
    }

    ; 保存引用供模块级函数使用
    global gHwnd := g.Hwnd
    global gLV := LV
    global g := g
    global gCommands := commands
    global gAppType := appType

    ; ---------- 事件 ----------
    LV.OnEvent("DoubleClick", LV_DoubleClick)
    LV_DoubleClick(LV, RowNumber) {
        executeShortcut(LV, RowNumber, g)
    }

    g.OnEvent("Close", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())

    LV.Modify(1, "Select Focus Vis")

    g.Show("AutoSize Center")

    ; ---------- 键盘消息拦截 ----------
    OnMessage(0x0100, OnKeyDown)
    OnMessage(0x0104, OnKeyDown)

    WinWaitClose("ahk_id " gHwnd)

    OnMessage(0x0100, OnKeyDown, 0)
    OnMessage(0x0104, OnKeyDown, 0)
}

; ============================================================
; 键盘处理 (WM_KEYDOWN)
; ============================================================
OnKeyDown(wParam, lParam, msg, hwnd) {
    if !WinActive("ahk_id " gHwnd)
        return

    vk := wParam

    ; --- 数字 0~9 ---
    if vk >= 0x30 && vk <= 0x39 {
        idx := (vk - 0x30) + 1
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 字母 a~z ---
    if vk >= 0x41 && vk <= 0x5A {
        idx := 10 + (vk - 0x41) + 1
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 空格或回车 → 执行 ---
    if vk = 0x20 || vk = 0x0D {
        row := gLV.GetNext(0, "Focused")
        if row
            executeShortcut(gLV, row, g)
        return 0
    }
}

; ============================================================
; 执行快捷命令
; ============================================================
executeShortcut(LV, RowNumber, g) {
    name := LV.GetText(RowNumber, 2)
    command := gCommands[name]

    Switch gAppType {

    Case "TC":
        TCExe := "d:\ProApps\Total Commander Ultima Prime\TOTALCMD64.EXE"
        g.Destroy()
        Run('"' TCExe '" /S "' command '"')

    Case "CMDER", "XSHELL":
        A_Clipboard := command
        if !ClipWait(0.3) {
            g.Destroy()
            MsgBox("写入剪贴板失败。", "错误", "Icon!")
            return
        }

        g.Destroy()

        ; 激活终端窗口
        if (gAppType = "CMDER") {
            if WinExist("ahk_exe Cmder.exe")
                WinActivate("ahk_exe Cmder.exe")
            else if WinExist("ahk_class VirtualConsoleClass")
                WinActivate("ahk_class VirtualConsoleClass")
            else if WinExist("ahk_class ConsoleWindowClass")
                WinActivate("ahk_class ConsoleWindowClass")
        } else {
            if WinExist("ahk_exe Xshell.exe")
                WinActivate("ahk_exe Xshell.exe")
        }

        Sleep(30)
        Send("^v")

    Case "NOTEPAD4":
        Notepad4Exe := "d:\ProApps\notepad4\current\Notepad4.exe"
        g.Destroy()
        Run('"' Notepad4Exe '" "' command '"')
    }
}