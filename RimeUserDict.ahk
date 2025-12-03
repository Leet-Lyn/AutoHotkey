; 请帮我写个 Autohotkey 脚本。
; 当我按下 Alt＋`，读取剪贴板内容。运行 Python 脚本：“e:\Documents\Creations\Scripts\Python\RimeUserDict.py”。

!`::
    Run, python "e:\Documents\Creations\Scripts\Python\RimeUserDict.py"
    return