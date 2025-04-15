# Quick launch Windows Terminal with preferred layout
$wtPath = "wt.exe"

# Launch Windows Terminal with split panes
& $wtPath `
    new-tab --title "Dev" `powershell -NoExit -Command "cd ~/Projects" `; `
    split-pane -V `powershell -NoExit -Command "cd ~/Projects" `; `
    move-focus up `; `
    split-pane -H `powershell -NoExit -Command "cd ~/Projects"
