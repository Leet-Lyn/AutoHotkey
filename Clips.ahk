#Requires AutoHotkey v2.0

; ============================================================
; Clips.ahk
; Win+C — 读取脚本所在目录的 Clips.txt，弹出选择窗，粘贴选中行
; 索引: 0~9, a~z (共36项)
; 空格/回车/双击 → 写入剪贴板 → Ctrl+V 粘贴
; ============================================================

#c:: {
    scriptDir := A_ScriptDir
    clipsFile := scriptDir "\Clips.txt"

    if !FileExist(clipsFile) {
        MsgBox("未找到 Clips.txt`n`n预期路径: " clipsFile, "错误", "Icon!")
        return
    }

    ; ---------- 读取文件 ----------
    lines := []
    loop read, clipsFile, "UTF-8" {
        line := Trim(A_LoopReadLine, "`r`n")
        if (line = "")
            continue
        lines.Push(line)
    }

    if !lines.Length {
        MsgBox("Clips.txt 中没有有效内容。", "提示", "Iconi")
        return
    }

    if lines.Length > 36
        lines.Length := 36

    ; 构建索引标签: 0~9, a~z
    labels := []
    loop 10
        labels.Push(Mod(A_Index - 1, 10))
    loop 26
        labels.Push(Chr(Ord("a") + A_Index - 1))

    ; ---------- 创建 GUI ----------
    g := Gui()
    g.Title := "剪贴板选择器  [0-9 a-z 导航 | 空格/回车粘贴 | Esc 关闭]"
    g.SetFont("s10", "Microsoft YaHei")
    g.MarginX := 12
    g.MarginY := 10

    g.AddText("", "索引 `t内容（双击或回车/空格 直接粘贴）")
    g.AddText("", "————————————————————————————————————————————")

    LV := g.AddListView("r18 w700 -Hdr Grid NoSort", ["Idx", "内容"])
    LV.ModifyCol(1, 45)
    LV.ModifyCol(2, 640)

    for i, text in lines {
        idx := i <= labels.Length ? labels[i] : "?"
        LV.Add(, idx, text)
    }

    ; 保存引用供 OnMessage 回调使用（必须声明 global 才能在函数外可见）
    global gHwnd := g.Hwnd
    global gLV := LV
    global g := g

    ; ---------- 事件: 双击 ----------
    LV.OnEvent("DoubleClick", LV_DoubleClick)
    LV_DoubleClick(LV, RowNumber) {
        pasteSelected(LV, RowNumber, g)
    }

    ; ---------- 关闭 ----------
    g.OnEvent("Close", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())

    ; 初始选择
    LV.Modify(1, "Select Focus Vis")

    g.Show("AutoSize Center")

    ; ---------- 键盘消息拦截 ----------
    OnMessage(0x0100, OnKeyDown)   ; WM_KEYDOWN
    OnMessage(0x0104, OnKeyDown)   ; WM_SYSKEYDOWN (Alt 组合等)

    WinWaitClose("ahk_id " gHwnd)

    ; 清理消息钩子
    OnMessage(0x0100, OnKeyDown, 0)
    OnMessage(0x0104, OnKeyDown, 0)
}

; ============================================================
; 键盘处理 (WM_KEYDOWN)
; ============================================================
OnKeyDown(wParam, lParam, msg, hwnd) {
    ; 仅当焦点在 ListView 所在 GUI 内时处理
    if !WinActive("ahk_id " gHwnd)
        return

    vk := wParam

    ; --- 数字 0~9 ---
    if vk >= 0x30 && vk <= 0x39 {
        idx := (vk - 0x30) + 1          ; 0 → 行1, 9 → 行10
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")    ; 先清除所有选择
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 字母 a~z ---
    if vk >= 0x41 && vk <= 0x5A {
        idx := 10 + (vk - 0x41) + 1     ; A → 行11, Z → 行36
        if idx <= gLV.GetCount() {
            gLV.Modify(0, "-Select")    ; 先清除所有选择
            gLV.Modify(idx, "Select Focus Vis")
        }
        return 0
    }

    ; --- 空格或回车 → 粘贴 ---
    if vk = 0x20 || vk = 0x0D {
        row := gLV.GetNext(0, "Focused")
        if row {
            pasteSelected(gLV, row, g)
        }
        return 0
    }

    ; --- 上下箭头正常工作（不拦截） ---
    ; (不 return 0 就是放行默认行为)
}

; ============================================================
; 粘贴逻辑
; ============================================================
pasteSelected(LV, RowNumber, g) {
    text := LV.GetText(RowNumber, 2)
    if text = ""
        return

    A_Clipboard := text
    if !ClipWait(0.3) {
        g.Destroy()
        MsgBox("写入剪贴板失败。", "错误", "Icon!")
        return
    }

    g.Destroy()

    Sleep(30)
    Send("^v")
}
