My Dotfiles
========

These are my dot files. 
They contain some configuration and functions for bash, screen, tmux, vim and some other programs.

# Installation
First of all you have to clone the git repository. Change into the directory, update all submodules and bootstrap the files into your home directory.

```bash
git clone https://github.com/HaraldWeber/dotfiles.git 
cd dotfiles
git submodule update --init --recursive
./bootstrap.sh
```

# Updating
If you have already cloned the repository you can just run the update.sh to update all submodules and bootstrap the files.

```bash
cd dotfiles
./update.sh
```

# Commands

I have added some handy commands.

## calc 

calc is a calculator for the command line. It uses bc for the calculation. If you use some special characters you have to use apostrophes.

Examples:

```bash
$ calc 1+2
3
$ calc '(1+3)*2'
8
```

## cpuq netq ioq

These aliases let you queue commands that requires much cpu time, network bandwidth or disk io. 

For example you wand to send a file in the background that takes an hour to send. After a minute you want to send more files. If you send them parallel it would take ages to complete the first file. To avoid this you can use the alias _netq__.

```bash
$ netq scp some.file remote:/tmp/
0
$ netq scp other.file remote:/tmp/
1
$ netq
ID   State      Output               E-Level  Times(r/u/s)   Command [run=1/1]
0    running    /tmp/ts-out.cEwzhE                           scp some.file remote:/tmp/
1    queued     (file)                                       scp other.file remote:/tmp/
```

This will run the first command immediately and queues the second. Run __netq__ to show the queue.   
For more information run __netq -h__.

## install-key

This program installs your public ssh key to the specified server.

```bash
$ install-key <remote_host> [ssh_port] [public_key_file]
```

## formatJSON

This alias formats json syntax using pythons json.tool. Python is required for this alias.

```bash
$ cat unformatted.json | formatJSON > formatted.json
$ curl http://json.com/unformatted.json | formatJSON
{
 jsontext: "Some formatted json"
}
```

## open

__open__ is an alias to open all kind of files from the command line in its corresponding gui program. Its behavior is like the open command on OSX.   
 
```bash
open some.pdf
```

This will open the pdf in your standard pdf reader.


## tmux

tmux**a** is an alias to 'tmux attach || tmux'
This alias always resume a tmux session. If there is no session just start tmux.


## tmux-remote

This is a script to easily create a shared tmux session.   
One user creates a sessions with the command __tmux_remote__ and the other user executes __tmux_remote attach__.   
The user who wants to attach a session gets a menu with open tmux sessions to choose from.


## tunnel

Opens a ssh tunnel and executes the optional command.
If no command is given the program waits until CTRL + d is pressed.

```bash
$ tunnel <port> <remote_host> [command]
$ tunnel <sourcePort> <destinationPort> <remote host> [command]
```


## bat

bat is an alias to show some battery infos
```bash
$ bat 
    state:               discharging
    time to empty:       2,9 hours
    percentage:          64%
```


## 7zc

7zc is an alias for 7zip maximum compression
(7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on -r)
```bash
$ 7zc archive.7z dir/  
```

## toggle-screen            

Toggles screen output of the given screen to on of off.
```bash
$ toggle-screen LVDS1 
```

## lock

Locks the screen with i3lock.
```bash
$ lock
```

## magnet

Creates a bittorrent magnet link with a specified info hash
```bash
$ magnet 3f19b149f53a50e14fc0b79926a391896eabab6f Ubuntu.iso
```

## backup

A script to wrap duplicity. Make backups simple.
Execute backup to show the usage.
```bash
$ backup
```

# Directory Structure
Each program has its own directory. Some files are symlinked to to the home directory (e.g. .bashrc).

## .bash
This directory contains all files for the bash.

* __.bashrc__ just calls __.bash_profile__
* __.bash_profile__ first sets a few options for the bash.   
  Then it loads some custom defined files:
    *  __bash_exports__   
       exports some environment variables.
    *  __bash_path__   
       builds up the PATH variable.
    *  __bash_aliases__   
       sets up some aliases.
    *  __bash_completion__   
       loads custom completion functions.
    *  __bash_prompt__   
       builds up the bash prompt.

Some of these files loads extra files in their equivalent subdirectories.

 For example __bash_aliases__ loads all files in aliases.   
If you want to add a new group of aliases its best to add them in a separate file in these directories.

For customizations the filenames should end with .custom.bash. Then git will ignore these files.

The __.bash/bin__ directory includes some executable scripts. This directory is added to the PATH variable in the __bash_path__ file.

## .screen
Contains the configuration for screen.

## .tmux
For tmux.

## .vim
Contains the configuration and plugins for vim. __.vimrc__ is symlinked from the home directory.





<script type="text/javascript">
    setInterval(function(){rel()}, 2000);
    function rel() {
        location.reload(true);
    }
</script>
