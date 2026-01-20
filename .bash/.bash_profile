# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%F %T "  # Add timestamps

shopt -s histappend      # append to the history file, don't overwrite it
shopt -s cmdhist         # Save multi-line commands in one line
shopt -s cdspell         # Autocorrect typos in cd
shopt -s dirspell        # Autocorrect directory names
shopt -s autocd          # Type directory name to cd into it
shopt -s nocaseglob      # Case-insensitive globbing

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Disalbe Ctrl+s flow control
stty -ixon

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Load some dotfiles (order is important)
for file in ~/.bash/{bash_exports,bash_path,bash_aliases,bash_completion,bash_prompt}; do
  [ -r "$file" ] && source "$file"
done

# Load function files
for file in ~/.bash/functions/*.bash; do
  [ -r "$file" ] && source "$file"
done

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
