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
; 10. 将剪贴板内的多行文字，每一行行首增加一个破折号及一个空格。
; 11. 将剪贴板内的多行文字，每一行行首增加两个空格。
; 12. 读取剪贴板内的内容，进行升序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。
; 13. 读取剪贴板内的内容，进行降序排序。如果是单行数据，则这组数据（每个数据之间用半角逗号加空格隔开“, ”），对这组数据排序，仍然以半角逗号加空格隔开。如果是多行数据，则这组数据（每一行为一个数据），对这组数据排序，仍然每一行为一个数据。

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
    Gui, Add, Radio,vAction Checked, 1. 去除文字格式
    Gui, Add, Radio,, 2. 每个单词首字母大写
    Gui, Add, Radio,, 3. 虚词小写处理
    Gui, Add, Radio,, 4. 中英数分隔
    Gui, Add, Radio,, 5. 繁体转简体
    Gui, Add, Radio,, 6. 提取 ed2k 字段
    Gui, Add, Radio,, 7. 提取 Magnet 哈希
    Gui, Add, Radio,, 8. 半角转全角标点
    Gui, Add, Radio,, 9. 删除 Via 并截断
    Gui, Add, Radio,, 10. 行首添加一个破折号及一个空格
    Gui, Add, Radio,, 11. 行首添加两个空格
    Gui, Add, Radio,, 12. 数据升序排序
    Gui, Add, Radio,, 13. 数据降序排序
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
            ; 方法1：通过文本中转（适用于大部分场景）
            Clipboard := Clipboard
            
            ; 方法2：更彻底的格式清除（需要等待剪贴板更新）
            /*
            tempFile := A_Temp "\~tempClip.txt"
            FileDelete, %tempFile%
            RunWait, %ComSpec% /c clip < "%tempFile%",, Hide  ; 清空剪贴板
            Sleep 100
            Send, ^c  ; 重新复制（可能需要根据具体应用调整）
            Sleep 100
            processedText := Clipboard
            */
            
            ; 等待剪贴板稳定
            ClipWait, 1, 1
            if ErrorLevel
            {
                MsgBox 无法获取纯文本内容
                processedText := originalClipboard
            }
            else
            {
                processedText := Clipboard
            }

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

        Case 10:  ; 行首添加一个破折号及一个空格
            processedText := RegExReplace(processedText, "m)^", "- ")

        Case 11:  ; 行首添加两个空格
            processedText := RegExReplace(processedText, "m)^", "  ")

        Case 12:  ; 升序排序
            processedText := SortClipboardText(processedText, "Asc")

        Case 13:  ; 降序排序
            processedText := SortClipboardText(processedText, "Desc")

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
    ; 判断内容类型
    isMultiLine := InStr(text, "`n") ? 1 : 0
    
    ; 分割数据
    if isMultiLine
        array := StrSplit(text, "`n", "`r")
    else
        array := StrSplit(text, ", ")
    
    ; 清理数据
    cleanedArray := []
    Loop % array.Length()
    {
        element := Trim(array[A_Index])
        if StrLen(element)
            cleanedArray.Push(element)
    }
    
    ; 执行排序
    sortedText := Join(cleanedArray, "`n")
    if (order = "Asc")
        Sort, sortedText, CL
    else
        Sort, sortedText, CL R
    
    ; 重组格式
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
    ; 参数设置
    flags := 0x2000000  ; LCMAP_SIMPLIFIED_CHINESE
    locale := 0x0804     ; 简体中文
    
    ; 计算字符长度（UTF-16编码）
    charCount := StrLen(text)
    
    ; 准备缓冲区（双倍长度保险）
    bufSize := (charCount + 1) * 4  ; 每个字符2字节＋缓冲区溢出保护
    VarSetCapacity(srcBuf, bufSize, 0)
    VarSetCapacity(destBuf, bufSize, 0)
    
    ; 写入源字符串（直接使用Unicode）
    StrPut(text, &srcBuf, charCount + 1, "UTF-16")
    
    ; 调用系统API（使用宽字符版本）
    ret := DllCall("Kernel32.dll\LCMapStringW"
        , "UInt", locale    ; 强制使用简体中文区域
        , "UInt", flags
        , "Ptr", &srcBuf
        , "Int", charCount
        , "Ptr", &destBuf
        , "Int", charCount
        , "Ptr", 0)
    
    ; 处理结果
    if (ret > 0) {
        return StrGet(&destBuf, ret, "UTF-16")
    }
    else {
        ; 显示错误信息但继续执行
        MsgBox 0x40000, 转换错误, 简繁转换失败，错误代码：%A_LastError%
        return text
    }
}

GuiClose:
    Gui, Destroy
    Clipboard := originalClipboard
return