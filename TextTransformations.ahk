#Requires AutoHotkey v2.0

; ============================================================
; TextTransformations.ahk
; Win+T — 读取剪贴板文本，弹出 15 种变换菜单，结果写回剪贴板并粘贴
; 索引: 0~9, a~e (共15项)
; 空格/回车/双击 → 执行变换 → Ctrl+V 粘贴
; Esc/关闭 → 恢复原剪贴板
; ============================================================

#t:: {
    ; ---------- 备份原剪贴板 ----------
    ClipSaved := ClipboardAll()
    clipText := A_Clipboard

    if (clipText = "") {
        A_Clipboard := ClipSaved
        MsgBox("剪贴板内容为空，或不是可处理的文本格式！", "错误", "Icon!")
        return
    }

    ; 获取当前活动窗口
    activeHwnd := WinGetID("A")

    ; ---------- 15 种变换 ----------
    transformNames := [
        "去除文字格式",
        "每个单词全部大写",
        "每个单词全部小写",
        "每个单词首字母大写",
        "虚词小写处理",
        "中英数分隔",
        "驼峰命名分隔",
        "繁体转简体",
        "提取 ed2k 字段",
        "提取 Magnet 哈希",
        "标点半角转全角",
        "半角逗号加空格转换行",
        "空格转 URL 编码",
        "删除 Via 并截断",
        "保留前 63 字符"
    ]

    ; 索引标签: 0~9, a~e
    labels := ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e"]

    ; ---------- 创建 GUI ----------
    g := Gui()
    g.Title := "剪贴板文字变换  [0-9 a-e 导航 | 空格/回车执行 | Esc 取消]"
    g.SetFont("s10", "Microsoft YaHei")
    g.MarginX := 12
    g.MarginY := 10

    g.AddText("", "索引 `t变换名称（双击或回车/空格 直接执行）")
    g.AddText("", "————————————————————————————————————————————")

    LV := g.AddListView("r15 w700 -Hdr Grid NoSort", ["Idx", "变换"])
    LV.ModifyCol(1, 45)
    LV.ModifyCol(2, 640)

    for i, name in transformNames {
        idx := i <= labels.Length ? labels[i] : "?"
        LV.Add(, idx, name)
    }

    ; 保存引用供模块级函数使用
    global gHwnd := g.Hwnd
    global gLV := LV
    global g := g
    global gClipText := clipText
    global gClipSaved := ClipSaved
    global gActiveHwnd := activeHwnd
    global gTransformNames := transformNames

    ; ---------- 事件 ----------
    LV.OnEvent("DoubleClick", LV_DoubleClick)
    LV_DoubleClick(LV, RowNumber) {
        executeTransform(LV, RowNumber, g)
    }

    g.OnEvent("Close", (*) => cancelAndRestore(g))
    g.OnEvent("Escape", (*) => cancelAndRestore(g))

    LV.Modify(1, "Select Focus Vis")

    g.Show("AutoSize Center")

    ; ---------- 键盘消息拦截 ----------
    OnMessage(0x0100, OnKeyDown)
    OnMessage(0x0104, OnKeyDown)

    WinWaitClose("ahk_id " gHwnd)

    OnMessage(0x0100, OnKeyDown, 0)
    OnMessage(0x0104, OnKeyDown, 0)
}

; ============================================================
; 键盘处理 (WM_KEYDOWN)
; ============================================================
OnKeyDown(wParam, lParam, msg, hwnd) {
    if !WinActive("ahk_id " gHwnd)
        return

    vk := wParam

    ; --- 数字 0~9 ---
    if vk >= 0x30 && vk <= 0x39 {
        idx := (vk - 0x30) + 1
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 字母 a~z ---
    if vk >= 0x41 && vk <= 0x5A {
        idx := 10 + (vk - 0x41) + 1
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 空格或回车 → 执行 ---
    if vk = 0x20 || vk = 0x0D {
        row := gLV.GetNext(0, "Focused")
        if row
            executeTransform(gLV, row, g)
        return 0
    }
}

; ============================================================
; 取消 — 恢复原剪贴板
; ============================================================
cancelAndRestore(g) {
    A_Clipboard := gClipSaved
    g.Destroy()
}

; ============================================================
; 执行变换
; ============================================================
executeTransform(LV, RowNumber, g) {
    action := RowNumber
    processedText := gClipText

    Switch action {
    Case 1:  ; 去除文字格式（从剪贴板读入时已是纯文本）
        {}  ; 无需额外处理

    Case 2:  ; 每个单词全部大写
        processedText := StrUpper(processedText)

    Case 3:  ; 每个单词全部小写
        processedText := StrLower(processedText)

    Case 4:  ; 每个单词首字母大写
        processedText := StrTitle(processedText)

    Case 5:  ; 虚词小写处理
        processedText := StrTitle(processedText)
        conjunctions := ["a","an","the","and","or","for","nor","at","by","in","of"
                        ,"off","on","out","to","up","with","without","from","into"
                        ,"onto","over","upon","via","as"]
        lines := StrSplit(processedText, "`n", "`r")
        resultLines := []
        for _, line in lines {
            if (line = "") {
                resultLines.Push("")
                continue
            }
            if RegExMatch(line, "^\s*(\w+)", &firstWordMatch) {
                firstWord := firstWordMatch[1]
                firstWordLower := StrLower(firstWord)
                firstWordIsConjunction := false
                for _, conjunction in conjunctions {
                    if (firstWordLower = conjunction) {
                        firstWordIsConjunction := true
                        break
                    }
                }
                if firstWordIsConjunction {
                    for _, conjunction in conjunctions
                        line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                    RegExMatch(line, "^(\s*)", &leadingSpaces)
                    firstLetter := SubStr(firstWordLower, 1, 1)
                    restOfWord := SubStr(firstWordLower, 2)
                    firstLetterUpper := StrUpper(firstLetter)
                    capitalizedConjunction := firstLetterUpper . restOfWord
                    line := RegExReplace(line, "^\s*" firstWordLower
                                        , leadingSpaces[1] . capitalizedConjunction)
                } else {
                    for _, conjunction in conjunctions
                        line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
                }
            } else {
                for _, conjunction in conjunctions
                    line := RegExReplace(line, "i)\b" conjunction "\b", conjunction)
            }
            resultLines.Push(line)
        }
        processedText := ""
        for _, line in resultLines
            processedText .= line "`n"
        processedText := RTrim(processedText, "`n")

    Case 6:  ; 中英数分隔
        processedText := RegExReplace(processedText
                    , "([\x{4e00}-\x{9fff}])(?=[a-zA-Z0-9])", "$1 ")
        processedText := RegExReplace(processedText
                    , "(?<=[a-zA-Z0-9])([\x{4e00}-\x{9fff}])", " $1")
        processedText := RegExReplace(processedText
                    , "([a-zA-Z])(?=\d)", "$1 ")
        processedText := RegExReplace(processedText
                    , "(?<=\d)([a-zA-Z])", " $1")
        processedText := RegExReplace(processedText, "\s+", " ")
        processedText := Trim(processedText)

    Case 7:  ; 驼峰命名分隔
        lines := StrSplit(processedText, "`n", "`r")
        resultLines := []
        for _, line in lines {
            if (line = "") {
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
        processedText := ""
        for _, line in resultLines
            processedText .= line "`n"
        processedText := RTrim(processedText, "`n")

    Case 8:  ; 繁体转简体
        processedText := ConvertToSimplifiedChinese(processedText)

    Case 9:  ; 提取 ed2k 字段
        lines := StrSplit(processedText, "`n", "`r")
        resultLines := []
        ed2kCount := 0
        for _, line in lines {
            line := Trim(line)
            if (SubStr(line, 1, 5) = "ed2k:") {
                arr := StrSplit(line, "|")
                if (arr.Length >= 6) {
                    resultLines.Push(arr[4] "|" arr[5])
                    ed2kCount++
                } else
                    resultLines.Push("; 无效ed2k: " line)
            } else if (line != "")
                resultLines.Push("; 非ed2k: " line)
        }
        if (ed2kCount = 0) {
            MsgBox("未找到有效的 ed2k 链接！", "提示", "Iconi")
            return
        }
        processedText := ""
        for _, line in resultLines
            processedText .= line "`n"
        processedText := RTrim(processedText, "`n")

    Case 10:  ; 提取 Magnet 哈希
        lines := StrSplit(processedText, "`n", "`r")
        resultLines := []
        magnetCount := 0
        for _, line in lines {
            line := Trim(line)
            if RegExMatch(line, "i)^magnet:\?xt=urn:btih:([^&]+)", &match) {
                resultLines.Push(match[1])
                magnetCount++
            } else if (line != "")
                resultLines.Push("; 非Magnet: " line)
        }
        if (magnetCount = 0) {
            MsgBox("未找到有效的 Magnet 链接！", "提示", "Iconi")
            return
        }
        processedText := ""
        for _, line in resultLines
            processedText .= line "`n"
        processedText := RTrim(processedText, "`n")

    Case 11:  ; 标点半角转全角
        ; 引号交替替换
        quoteCount := 0
        pos := 1
        While (pos := InStr(processedText, '"', false, pos)) {
            quoteCount++
            replacement := (Mod(quoteCount, 2) = 1) ? Chr(0x201C) : Chr(0x201D)
            processedText := SubStr(processedText, 1, pos - 1)
                           . replacement
                           . SubStr(processedText, pos + 1)
            pos += StrLen(replacement)
        }
        ; 其余标点
        symbols := Map(
            " ",  "　",   ",",  "，",   "~",  "～",
            ":",  "：",   ";",  "；",   "!",  "！",
            "?",  "？",   "%",  "％",   "+",  "＋",
            "-",  "－",   "=",  "＝",   "/",  "／",
            "\",  "＼",   "(",  "（",   ")",  "）",
            "<",  "〈",   ">",  "〉"
        )
        for half, full in symbols
            processedText := StrReplace(processedText, half, full)

    Case 12:  ; 半角逗号加空格转行
        processedText := StrReplace(processedText, ", ", "`r`n")

    Case 13:  ; 空格转 URL 编码
        processedText := StrReplace(processedText, " ", "%20")

    Case 14:  ; 删除 Via 并截断
        viaPatterns := ["（Via：", "(Via:"]
        for _, pattern in viaPatterns {
            if (pos := InStr(processedText, pattern)) {
                processedText := SubStr(processedText, 1, pos - 1)
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

    ; ---------- 写入剪贴板并粘贴 ----------
    A_Clipboard := processedText
    if !ClipWait(0.3) {
        g.Destroy()
        MsgBox("写入剪贴板失败。", "错误", "Icon!")
        return
    }

    g.Destroy()

    if WinExist("ahk_id " gActiveHwnd)
        WinActivate("ahk_id " gActiveHwnd)
    Sleep(30)
    Send("^v")
}

; ============================================================
; 繁体转简体 (LCMapStringW)
; ============================================================
ConvertToSimplifiedChinese(text) {
    flags := 0x2000000  ; LCMAP_SIMPLIFIED_CHINESE
    locale := 0x0804     ; 简体中文
    charCount := StrLen(text)
    bufSize := (charCount + 1) * 4
    srcBuf := Buffer(bufSize, 0)
    destBuf := Buffer(bufSize, 0)
    StrPut(text, srcBuf, charCount + 1, "UTF-16")
    ret := DllCall("Kernel32.dll\LCMapStringW",
        "UInt", locale,
        "UInt", flags,
        "Ptr", srcBuf,
        "Int", charCount,
        "Ptr", destBuf,
        "Int", charCount,
        "Ptr", 0)
    if (ret > 0)
        return StrGet(destBuf, ret, "UTF-16")
    else {
        MsgBox("简繁转换失败，返回原文。", "错误", "Icon!")
        return text
    }
}