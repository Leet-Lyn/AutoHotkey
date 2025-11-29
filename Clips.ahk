; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt＋C，读取并显示当前目录下Clips.txt。根据后续选择写入剪贴板。再触发一次 Ctrl＋V，粘贴。

; Alt＋C 读取剪贴板记录并选择
!c::
    WinGet, activeHwnd, ID, A
    clipsFile := "e:\Documents\Creations\Scripts\Attachment\Clips.txt"
    
    ; 检查文件是否存在
    IfNotExist, %clipsFile%
    {
        MsgBox Clips.txt文件不存在于指定目录！
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
        MsgBox Clips.txt中没有有效内容！
        Return
    }
    
    ; 创建选择界面
    Gui, ClipSelect:New, +AlwaysOnTop, 选择剪贴板内容
    Gui, Add, ListView, h200 w400 vMyListView AltSubmit -Multi -Hdr gHandleDoubleClick, 内容|行号
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
    SetTimer, RemoveToolTip, 2000
    Gui, Destroy
    
    ; 自动粘贴到原窗口
    WinActivate, ahk_id %activeHwnd%
    Sleep 100
    Send ^v
    Return

; 工具提示清除
RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
    Return