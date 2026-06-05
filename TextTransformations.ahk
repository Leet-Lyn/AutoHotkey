; 请帮我写个 Autohotkey 脚本。
; 当我按下 Win＋T，读取剪贴板内容。弹出图形界面，可选择 15 种文字变换，结果写回剪贴板并粘贴。

; Win+T 剪贴板文字变换

; 全局变量
Global g_LastClickTime := 0
Global g_LastClickItem := ""
Global g_ShortcutKeys := {}      ; 按键字符 -> 纯名称
Global g_GuiHwnd := 0
Global g_ActiveHwnd := 0
Global g_OriginalClipboard      ; 原始剪贴板备份（ClipboardAll）
Global g_ClipboardText := ""    ; 读入的纯文本

; 15 种变换的显示名称（与下方 Switch case 一一对应）
Global g_TransformNames := ["去除文字格式"
    , "每个单词全部大写"
    , "每个单词全部小写"
    , "每个单词首字母大写"
    , "虚词小写处理"
    , "中英数分隔"
    , "驼峰命名分隔"
    , "繁体转简体"
    , "提取 ed2k 字段"
    , "提取 Magnet 哈希"
    , "标点半角转全角"
    , "半角逗号加空格转换行"
    , "空格转 URL 编码"
    , "删除 Via 并截断"
    , "保留前 63 字符" ]

; 注册键盘消息钩子（0-9/a-z 快捷键 + ESC 退出）
OnMessage(0x0100, "OnGuiKey")

; Win+T 热键
#t::
    g_OriginalClipboard := ClipboardAll
    if !Clipboard is text
    {
        Clipboard := g_OriginalClipboard
        MsgBox, 剪贴板内容不是可处理的文本格式！
        return
    }
    ClipWait, 0.5
    g_ClipboardText := Clipboard
    WinGet, g_ActiveHwnd, ID, A
    ShowTransformSelector()
return

; 显示变换选择器
ShowTransformSelector()
{
    Global g_LastClickTime, g_LastClickItem
    Global g_ShortcutKeys, g_GuiHwnd
    Global g_TransformNames

    g_LastClickTime := 0
    g_LastClickItem := ""

    ; 构建带快捷键前缀的显示列表
    shortcutChars := "0123456789abcdefghijklmnopqrstuvwxyz"
    g_ShortcutKeys := {}
    DisplayItems := []

    Loop % g_TransformNames.Length()
    {
        Name := g_TransformNames[A_Index]
        if (A_Index <= 36)
        {
            Char := SubStr(shortcutChars, A_Index, 1)
            g_ShortcutKeys[Char] := Name
            DisplayItems.Push("[" Char "] " Name)
        }
        else
        {
            DisplayItems.Push("    " Name)
        }
    }

    ; 销毁旧窗口
    Gui, TransformSelect:Destroy

    ; 创建图形界面
    Gui, TransformSelect:New
    Gui, TransformSelect:+AlwaysOnTop +ToolWindow
    Gui, TransformSelect:Font, s10, Segoe UI
    Gui, TransformSelect:Add, Text, w420 Center, 选择文字变换（0-9/a-z 直达，空格执行，ESC 退出）：

    ListItems := JoinArray(DisplayItems, "|")
    Gui, TransformSelect:Add, ListBox, w640 h480 vSelectedItem gOnItemSelect Choose1, %ListItems%

    Gui, TransformSelect:Add, Button, w150 h35 Default gExecuteTransform, 执行(&E)
    Gui, TransformSelect:Add, Button, x+20 w150 h35 gCancelSelector, 取消(&C)
    Gui, TransformSelect:Show, , 剪贴板文字变换

    ; 捕获 HWND
    g_GuiHwnd := WinExist("A")
    return
}

; 项目选择事件（支持双击）
OnItemSelect:
    Gui, TransformSelect:Submit, NoHide
    Global g_LastClickTime, g_LastClickItem

    CurrentTime := A_TickCount
    If (g_LastClickItem = SelectedItem && CurrentTime - g_LastClickTime < 500)
    {
        g_LastClickTime := 0
        g_LastClickItem := ""
        GoSub, ExecuteTransform
    }
    Else
    {
        g_LastClickTime := CurrentTime
        g_LastClickItem := SelectedItem
    }
    return

; 执行变换
ExecuteTransform:
    Global g_GuiHwnd, g_ActiveHwnd
    Global g_ClipboardText, g_OriginalClipboard, g_TransformNames

    Gui, TransformSelect:Submit, NoHide
    if (SelectedItem = "")
    {
        MsgBox, 请选择一个变换！
        return
    }

    ; 剥离快捷键前缀 "[x] "
    Name := SelectedItem
    if (SubStr(Name, 1, 1) = "[" && SubStr(Name, 3, 2) = "] ")
        Name := SubStr(Name, 5)

    ; 找到变换编号
    Action := 0
    Loop % g_TransformNames.Length()
    {
        if (g_TransformNames[A_Index] = Name)
        {
            Action := A_Index
            break
        }
    }

    if (Action = 0)
    {
        MsgBox, 未知变换：%Name%
        return
    }

    ; 执行变换
    processedText := g_ClipboardText

    Switch Action
    {
        Case 1:  ; 去除文字格式
            Clipboard := processedText
            ClipWait, 1
            processedText := Clipboard

        Case 2:  ; 每个单词全部大写
            StringUpper, processedText, processedText

        Case 3:  ; 每个单词全部小写
            StringLower, processedText, processedText

        Case 4:  ; 首字母大写
            StringUpper, processedText, processedText, T

        Case 5:  ; 虚词小写处理
            StringUpper, processedText, processedText, T
            conjunctions := ["a","an","the","and","or","for","nor","at","by","in","of","off","on","out","to","up","with","without","from","into","onto","over","upon","via","as"]
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            for _, line in lines
            {
                if (line = "")
                {
                    resultLines.Push("")
                    continue
                }
                if RegExMatch(line, "^\s*(\w+)", firstWordMatch)
                {
                    firstWord := firstWordMatch1
                    StringLower, firstWordLower, firstWord
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
                        for _, conjunction in conjunctions
                            line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                        RegExMatch(line, "^(\s*)", leadingSpaces)
                        firstLetter := SubStr(firstWordLower, 1, 1)
                        restOfWord := SubStr(firstWordLower, 2)
                        StringUpper, firstLetterUpper, firstLetter
                        capitalizedConjunction := firstLetterUpper . restOfWord
                        line := RegExReplace(line, "^\s*" firstWordLower, leadingSpaces . capitalizedConjunction)
                    }
                    else
                    {
                        for _, conjunction in conjunctions
                            line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                    }
                }
                else
                {
                    for _, conjunction in conjunctions
                        line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                }
                resultLines.Push(line)
            }
            processedText := Join(resultLines, "`n")

        Case 6:  ; 中英数分隔
            processedText := RegExReplace(processedText, "([\x{4e00}-\x{9fff}])(?=[a-zA-Z0-9])", "$1 ")
            processedText := RegExReplace(processedText, "(?<=[a-zA-Z0-9])([\x{4e00}-\x{9fff}])", " $1")
            processedText := RegExReplace(processedText, "([a-zA-Z])(?=\d)", "$1 ")
            processedText := RegExReplace(processedText, "(?<=\d)([a-zA-Z])", " $1")
            processedText := RegExReplace(processedText, "\s+", " ")
            processedText := Trim(processedText)

        Case 7:  ; 驼峰命名分隔
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            for _, line in lines
            {
                if (line = "")
                {
                    resultLines.Push("")
                    continue
                }
                line := RegExReplace(line, "([a-z])([A-Z])", "$1 $2")
                line := RegExReplace(line, "([A-Z])([A-Z][a-z])", "$1 $2")
                line := RegExReplace(line, "([a-zA-Z])(\d)", "$1 $2")
                line := RegExReplace(line, "(\d)([a-zA-Z])", "$1 $2")
                line := RegExReplace(line, "\s+", " ")
                line := Trim(line)
                resultLines.Push(line)
            }
            processedText := Join(resultLines, "`n")

        Case 8:  ; 繁体转简体
            processedText := ConvertToSimplifiedChinese(processedText)

        Case 9:  ; ed2k 字段
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            ed2kCount := 0
            for _, line in lines
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
                        resultLines.Push("; 无效ed2k: " line)
                }
                else if (line != "")
                    resultLines.Push("; 非ed2k: " line)
            }
            if (ed2kCount = 0)
            {
                MsgBox, 未找到有效的 ed2k 链接！
                processedText := g_ClipboardText
            }
            else
            {
                processedText := ""
                for _, line in resultLines
                    processedText .= line "`n"
                processedText := RTrim(processedText, "`n")
            }

        Case 10:  ; Magnet 哈希
            lines := StrSplit(processedText, "`n", "`r")
            resultLines := []
            magnetCount := 0
            for _, line in lines
            {
                line := Trim(line)
                if RegExMatch(line, "i)^magnet:\?xt=urn:btih:([^&]+)", match)
                {
                    resultLines.Push(match1)
                    magnetCount++
                }
                else if (line != "")
                    resultLines.Push("; 非Magnet: " line)
            }
            if (magnetCount = 0)
            {
                MsgBox, 未找到有效的 Magnet 链接！
                processedText := g_ClipboardText
            }
            else
            {
                processedText := ""
                for _, line in resultLines
                    processedText .= line "`n"
                processedText := RTrim(processedText, "`n")
            }

        Case 11:  ; 半角转全角标点
            symbols := { " ": "　", ",": "，", "~": "～", ":": "：", ";": "；"
                       , "!": "！", "?": "？", "%": "％", "+": "＋", "-": "－"
                       , "=": "＝", "/": "／", "\": "＼", "(": "（", ")": "）"
                       , "<": "〈", ">": "〉" }
            quoteCount := 0
            pos := 1
            While (pos := InStr(processedText, """", false, pos))
            {
                quoteCount++
                replacement := (Mod(quoteCount, 2) = 1) ? "`u201C" : "`u201D"
                processedText := SubStr(processedText, 1, pos-1) . replacement . SubStr(processedText, pos+1)
                pos += StrLen(replacement)
            }
            for half, full in symbols
            {
                escaped := RegExReplace(half, "[.*+?^${}()|[\]\\]", "\$0")
                processedText := RegExReplace(processedText, escaped, full)
            }

        Case 12:  ; 半角逗号+空格转行
            processedText := RegExReplace(processedText, ", ", "`r`n")

        Case 13:  ; 空格转 URL 编码
            processedText := StrReplace(processedText, " ", "%20")

        Case 14:  ; 删除 Via 并截断
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
                processedText := SubStr(processedText, 1, 20) . "..."

        Case 15:  ; 保留前 63 字符
            if (StrLen(processedText) > 63)
                processedText := SubStr(processedText, 1, 63)
    }

    ; 写回剪贴板
    Clipboard := processedText

    ; 隐藏 GUI
    g_GuiHwnd := 0
    Gui, TransformSelect:Hide

    ; 粘贴到原窗口
    WinActivate, ahk_id %g_ActiveHwnd%
    Sleep, 150
    Send, ^v

    Gui, TransformSelect:Destroy
    return

; 取消 / 关闭（恢复原剪贴板）
CancelSelector:
GuiClose:
GuiEscape:
    Global g_GuiHwnd, g_OriginalClipboard
    g_GuiHwnd := 0
    Clipboard := g_OriginalClipboard
    Gui, TransformSelect:Destroy
    return

; 辅助函数
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

Join(array, delimiter)
{
    result := ""
    Loop % array.Length()
    {
        if (A_Index > 1)
            result .= delimiter
        result .= array[A_Index]
    }
    return result
}

; 简繁转换
ConvertToSimplifiedChinese(text)
{
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
    if (ret > 0)
        return StrGet(&destBuf, ret, "UTF-16")
    else
    {
        MsgBox, 0x40000, 转换错误, 简繁转换失败，错误代码：%A_LastError%
        return text
    }
}

; ==================== 键盘钩子 ====================
OnGuiKey(wParam, lParam, msg, hwnd)
{
    Global g_GuiHwnd, g_ShortcutKeys, SelectedItem

    ; GUI 未打开 -> 放行
    if (!g_GuiHwnd)
        return

    ; ESC -> 关闭 GUI
    if (wParam = 0x1B)
    {
        Global g_OriginalClipboard
        g_GuiHwnd := 0
        Clipboard := g_OriginalClipboard
        Gui, TransformSelect:Destroy
        return 0
    }

    ; 只拦截 GUI 为前台时
    if (!WinActive("ahk_id " g_GuiHwnd))
        return

    ; 空格键 -> 执行当前项
    if (wParam = 0x20)
    {
        SetTimer, ExecuteTransform, -10
        return 0
    }

    key := ""

    ; 数字 0-9
    if (wParam >= 0x30 && wParam <= 0x39)
        key := Chr(wParam)

    ; 字母 a-z
    if (wParam >= 0x41 && wParam <= 0x5A)
        key := Chr(wParam + 32)

    if (key = "")
        return

    ; 匹配快捷键 -> 选中并执行
    if (g_ShortcutKeys.HasKey(key))
    {
        GuiControl, ChooseString, SelectedItem, % g_ShortcutKeys[key]
        SetTimer, ExecuteTransform, -10
        return 0
    }

    return
}