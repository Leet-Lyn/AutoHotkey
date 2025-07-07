; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt＋v，读取剪贴板内容。
; 弹出图形界面，可作选择：
; 1.将剪贴板内带格式的文字去除格式。
; 2. 将剪贴板内的文字，每个单词首字母大写，其余小写。修改后再次写入剪贴板。
; 3. 将剪贴板内的文字，每个单词首字母大写，但虚词小写（a, an, the, and, or, for, nor, at, by, for, in, of, off, on, out, to, up, with, without, from, into, onto, over, upon, via, as）。修改后再次写入剪贴板。
; 4. 将剪贴板内文字，汉字、英文、或数字）用空格隔开。修改后再次写入剪贴板。
; 5：将剪贴板内的汉字繁体中文转为简体中文。
; 6. 对于 ed2k 开头的链接，读取第 3 个“|”之后，至第 5 个“|”之前的字段，写入剪贴板。
; 7. 对于 magnet 开头的链接 ，读取 “magnet:?xt=urn:btih:”之后，至“&dn”之前的字段，写入剪贴板。
; 8. 将将剪贴板内的文字，所有半角标点符号（空格（ ），逗号（,），波浪号（~），冒号（:），分号（;），感叹号（!），问号（?），百分号（%），加号（+），减号（-），等号（=），斜杠（/），反斜杠（\），引号（""），括号（()），大于号（>），小于号（<）替换为全角符号（空格（　），逗号（，），波浪号（～），冒号（：），分号（；），感叹号（！），问号（？），百分号（％），加号（＋），减号（－），等号（＝），斜杠（／），反斜杠（＼），引号（“”），括号（（）），大于号（〉），小于号（〈））。
; 9. 删除“（Via：”之后的文字。此后新生成的文字从第21个字符至末尾删除。如果不足21位，则保留，写入剪贴板。
; 10. 读取剪贴板内的内容，将单行多个数据（每个数据之间用半角逗号加空格隔开“, ”），将这组数据转换成多行数据，每一行为一个数据。
; 11. 将剪贴板内的多行文字，每一行行首增加两个空格加一个破折号及一个空格。（“  - ”）。
; 12. 读取剪贴板内的内容，进行升序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。
; 13. 读取剪贴板内的内容，进行降序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。
; 14. 读取剪贴板内的内容，将单行多个数据（每个数据之间用半角逗号加空格隔开“, ”），将这组数据转换成多行数据，并升序排序。每一行为一个数据。
; 15. 读取剪贴板内的内容，将空格转化为“%20”。

; 剪贴板多功能处理工具
; 快捷键: Alt + V

!v::
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
    Gui, Add, Radio, vAction Checked, 1. 去除文字格式
    Gui, Add, Radio,, 2. 每个单词首字母大写
    Gui, Add, Radio,, 3. 虚词小写处理
    Gui, Add, Radio,, 4. 中英数分隔
    Gui, Add, Radio,, 5. 繁体转简体
    Gui, Add, Radio,, 6. 提取 ed2k 字段
    Gui, Add, Radio,, 7. 提取 Magnet 哈希
    Gui, Add, Radio,, 8. 半角转全角标点
    Gui, Add, Radio,, 9. 删除 Via 并截断
    Gui, Add, Radio,, 10. 单行转多行
    Gui, Add, Radio,, 11. 行首添加"  - "
    Gui, Add, Radio,, 12. 数据升序排序
    Gui, Add, Radio,, 13. 数据降序排序
    Gui, Add, Radio,, 14. 空格转URL编码
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
        Case 1:  ; 去除文字格式
            Clipboard := Clipboard
            ClipWait, 1, 1
            if ErrorLevel
                processedText := originalClipboard
            else
                processedText := Clipboard

        Case 2:  ; 首字母大写
            StringUpper, processedText, processedText, T
        
        Case 3:  ; 虚词小写处理
            StringUpper, processedText, processedText, T
            conjunctions := ["a","an","the","and","or","for","nor","at","by","in","of","off","on","out","to","up","with","without","from","into","onto","over","upon","via","as"]
            for _, word in conjunctions
                processedText := RegExReplace(processedText, "i)\b" word "\b", word)
        
        Case 4:  ; 中英数分隔
            processedText := RegExReplace(processedText, "([\x{4e00}-\x{9fff}])([^\x{4e00}-\x{9fff}])", "$1 $2")
            processedText := RegExReplace(processedText, "([^\x{4e00}-\x{9fff}])([\x{4e00}-\x{9fff}])", "$1 $2")
            processedText := RegExReplace(processedText, "([a-zA-Z])(\d)", "$1 $2")
            processedText := RegExReplace(processedText, "(\d)([a-zA-Z])", "$1 $2")
            processedText := RegExReplace(processedText, "\s+", " ")
            processedText := Trim(processedText)

        Case 5:  ; 繁体转简体
            processedText := ConvertToSimplifiedChinese(processedText)
        
        Case 6:  ; ed2k 处理
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
        
        Case 7:  ; Magnet 处理
            if RegExMatch(processedText, "i)^magnet:\?xt=urn:btih:([^&]+)", match)
                processedText := match1
            else
            {
                MsgBox 非 Magnet 链接
                processedText := originalClipboard
            }

        Case 8:  ; 半角转全角标点
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
                replacement := (Mod(quoteCount, 2) = 1) ? "“" : "”"
                processedText := SubStr(processedText, 1, pos-1) . replacement . SubStr(processedText, pos+1)
                pos += StrLen(replacement)
            }
            
            ; 处理其他符号
            for half, full in symbols
            {
                escaped := RegExReplace(half, "[.*+?^${}()|[\]\\]", "\$0")
                processedText := RegExReplace(processedText, escaped, full)
            }

        Case 9:  ; 删除Via并截断
            viaPatterns := ["（Via：", "(Via:"]
            for _, pattern in viaPatterns
            {
                if (pos := InStr(processedText, pattern))
                {
                    processedText := SubStr(processedText, 1, pos-1)
                    break
                }
            }
            
            processedText := RegExReplace(processedText, "\s+", " ")
            processedText := Trim(processedText)
            if (StrLen(processedText) > 20)
            {
                processedText := SubStr(processedText, 1, 20) . "..."
            }

        Case 10:  ; 单行转多行
            if (InStr(processedText, "`n") || InStr(processedText, "`r"))
            {
                MsgBox 此功能仅支持单行数据
                processedText := originalClipboard
            }
            else
            {
                array := StrSplit(processedText, ", ")
                processedText := ""
                for index, element in array
                {
                    element := Trim(element)
                    if (element != "")
                        processedText .= element . "`n"
                }
                processedText := RTrim(processedText, "`n")
            }

        Case 11:  ; 行首添加"  - "
            processedText := RegExReplace(processedText, "m)^", "  - ")

        Case 12:  ; 升序排序
            processedText := SortClipboardText(processedText, "Asc")

        Case 13:  ; 降序排序
            processedText := SortClipboardText(processedText, "Desc")

        Case 14:  ; 空格转URL编码
            processedText := StrReplace(processedText, " ", "%20")
    }

    ; 更新剪贴板并自动粘贴
    Clipboard := processedText
    Sleep 150
    Send, ^v

    ; 可选：3秒后恢复原内容
    ; SetTimer, RestoreClipboard, -3000
return

; 剪贴板恢复函数
RestoreClipboard:
    Clipboard := originalClipboard
return

; 排序功能函数
SortClipboardText(text, order) {
    isMultiLine := InStr(text, "`n") ? 1 : 0
    
    if isMultiLine
        array := StrSplit(text, "`n", "`r")
    else
        array := StrSplit(text, ", ")
    
    cleanedArray := []
    Loop % array.Length()
    {
        element := Trim(array[A_Index])
        if StrLen(element)
            cleanedArray.Push(element)
    }
    
    sortedText := Join(cleanedArray, "`n")
    if (order = "Asc")
        Sort, sortedText, CL
    else
        Sort, sortedText, CL R
    
    sortedArray := StrSplit(sortedText, "`n")
    if isMultiLine
        return Join(sortedArray, "`n")
    else
        return Join(sortedArray, ", ")
}

Join(array, delimiter) {
    result := ""
    Loop % array.Length()
    {
        if (A_Index > 1)
            result .= delimiter
        result .= array[A_Index]
    }
    return result
}

; 简繁转换函数
ConvertToSimplifiedChinese(text) {
    flags := 0x2000000  ; LCMAP_SIMPLIFIED_CHINESE
    locale := 0x0804     ; 简体中文
    
    charCount := StrLen(text)
    bufSize := (charCount + 1) * 4
    VarSetCapacity(srcBuf, bufSize, 0)
    VarSetCapacity(destBuf, bufSize, 0)
    
    StrPut(text, &srcBuf, charCount + 1, "UTF-16")
    
    ret := DllCall("Kernel32.dll\LCMapStringW"
        , "UInt", locale
        , "UInt", flags
        , "Ptr", &srcBuf
        , "Int", charCount
        , "Ptr", &destBuf
        , "Int", charCount
        , "Ptr", 0)
    
    if (ret > 0) {
        return StrGet(&destBuf, ret, "UTF-16")
    }
    else {
        MsgBox 0x40000, 转换错误, 简繁转换失败，错误代码：%A_LastError%
        return text
    }
}

GuiClose:
    Gui, Destroy
    Clipboard := originalClipboard
return