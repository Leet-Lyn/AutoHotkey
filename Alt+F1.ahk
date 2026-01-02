; 请帮我写个 Autohotkey 脚本。
; 1. 如果当前应用为 Total Commander，按 Alt＋F1，则弹出图形界面。读取“e:\Documents\Creations\Scripts\Attachment\Total Commander Ultima Prime Alt+F1.txt”，每一行为一个地址，如：“Downloads=d:\Downloads\”，弹出图形界面，可选择：Downloads，将“d:\Downloads\”写入参数，运行命令：“"d:\ProApps\Total Commander Ultima Prime\TOTALCMD64.EXE" /S %1”。目的是在激活到一栏（Total Commander 有两栏）打开“d:\Downloads\”。
; 2. 如果当前应用为 Cmder.exe，按 Alt＋F1，则弹出图形界面。读取“e:\Documents\Creations\Scripts\Attachment\Cmder Alt+F1.txt”，每一行为一个命令，如：“cd e:\Documents\Creations\Scripts\Python\”，弹出图形界面，可选择：“cd e:\Documents\Creations\Scripts\Python\”，将其写入剪贴板，粘贴到 Cmder.exe。
; 3. 如果当前应用为 Xshell.exe，按 Alt＋F1，则弹出图形界面。读取“e:\Documents\Creations\Scripts\Attachment\Xshell Alt+F1.txt”，每一行为一个命令，如：“docker compose up -d”，弹出图形界面，可选择：“docker compose up -d”，将其写入剪贴板，粘贴到 Xshell.exe。
; 4. 如果当前应用为 Notepad3.exe，按 Alt＋F1，则弹出图形界面。读取“e:\Documents\Creations\Scripts\Attachment\Notepad3 Alt+F1.txt”，每一行为一个地址，如：“Clips.txt=e:\Documents\Creations\Scripts\Attachment\Clips.txt”，弹出图形界面，可选择：Clips.txt，将“e:\Documents\Creations\Scripts\Attachment\Clips.txt” 用 Notepad3.exe 用新的窗口打开。
; 预设默认为第一行。

; Total Commander, Cmder, Xshell 和 Notepad3 Alt+F1 快速命令

; 全局变量
Global g_Commands := {}
Global g_ConfigFile := ""
Global g_GuiTitle := ""
Global g_AppType := "" ; "TC", "CMDER", "XSHELL", "NOTEPAD3"
Global g_LastClickTime := 0
Global g_LastClickItem := ""

; Total Commander 热键
#IfWinActive, ahk_class TTOTAL_CMD
!F1::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachment\Total Commander Ultima Prime Alt+F1.txt"
    g_GuiTitle := "Total Commander 快速跳转"
    g_AppType := "TC"
    ShowCommandSelector()
return
#IfWinActive

; Cmder 热键 - 使用更宽泛的窗口匹配
#If WinActive("ahk_exe Cmder.exe") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_class ConsoleWindowClass")
!F1::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachment\Cmder Alt+F1.txt"
    g_GuiTitle := "Cmder 快速命令"
    g_AppType := "CMDER"
    ShowCommandSelector()
return
#If

; Xshell 热键
#IfWinActive, ahk_exe Xshell.exe
!F1::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachment\Xshell Alt+F1.txt"
    g_GuiTitle := "Xshell 快速命令"
    g_AppType := "XSHELL"
    ShowCommandSelector()
return
#IfWinActive

; Notepad3 热键
#IfWinActive, ahk_exe Notepad3.exe
!F1::
    g_ConfigFile := "e:\Documents\Creations\Scripts\Attachment\Notepad3 Alt+F1.txt"
    g_GuiTitle := "Notepad3 快速打开"
    g_AppType := "NOTEPAD3"
    ShowCommandSelector()
return
#IfWinActive

; 显示命令选择器的函数
ShowCommandSelector()
{
    ; 使用全局变量
    Global g_Commands, g_ConfigFile, g_GuiTitle, g_AppType
    Global g_LastClickTime, g_LastClickItem
    
    ; 重置双击相关变量
    g_LastClickTime := 0
    g_LastClickItem := ""
    
    ; 读取配置文件
    FileRead, ConfigContent, %g_ConfigFile%
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
            
        ; 统一解析格式："显示名称=命令/路径"
        Pos := InStr(A_LoopField, "=")
        if (Pos > 0)
        {
            Name := Trim(SubStr(A_LoopField, 1, Pos-1))
            Command := Trim(SubStr(A_LoopField, Pos+1))
            
            ; 如果名称为空，则使用命令作为名称
            if (Name = "")
                Name := Command
                
            MenuItems.Push(Name)
            g_Commands[Name] := Command
        }
        else
        {
            ; 如果没有等号，整行作为名称和命令
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
    
    ; 创建图形界面
    Gui, CommandSelector:New
    Gui, CommandSelector:+AlwaysOnTop +ToolWindow
    Gui, CommandSelector:Font, s10, Segoe UI
    Gui, CommandSelector:Add, Text, w300 Center, 选择要执行的命令：
    
    ; 构建列表项字符串，默认选中第一项
    ListItems := JoinArray(MenuItems, "|")
    Gui, CommandSelector:Add, ListBox, w300 h200 vSelectedItem gOnItemSelect Choose1, %ListItems%
    
    Gui, CommandSelector:Add, Button, w140 h35 Default gExecuteCommand, 执行命令
    Gui, CommandSelector:Add, Button, x+20 w140 h35 gCancelSelector, 取消
    Gui, CommandSelector:Show, , %g_GuiTitle%
    return
}

; 项目选择事件（支持双击）
OnItemSelect:
    Gui, CommandSelector:Submit, NoHide
    Global g_LastClickTime, g_LastClickItem
    
    ; 检查是否为双击
    CurrentTime := A_TickCount
    If (g_LastClickItem = SelectedItem && CurrentTime - g_LastClickTime < 500) ; 500ms内再次点击同一项目视为双击
    {
        ; 重置双击相关变量
        g_LastClickTime := 0
        g_LastClickItem := ""
        
        ; 执行命令
        GoSub, ExecuteCommand
    }
    Else
    {
        ; 更新点击信息
        g_LastClickTime := CurrentTime
        g_LastClickItem := SelectedItem
    }
    return

; 执行命令
ExecuteCommand:
    Global g_Commands, g_AppType
    
    ; 确保GUI已提交，获取选中的项目
    Gui, CommandSelector:Submit, NoHide
    if (SelectedItem = "")
    {
        MsgBox, 请选择一个命令！
        return
    }
    
    ; 获取对应的命令
    Command := g_Commands[SelectedItem]
    
    ; 根据应用类型执行不同的操作
    if (g_AppType = "TC")
    {
        ; Total Commander: 运行命令打开目录
        TCExe := "d:\ProApps\Total Commander Ultima Prime\TOTALCMD64.EXE"
        Run, "%TCExe%" /S "%Command%"
    }
    else if (g_AppType = "CMDER" or g_AppType = "XSHELL")
    {
        ; Cmder 和 Xshell: 复制命令到剪贴板并粘贴
        Clipboard := Command
        Sleep, 100 ; 等待剪贴板更新
        
        ; 激活目标窗口并粘贴
        if (g_AppType = "CMDER")
        {
            ; 尝试多种方式激活Cmder窗口
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
        
        Sleep, 100 ; 等待窗口激活
        Send, ^v ; 粘贴命令（不自动按回车，允许用户修改）
    }
    else if (g_AppType = "NOTEPAD3")
    {
        ; Notepad3: 用新窗口打开文件
        Notepad3Exe := "d:\ProApps\Notepad3\Notepad3.exe"
        Run, "%Notepad3Exe%" "%Command%"
    }
    
    ; 关闭GUI
    Gui, CommandSelector:Destroy
    return

; 取消选择
CancelSelector:
    Gui, CommandSelector:Destroy
    return

; 辅助函数：将数组元素用指定分隔符连接
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