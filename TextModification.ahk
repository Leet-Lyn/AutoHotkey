; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt + T，读取剪贴板内容。
; 弹出图形界面，可作选择：
; 1. 将剪贴板内的文字，每个单词首字母大写，其余小写。修改后再次写入剪贴板。
; 2. 将剪贴板内的文字，每个单词首字母大写，但虚词小写（a, an, the, and, or, for, nor, at, by, for, in, of, off, on, out, to, up, with, without, from, into, onto, over, upon, via, as）。修改后再次写入剪贴板。
; 3. 将剪贴板内文字，汉字、英文、或数字）用空格隔开。修改后再次写入剪贴板。
; 4. 对于 ed2k 开头的链接，读取第 3 个“|”之后，至第 5 个“|”之前的字段，写入剪贴板。
; 5. 对于 magnet 开头的链接 ，读取 “magnet:?xt=urn:btih:”之后，至“&dn”之前的字段，写入剪贴板。

; 快捷键 Alt+T 触发
!t::
    ; 备份剪贴板并验证文本
    originalClipboard := ClipboardAll
    if !Clipboard is text
    {
        MsgBox 剪贴板内容不是可处理的文本格式
        Clipboard := originalClipboard
        return
    }

    ; 创建单选按钮界面
    Gui, New
    Gui, Add, Text,, 请选择处理方式：
    Gui, Add, Radio, vAction Checked, 每个单词首字母大写
    Gui, Add, Radio,, 虚词小写处理
    Gui, Add, Radio,, 中英数分隔
    Gui, Add, Radio,, 提取ed2k字段
    Gui, Add, Radio,, 提取Magnet哈希
    Gui, Add, Button, Default w80, 确定
    Gui, Show,, 剪贴板处理工具
return

Button确定:
    Gui, Submit
    Gui, Destroy
    
    ; 保存处理结果
    processedText := Clipboard
    
    ; Switch 分支处理
    Switch Action
    {
        Case 1:  ; 首字母大写
            StringUpper, processedText, processedText, T
        
        Case 2:  ; 虚词小写处理
            StringUpper, processedText, processedText, T
            conjunctions := ["a","an","the","and","or","for","nor","at","by","in","of","off","on","out","to","up","with","without","from","into","onto","over","upon","via","as"]
            for _, word in conjunctions
                processedText := RegExReplace(processedText, "i)\b" word "\b", word)
        
        Case 3:  ; 中英数分隔
            processedText := RegExReplace(processedText, "([\x{4e00}-\x{9fff}])([^\x{4e00}-\x{9fff}])", "$1 $2")
            processedText := RegExReplace(processedText, "([^\x{4e00}-\x{9fff}])([\x{4e00}-\x{9fff}])", "$1 $2")
            processedText := RegExReplace(processedText, "([a-zA-Z])(\d)", "$1 $2")
            processedText := RegExReplace(processedText, "(\d)([a-zA-Z])", "$1 $2")
            processedText := RegExReplace(processedText, "\s+", " ")
            processedText := Trim(processedText)
        
        Case 4:  ; ed2k处理
            if (SubStr(processedText, 1, 5) = "ed2k:")
            {
                arr := StrSplit(processedText, "|")
                if (arr.Length() >= 6)
                    processedText := arr[4] "|" arr[5]
                else
                {
                    MsgBox ed2k链接格式无效
                    processedText := originalClipboard
                }
            }
            else
            {
                MsgBox 非ed2k链接
                processedText := originalClipboard
            }
        
        Case 5:  ; Magnet处理
            if RegExMatch(processedText, "i)^magnet:\?xt=urn:btih:([^&]+)", match)
                processedText := match1
            else
            {
                MsgBox 非Magnet链接
                processedText := originalClipboard
            }
    }

    ; 更新剪贴板并自动粘贴
    Clipboard := processedText
    Sleep 150
    Send, ^v  ; 自动执行粘贴操作

    ; 可选：3秒后恢复原内容
    ; SetTimer, RestoreClipboard, -3000
return

; 剪贴板恢复函数
RestoreClipboard:
    Clipboard := originalClipboard
return

GuiClose:
    Gui, Destroy
    Clipboard := originalClipboard
return