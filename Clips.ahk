; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt＋C，读取并显示当前目录下.Clips.txt。根据后续选择写入剪贴板。再触发一次 Ctrl＋V，粘贴。
; 按下 Ctrl＋Alt＋C，触发一次 Ctrl＋C，将当前窗体可复制（块选）内容，写入剪贴板。并写入当前目录下.Clips.txt，添加为末尾新的行。

; Alt＋C 读取剪贴板记录并选择
!c::
    WinGet, activeHwnd, ID, A
    clipsFile := A_ScriptDir "\.Clips.txt"
    
    ; 检查文件是否存在
    IfNotExist, %clipsFile%
    {
        MsgBox .Clips.txt文件不存在于当前目录！
        Return
    }
    
    ; 读取文件内容（UTF-8编码）
    FileRead, fileContent, *P65001 %clipsFile%
    clips := []
    Loop, Parse, fileContent, `n, `r
    {
        if (Trim(A_LoopField) != "")
            clips.Push(A_LoopField)
    }
    
    ; 检查有效内容
    if (clips.Length() = 0)
    {
        MsgBox .Clips.txt中没有有效内容！
        Return
    }
    
    ; 创建选择界面
    Gui, ClipSelect:New, +AlwaysOnTop, 选择剪贴板内容
    Gui, Add, ListView, h200 w400 vMyListView AltSubmit -Multi gHandleDoubleClick, 可用片段|行号
    Loop % clips.Length()
    {
        LV_Add("", clips[A_Index], A_Index)
    }
    LV_ModifyCol(1, 380)  ; 调整列宽
    LV_ModifyCol(2, 0)    ; 隐藏行号列
    Gui, Add, Button, Default w80 gClipSelected, 确定
    Gui, Show
    ControlFocus, SysListView321, A  ; 自动聚焦列表
    Return

; 处理双击事件
HandleDoubleClick:
    if (A_GuiEvent = "DoubleClick")
    {
        Gosub ClipSelected
    }
    Return

; 确定按钮处理
ClipSelected:
    Gui, Submit, NoHide
    SelectedRow := LV_GetNext()
    if (SelectedRow = 0)
    {
        MsgBox 请先选择一个项目！
        Return
    }
    
    ; 获取选中内容
    LV_GetText(selectedText, SelectedRow, 1)
    LV_GetText(rowIndex, SelectedRow, 2)
    
    ; 写入剪贴板
    Clipboard := ""
    Clipboard := clips[rowIndex]
    ClipWait, 1
    
    ; 验证复制结果
    if (Clipboard != clips[rowIndex])
    {
        MsgBox 复制失败！请手动选择内容
        Return
    }
    
    ; 显示操作反馈
    ToolTip 已复制：%selectedText%
    SetTimer, RemoveClipToolTip, 2000
    Gui, Destroy
    
    ; 自动粘贴到原窗口
    WinActivate, ahk_id %activeHwnd%
    Sleep 100
    Send ^v
    Return

; Ctrl＋Alt＋C 保存剪贴板内容
; ^!c::
;     WinGet, originalHwnd, ID, A
;    ClipboardBackup := ClipboardAll
;    
;    ; 获取剪贴板内容
;    Clipboard := ""
;    Send ^c
;    ClipWait, 2, 1  ; 延长等待时间
;    
;    ; 有效性检查
;    if (Clipboard = "") {
;        ToolTip 未捕获到有效内容!
;        SetTimer, RemoveXToolTip, 1500
;        Clipboard := ClipboardBackup
;        return
;    }
;    
;    ; 清理内容格式
;    cleanContent := RegExReplace(Clipboard, "[\r\n]+", "`n")
;    cleanContent := Trim(cleanContent, " `t`n`r")
;    
;    ; 空内容检查
;    if (StrLen(cleanContent) < 1) {
;        ToolTip 内容为空未保存!
;        SetTimer, RemoveXToolTip, 1500
;        Clipboard := ClipboardBackup
;        return
;    }
;    
;    clipsFile := A_ScriptDir "\.Clips.txt"
;    
;    ; 重复内容检测
;    FileRead, existingContent, %clipsFile%
;    existingContent := "`n" existingContent "`n"  ; 标准化格式
;    If InStr(existingContent, "`n" cleanContent "`n")
;    {
;        ToolTip 已存在相同内容!
;        SetTimer, RemoveXToolTip, 1500
;        Clipboard := ClipboardBackup
;        return
;    }
;    
;    ; 追加写入文件
;    FileAppend, %cleanContent%`n, %clipsFile%, UTF-8
;    
;    ; 恢复剪贴板
;    Clipboard := ClipboardBackup
;    WinActivate, ahk_id %originalHwnd%
;    ToolTip 已保存内容!
;    SetTimer, RemoveXToolTip, 1500
;    Return

; 工具提示清除
RemoveClipToolTip:
;RemoveXToolTip:
    ToolTip
    SetTimer, %A_ThisLabel%, Off
    Return