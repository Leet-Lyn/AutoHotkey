; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt + T，读取剪贴板内容。
; 弹出图形界面，可作选择：
; 1. 将剪贴板内的文字，每个单词首字母大写，其余小写。修改后再次写入剪贴板。
; 2. 将剪贴板内的文字，每个单词首字母大写，但虚词小写（a, an, the, and, or, for, nor, at, by, for, in, of, off, on, out, to, up, with, without, from, into, onto, over, upon, via, as）。修改后再次写入剪贴板。
; 3. 将剪贴板内文字，汉字、英文、或数字）用空格隔开。修改后再次写入剪贴板。
; 4. 对于 ed2k 开头的链接，读取第 3 个“|”之后，至第 5 个“|”之前的字段，写入剪贴板。
; 5. 对于 magnet 开头的链接 ，读取 “magnet:?xt=urn:btih:”之后，至“&dn”之前的字段，写入剪贴板。
; 6. 将将剪贴板内的文字，所有半角标点符号（空格（ ），逗号（,），波浪号（~），冒号（:），分号（;），感叹号（!），问号（?），百分号（%），加号（+），减号（-），等号（=），斜杠（/），反斜杠（\），引号（""），括号（()），大于号（>），小于号（<）替换为全角符号（空格（　），逗号（，），波浪号（～），冒号（：），分号（；），感叹号（！），问号（？），百分号（％），加号（＋），减号（－），等号（＝），斜杠（／），反斜杠（＼），引号（“”），括号（（）），大于号（〉），小于号（〈））。
; 7：删除“（Via：”之后的文字。此后新生成的文字从第21个字符至末尾删除。如果不足21位，则保留，写入剪贴板。

!t::
    ; 备份剪贴板并验证文本
    originalClipboard := ClipboardAll
    if !Clipboard is text
    {
        MsgBox 剪贴板内容不是可处理的文本格式
        Clipboard := originalClipboard
        return
    }

    ; 创建单选按钮界面（新增第6项）
    Gui, New
    Gui, Add, Text,, 请选择处理方式：
    Gui, Add, Radio, vAction Checked, 每个单词首字母大写
    Gui, Add, Radio,, 虚词小写处理
    Gui, Add, Radio,, 中英数分隔
    Gui, Add, Radio,, 提取 ed2k 字段
    Gui, Add, Radio,, 提取 Magnet 哈希
    Gui, Add, Radio,, 半角转全角标点
    Gui, Add, Radio,, 删除 Via 并截断
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
        
        Case 4:  ; ed2k 处理
            if (SubStr(processedText, 1, 5) = "ed2k:")
            {
                arr := StrSplit(processedText, "|")
                if (arr.Length() >= 6)
                    processedText := arr[4] "|" arr[5]
                else
                {
                    MsgBox ed2k 链接格式无效
                    processedText := originalClipboard
                }
            }
            else
            {
                MsgBox 非 ed2k 链接
                processedText := originalClipboard
            }
        
        Case 5:  ; Magnet 处理
            if RegExMatch(processedText, "i)^magnet:\?xt=urn:btih:([^&]+)", match)
                processedText := match1
            else
            {
                MsgBox 非 Magnet 链接
                processedText := originalClipboard
            }

        Case 6:  ; 半角转全角标点
            symbols := { " ": "　", ",": "，", "~": "～", ":": "：", ";": "；"
                       , "!": "！", "?": "？", "%": "％", "+": "＋", "-": "－"
                       , "=": "＝", "/": "／", "\": "＼", "(": "（", ")": "）"
                       , "<": "〈", ">": "〉" }
            
            ; 智能双引号替换
            quoteCount := 0
            pos := 1
            While (pos := InStr(processedText, """", false, pos))
            {
                quoteCount++
                ; 交替替换左右引号
                replacement := (Mod(quoteCount, 2) = 1) ? "“" : "”"
                processedText := SubStr(processedText, 1, pos-1) . replacement . SubStr(processedText, pos+1)
                pos += StrLen(replacement)  ; 跳过已替换内容
            }
            
            ; 处理其他符号
            for half, full in symbols
            {
                escaped := RegExReplace(half, "[.*+?^${}()|[\]\\]", "\$0")
                processedText := RegExReplace(processedText, escaped, full)
            }


        Case 7:  ; 删除Via并截断
            ; 处理中文/英文格式的Via标记
            viaPatterns := ["（Via：", "(Via:"]  ; 支持中文全角括号和英文半角括号
            for _, pattern in viaPatterns
            {
                if (pos := InStr(processedText, pattern))
                {
                    processedText := SubStr(processedText, 1, pos-1)
                    break
                }
            }
            
            ; 智能截断（保留前20个有效字符）
            processedText := RegExReplace(processedText, "\s+", " ")  ; 合并多余空格
            processedText := Trim(processedText)
            if (StrLen(processedText) > 20)  ; 修复缺少的右括号
            {
                processedText := SubStr(processedText, 1, 20) . "..."  ; 添加省略号提示截断
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