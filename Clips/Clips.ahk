; 请帮我写个 Autohotkey 脚本。当我按下 Crtl+Shift +A，读取并显示 当前目录下Clips.txt。根据后续选择写入剪贴板。

^+a::
    ; 获取当前脚本目录下的Clips.txt路径
    clipsFile := A_ScriptDir "\Clips.txt"
    
    ; 检查文件是否存在
    IfNotExist, %clipsFile%
    {
        MsgBox Clips.txt文件不存在于当前目录！
        Return
    }
    
    ; 读取文件内容并分割为数组
    FileRead, fileContent, %clipsFile%
    clips := []
    Loop, Parse, fileContent, `n, `r
    {
        ; 跳过空行
        if (Trim(A_LoopField) != "")
            clips.Push(A_LoopField)
    }
    
    ; 检查是否有有效内容
    if (clips.Length() = 0)
    {
        MsgBox Clips.txt中没有有效内容！
        Return
    }
    
    ; 创建选择界面
    Gui, ClipSelect:New, +AlwaysOnTop, 选择剪贴板内容
    Gui, Add, ListView, h200 w400 vMyListView AltSubmit -Multi, 可用片段|行号
    Loop % clips.Length()
    {
        LV_Add("", clips[A_Index], A_Index) ; 第二列为隐藏索引
    }
    LV_ModifyCol(1, 380)  ; 加宽内容列
    LV_ModifyCol(2, 0)     ; 隐藏索引列
    Gui, Add, Button, Default w80 gClipSelected, 确定
    Gui, Show
    ControlFocus, SysListView321, A  ; 确保焦点在列表
    Return

    ; 双击直接复制
    GuiContextMenu:
    if (A_GuiEvent = "DoubleClick")
    {
        Gosub ClipSelected
    }
    Return

    ClipSelected:
    Gui, Submit, NoHide
    ; 获取选中行号
    SelectedRow := LV_GetNext()
    if (SelectedRow = 0)
    {
        MsgBox 请先选择一个项目！
        Return
    }
    
    ; 获取实际内容
    LV_GetText(selectedText, SelectedRow, 1)
    LV_GetText(rowIndex, SelectedRow, 2)
    
    ; 双保险复制逻辑
    Clipboard := ""
    Clipboard := clips[rowIndex]  ; 通过数组索引复制
    ClipWait, 1  ; 等待剪贴板就绪
    
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
    Return

    RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
    Return