; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt + V，读取剪贴板内容，以无格式文字粘贴。

!v::
    originalClipboard := ClipboardAll  ; 保存剪贴板原始内容（修正函数调用）
    Clipboard := Clipboard  ; 自动转换为纯文本
    
    ; 等待剪贴板数据就绪（最多等待1秒）
    ClipWait, 1, 1
    
    ; 执行无格式粘贴
    Send, ^v
    
    ; 短暂延迟后恢复剪贴板
    Sleep, 150
    Clipboard := originalClipboard
    originalClipboard := ""  ; 释放内存
return