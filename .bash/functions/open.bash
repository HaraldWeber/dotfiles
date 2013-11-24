# open every file with the command open

open(){
    xdg-open "$@" &>/dev/null
}

