; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt＋t，读取剪贴板内容。弹出图形界面，可作选择：
; 1.将剪贴板内带格式的文字去除格式。
; 2. 将剪贴板内的文字，每个单词大写。
; 3. 将剪贴板内的文字，每个单词小写。
; 4. 将剪贴板内的文字，每个单词首字母大写，其余小写。
; 5. 将剪贴板内的文字，每个单词首字母大写，但虚词小写（a, an, the, and, or, for, nor, at, by, for, in, of, off, on, out, to, up, with, without, from, into, onto, over, upon, via, as）。修改后再次写入剪贴板。
; 6. 将剪贴板内文字，汉字、英文、或数字）用空格隔开。
; 7：将剪贴板内的汉字繁体中文转为简体中文。
; 8. 对于 ed2k 开头的链接，截取第 3 个“|”之后，至第 5 个“|”之前的字段。
; 9. 对于 magnet 开头的链接 ，截取 “magnet:?xt=urn:btih:”之后，至“&dn”之前的字段。
; 10. 将剪贴板内的文字，所有半角标点符号转为全角标点符号。（空格（ ），逗号（,），波浪号（~），冒号（:），分号（;），感叹号（!），问号（?），百分号（%），加号（+），减号（-），等号（=），斜杠（/），反斜杠（\），引号（""），括号（()），大于号（>），小于号（<）替换为全角符号（空格（　），逗号（，），波浪号（～），冒号（：），分号（；），感叹号（！），问号（？），百分号（％），加号（＋），减号（－），等号（＝），斜杠（／），反斜杠（＼），引号（“”），括号（（）），大于号（〉），小于号（〈））。
; 11. 删除“（Via：”之后的文字。
; 12. 删除 64 个字符后的内容。
; 13. 读取剪贴板内的内容，将单行多个数据（每个数据之间用半角逗号加空格隔开“, ”），将这组数据转换成多行数据，每一行为一个数据。
; 14. 将剪贴板内的多行文字，每一行行首增加两个空格加一个破折号及一个空格。（“  - ”）。
; 15. 读取剪贴板内的内容，进行升序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。
; 16. 读取剪贴板内的内容，进行降序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。
; 17. 读取剪贴板内的内容，将单行多个数据（每个数据之间用半角逗号加空格隔开“, ”），将这组数据转换成多行数据，并升序排序。每一行为一个数据。
; 18. 读取剪贴板内的内容，将空格转化为“%20”。

; 剪贴板多功能处理工具
; 快捷键: Alt + t

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
    Gui, Add, Radio, vAction Checked, 1. 去除文字格式
    Gui, Add, Radio,, 2. 每个单词全部大写
    Gui, Add, Radio,, 3. 每个单词全部小写
    Gui, Add, Radio,, 4. 每个单词首字母大写
    Gui, Add, Radio,, 5. 虚词小写处理（行首虚词首字母大写）
    Gui, Add, Radio,, 6. 中英数分隔
    Gui, Add, Radio,, 7. 繁体转简体
    Gui, Add, Radio,, 8. 提取 ed2k 字段
    Gui, Add, Radio,, 9. 提取 Magnet 哈希
    Gui, Add, Radio,, 10. 半角转全角标点
    Gui, Add, Radio,, 11. 删除 Via 并截断
    Gui, Add, Radio,, 12. 保留前 63 字符
    Gui, Add, Radio,, 13. 单行转多行
    Gui, Add, Radio,, 14. 行首添加"  - "
    Gui, Add, Radio,, 15. 数据升序排序
    Gui, Add, Radio,, 16. 数据降序排序
    Gui, Add, Radio,, 17. 单行转多行并升序
    Gui, Add, Radio,, 18. 空格转 URL 编码
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

        Case 2:  ; 每个单词全部大写
            StringUpper, processedText, processedText
        
        Case 3:  ; 每个单词全部小写
            StringLower, processedText, processedText
        
        Case 4:  ; 首字母大写
            StringUpper, processedText, processedText, T
        
        Case 5:  ; 虚词小写处理（行首虚词首字母大写）
            ; 首先将整个文本转换为首字母大写
            StringUpper, processedText, processedText, T
            
            ; 虚词列表（小写形式）
            conjunctions := ["a","an","the","and","or","for","nor","at","by","in","of","off","on","out","to","up","with","without","from","into","onto","over","upon","via","as"]
            
            ; 按行处理，每行独立处理
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            
            for _, line in lines
            {
                if (line = "")
                {
                    resultLines.Push("")
                    continue
                }
                
                ; 提取行首第一个单词（去除前导空格）
                if RegExMatch(line, "^\s*(\w+)", firstWordMatch)
                {
                    firstWord := firstWordMatch1
                    ; 将第一个单词转换为小写进行比较
                    StringLower, firstWordLower, firstWord
                    
                    ; 检查第一个单词是否是虚词
                    firstWordIsConjunction := false
                    for _, conjunction in conjunctions
                    {
                        if (firstWordLower = conjunction)
                        {
                            firstWordIsConjunction := true
                            break
                        }
                    }
                    
                    if firstWordIsConjunction
                    {
                        ; 对于虚词在行首的情况
                        ; 1. 先将整行所有虚词转为小写
                        for _, conjunction in conjunctions
                        {
                            ; 使用正则表达式匹配整个单词
                            line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                        }
                        
                        ; 2. 将行首的虚词重新首字母大写
                        ; 获取首字母并大写
                        firstLetter := SubStr(firstWordLower, 1, 1)
                        restOfWord := SubStr(firstWordLower, 2)
                        StringUpper, firstLetterUpper, firstLetter
                        capitalizedConjunction := firstLetterUpper . restOfWord
                        
                        ; 替换行首的虚词
                        line := RegExReplace(line, "^\s*" firstWordLower, firstWordMatch . capitalizedConjunction)
                    }
                    else
                    {
                        ; 行首不是虚词，直接将所有虚词转为小写
                        for _, conjunction in conjunctions
                        {
                            line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                        }
                    }
                }
                else
                {
                    ; 没有单词的行，直接处理所有虚词
                    for _, conjunction in conjunctions
                    {
                        line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                    }
                }
                
                resultLines.Push(line)
            }
            
            processedText := Join(resultLines, "`n")
        
        Case 6:  ; 中英数分隔（改进版，忽略标点符号）
            ; 定义标点符号模式（半角和全角）
            punctuation := ".,!?;:""'`~@#$%^&*()[]{}<>/\\|_-+= 　，。！？；：""'～＠＃＄％＾＆＊（）【】｛｝〈〉／＼｜－—＋＝"
            
            ; 汉字与英文/数字之间加空格（忽略标点）
            processedText := RegExReplace(processedText, "([\x{4e00}-\x{9fff}])(?=[a-zA-Z0-9])", "$1 ")
            processedText := RegExReplace(processedText, "(?<=[a-zA-Z0-9])([\x{4e00}-\x{9fff}])", " $1")
            
            ; 英文与数字之间加空格（忽略标点）
            processedText := RegExReplace(processedText, "([a-zA-Z])(?=\d)", "$1 ")
            processedText := RegExReplace(processedText, "(?<=\d)([a-zA-Z])", " $1")
            
            ; 清理多余空格
            processedText := RegExReplace(processedText, "\s+", " ")
            processedText := Trim(processedText)

        Case 7:  ; 繁体转简体
            processedText := ConvertToSimplifiedChinese(processedText)
        
        Case 8:  ; ed2k 处理 - 多行支持
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            ed2kCount := 0
            
            for index, line in lines
            {
                line := Trim(line)
                if (SubStr(line, 1, 5) = "ed2k:")
                {
                    arr := StrSplit(line, "|")
                    if (arr.Length() >= 6)
                    {
                        resultLines.Push(arr[4] "|" arr[5])
                        ed2kCount++
                    }
                    else
                    {
                        resultLines.Push("; 无效ed2k链接: " line)
                    }
                }
                else if (line != "")
                {
                    resultLines.Push("; 非ed2k链接: " line)
                }
            }
            
            if (ed2kCount = 0)
            {
                MsgBox 未找到有效的ed2k链接
                processedText := originalClipboard
            }
            else
            {
                processedText := ""
                for index, line in resultLines
                {
                    processedText .= line "`n"
                }
                processedText := RTrim(processedText, "`n")
            }
        
        Case 9:  ; Magnet 处理 - 多行支持
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            magnetCount := 0
            
            for index, line in lines
            {
                line := Trim(line)
                if RegExMatch(line, "i)^magnet:\?xt=urn:btih:([^&]+)", match)
                {
                    resultLines.Push(match1)
                    magnetCount++
                }
                else if (line != "")
                {
                    resultLines.Push("; 非Magnet链接: " line)
                }
            }
            
            if (magnetCount = 0)
            {
                MsgBox 未找到有效的Magnet链接
                processedText := originalClipboard
            }
            else
            {
                processedText := ""
                for index, line in resultLines
                {
                    processedText .= line "`n"
                }
                processedText := RTrim(processedText, "`n")
            }

        Case 10:  ; 半角转全角标点
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
                replacement := (Mod(quoteCount, 2) = 1) ? "“" : "」"
                processedText := SubStr(processedText, 1, pos-1) . replacement . SubStr(processedText, pos+1)
                pos += StrLen(replacement)
            }
            
            ; 处理其他符号
            for half, full in symbols
            {
                escaped := RegExReplace(half, "[.*+?^${}()|[\]\\]", "\$0")
                processedText := RegExReplace(processedText, escaped, full)
            }

        Case 11:  ; 删除Via并截断
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

        Case 12:  ; 保留前64字符
            if (StrLen(processedText) > 63)
            {
                processedText := SubStr(processedText, 1, 63)
            }

        Case 13:  ; 单行转多行
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

        Case 14:  ; 行首添加"  - "
            processedText := RegExReplace(processedText, "m)^", "  - ")

        Case 15:  ; 升序排序
            processedText := SortClipboardText(processedText, "Asc")

        Case 16:  ; 降序排序
            processedText := SortClipboardText(processedText, "Desc")

        Case 17:  ; 单行转多行并升序排序
            if (InStr(processedText, "`n") || InStr(processedText, "`r"))
            {
                MsgBox 此功能仅支持单行数据
                processedText := originalClipboard
            }
            else
            {
                ; 先转换为多行
                array := StrSplit(processedText, ", ")
                processedText := ""
                for index, element in array
                {
                    element := Trim(element)
                    if (element != "")
                        processedText .= element . "`n"
                }
                processedText := RTrim(processedText, "`n")
                
                ; 然后升序排序
                processedText := SortClipboardText(processedText, "Asc")
            }

        Case 18:  ; 空格转URL编码
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