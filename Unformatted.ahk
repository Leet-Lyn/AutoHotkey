; 请帮我写个 Autohotkey 脚本。
; 当我按下 Crtl + Shift + V，读取剪贴板内容，以无格式文字粘贴。

^+v::
    ; 保存原始剪贴板内容
    originalClipboard := ClipboardAll()
    
    ; 将剪贴板内容转换为纯文本
    Clipboard := Clipboard
    
    ; 等待剪贴板就绪（最多等待 0.5 秒）
    ClipWait 0.5
    
    ; 发送 Ctrl+V 粘贴
    Send ^v
    
    ; 短暂等待确保粘贴完成
    Sleep 50
    
    ; 恢复原始剪贴板内容
    Clipboard := originalClipboard
    
    ; 清理内存
    originalClipboard := ""
return