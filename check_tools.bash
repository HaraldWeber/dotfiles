#/bin/bash

function checkBashVersion()
{
    if ((BASH_VERSINFO[0] < 4))
    then
        echo 1
    else
        echo 0
    fi
}

function checkGit()
{
    which git > /dev/null 2>&1
    if [[ $? -eq "0" ]]
    then
        echo "Git is not installed."
        read -p "Do you want to install it now? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ (^$|^[Yy]$) ]]
        then
            echo "Aborting installation."
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
        fi
        sudo apt-get install git
    fi
}

function checkPrograms()
{
    declare -A PROGS
    PROGS=(
        ["git"]="git"
        ["ssh"]="openssh-client"
        ["rsync"]="rsync"
        ["vim"]="vim"
        ["tmux"]="tmux"
        ["tsp"]="task-spooler"
        ["curl"]="curl"
        ["grep"]="grep"
        ["sed"]="sed"
        ["upower"]="upower"
        ["duplicity"]="duplicity"
        ["python"]="python-minimal"
        ["htop"]="htop"
        ["iotop"]="iotop"
        ["iftop"]="iftop"
        ["ncdu"]="ncdu"
        ["mtr"]="mtr"

    )
    PACKAGES_TO_INSTALL=""
    read -p "Do you want to install programs automatically (dpkg based OS only)? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ (^$|^[Yy]$) ]]
    then
        # select 
        echo "select"
        for PROG in "${!PROGS[@]}";
        do
            read -p "Do you want to install ${PROG}? [Y/n] " -n 1 -r
            echo
            if [[ $REPLY =~ (^$|^[Yy]$) ]]
            then
                PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} ${PROGS[$PROG]}"
            fi
        done
    else
        for PROG in "${!PROGS[@]}";
        do
            PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} ${PROGS[$PROG]}"
        done
    fi
    
    echo "Do you want to install these programs?"
    echo -e "\033[1m${PACKAGES_TO_INSTALL}\033[0m"
    sleep 2
    read -p "Install [Y/n]" -n 1 -r
    if [[ ! $REPLY =~ (^$|^[Yy]$) ]]
    then
        echo
        echo "Will not install additional programs."
    else
        sudo apt-get -y update && sudo apt-get install ${PACKAGES_TO_INSTALL}
    fi

}

