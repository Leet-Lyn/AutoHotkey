; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt + C，读取并显示当前目录下Clips.txt。根据后续选择写入剪贴板。再触发一次 Ctrl + V，粘贴。
; 按下 Alt + X，触发一次 Ctrl + C，将当前窗体可复制（块选）内容，写入剪贴板。并写入当前目录下Clips.txt，添加为末尾新的行。

!c::
    WinGet, activeHwnd, ID, A
    clipsFile := A_ScriptDir "\Clips.txt"
    
    IfNotExist, %clipsFile%
    {
        MsgBox Clips.txt文件不存在于当前目录！
        Return
    }
    
    FileRead, fileContent, *P65001 %clipsFile%
    clips := []
    Loop, Parse, fileContent, `n, `r
    {
        if (Trim(A_LoopField) != "")
            clips.Push(A_LoopField)
    }
    
    if (clips.Length() = 0)
    {
        MsgBox Clips.txt中没有有效内容！
        Return
    }
    
    Gui, ClipSelect:New, +AlwaysOnTop, 选择剪贴板内容
    Gui, Add, ListView, h200 w400 vMyListView AltSubmit -Multi, 可用片段|行号
    Loop % clips.Length()
    {
        LV_Add("", clips[A_Index], A_Index)
    }
    LV_ModifyCol(1, 380)
    LV_ModifyCol(2, 0)
    Gui, Add, Button, Default w80 gClipSelected, 确定
    Gui, Show
    ControlFocus, SysListView321, A
    Return

ClipSelectGuiContextMenu:
    if (A_GuiEvent = "DoubleClick")
    {
        Gosub ClipSelected
    }
    Return

ClipSelected:
    Gui, Submit, NoHide
    SelectedRow := LV_GetNext()
    if (SelectedRow = 0)
    {
        MsgBox 请先选择一个项目！
        Return
    }
    
    LV_GetText(selectedText, SelectedRow, 1)
    LV_GetText(rowIndex, SelectedRow, 2)
    
    Clipboard := ""
    Clipboard := clips[rowIndex]
    ClipWait, 1
    
    if (Clipboard != clips[rowIndex])
    {
        MsgBox 复制失败！请手动选择内容
        Return
    }
    
    ToolTip 已复制：%selectedText%
    SetTimer, RemoveClipToolTip, 2000
    Gui, Destroy
    
    WinActivate, ahk_id %activeHwnd%
    Sleep 100
    Send ^v
    Return

!x::
    WinGet, originalHwnd, ID, A
    ClipboardBackup := ClipboardAll
    
    Clipboard := ""
    Send ^c
    ClipWait, 2, 1  ; 延长等待时间
    
    if (Clipboard = "") {
        ToolTip 未捕获到有效内容!
        SetTimer, RemoveXToolTip, 1500
        Clipboard := ClipboardBackup
        return
    }
    
    cleanContent := RegExReplace(Clipboard, "[\r\n]+", "`n")
    cleanContent := Trim(cleanContent, " `t`n`r")
    
    if (StrLen(cleanContent) < 1) {
        ToolTip 内容为空未保存!
        SetTimer, RemoveXToolTip, 1500
        Clipboard := ClipboardBackup
        return
    }
    
    clipsFile := A_ScriptDir "\Clips.txt"
    
    ; 改进重复检测
    FileRead, existingContent, %clipsFile%
    existingContent := "`n" existingContent "`n"  ; 确保前后有换行符
    If InStr(existingContent, "`n" cleanContent "`n")
    {
        ToolTip 已存在相同内容!
        SetTimer, RemoveXToolTip, 1500
        Clipboard := ClipboardBackup
        return
    }
    
    ; 改进写入方式
    FileAppend, %cleanContent%`n, %clipsFile%, UTF-8
    
    Clipboard := ClipboardBackup
    WinActivate, ahk_id %originalHwnd%
    ToolTip 已保存内容!
    SetTimer, RemoveXToolTip, 1500
    Return

; 独立的ToolTip移除标签
RemoveClipToolTip:
RemoveXToolTip:
    ToolTip
    SetTimer, %A_ThisLabel%, Off
    Return