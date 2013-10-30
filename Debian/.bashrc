# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${BBlue}        # Connected on remote machine, via ssh (good).
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${ALERT}        # Connected on remote machine, not via ssh (bad).
else
    CNX=${BGreen}        # Connected on local machine.
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Red}           # User is root.
elif [[ ${USER} != $(logname) ]]; then
    SU=${BRed}          # User is not login user.
else
    SU=${BCyan}         # User is normal (well ... most of us are).
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1="\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[1;31m\]\$(date +%H:%M)\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\]"
#    PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[1;31m\]\@\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\]"
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias PAGER='less -r'
alias h='history 10'
alias j='jobs -l'
alias m='less'
alias md='mkdir'
alias p='pstree -p'
alias ping='ping -vc1'
alias updt='sudo apt-get update && sudo apt-get upgrade'
alias psc='ps xawf -eo pid,user,cgroup,args'

alias twitter='turses'

# SSH aliases
alias pb='ssh pi@pibang'
alias fp='ssh pi@funpi'
alias sp='ssh pi@securitypi'

# FTP aliases
alias ftpp='ftp pibang'
alias ftpf='ftp funpi'
alias ftps='ftp securitypi'

# Serial aliases
alias compi='minicom --color=on -D /dev/ttyUSB0 -b 115200 -o'
alias scrpi='sudo screen -A /dev/ttyUSB0 115200'

# Disk mount aliases
alias PiBang='sudo mount -t cifs //pibang/BangDisk /home/bubbl/mnt/PiBang -o username=pi'
alias SecDisk='sudo mount -t cifs //securitypi/MediA /home/bubbl/mnt/PiSecurity -o username=pi'
alias Ubuntu1='sudo mount -t cifs //ubuntu/bubbl ~/mnt/bubbl1 -o username=bubbl'
alias Ubuntu2='sudo mount -t cifs //ubuntu/bubbl2 ~/mnt/bubbl2 -o username=bubbl'

# Fast(er) shutdown/restart
alias haltme='sudo shutdown -h now'
alias restart='sudo shutdown -r now'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

alias m='less'
alias p='pstree -p'

alias unaliasall='unalias -a'

alias h='history'
alias j='jobs -l'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.git-completion.bash ]; then
. ~/.git-completion.bash
fi

genpasswd() {
	local l=$1
       	[ "$l" == "" ] && l=20
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

today() {
    echo -n "Today's date is: "
    date +"%A, %B %-d, %Y"
}

extract() {
 if [ -f $1 ] ; then
 case $1 in
 *.tar.bz2) tar xvjf $1 ;;
 *.tar.gz) tar xvzf $1 ;;
 *.bz2) bunzip2 $1 ;;
 *.rar) unrar x $1 ;;
 *.gz) gunzip $1 ;;
 *.tar) tar xvf $1 ;;
 *.tbz2) tar xvjf $1 ;;
 *.tgz) tar xvzf $1 ;;
 *.zip) unzip $1 ;;
 *.Z) uncompress $1 ;;
 *.7z) 7z x $1 ;;
 *) echo "'$1' cannot be extracted via &gt;extract&lt;" ;;
 esac
 else
 echo "'$1' is not a valid file"
 fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz" "${1%%/}/"; }
# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }
# Make your directories and files access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}

function mcd() { mkdir $1 && cd $1; }

function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function killps()   # kill by process name
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}

mydf()         # Pretty-print of 'df' output.
{                       # Inspired by 'dfc' utility.
    for fs ; do

        if [ ! -d $fs ]
        then
          echo -e $fs" :No such file or directory" ; continue
        fi

        local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') 
)
        local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
        local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
        local out="["
        for ((j=0;j<20;j++)); do
            if [ ${j} -lt ${nbstars} ]; then
               out=$out"*"
            else
               out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}


function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

function ii()   # Get current host related info.
{
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
    echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
    echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}

function cline_red {
PS1="\[\033[31;41;1m\]\333\262\261\260\[\033[37;41;1m\]\u@\h\[\033[0m\033[31;40m\]\333\262\261\260\[\033[37;40;1m\] \d \$(date +%I:%M%P)\n\[\033[31;40;1m\]\w/\[\033[0m\] "
PS2="\[\033[31;40m\]\333\262\261\260\[\033[0m\]>"
}

function cline_combo {
PS1="\[\033[01;34;01m\]\333\262\261\260\[\033[01;37;44m\]\u@\h\[\033[00;34;40m\]\260\261\262\333\[\033[00;34;40m\]\333\262\261\260\[\033[01;37;40m\] \d \$(date +%I:%M%P)\n\[\033[01;33;40m\]$PWD>\[\033[00m\] "
PS2="\[\033[01;34;01m\]\333\262\261\260\[\033[00;34;40m\]\260\261\262\333\[\033[00;34;40m\]\333\262\261\260\[\033[01;01;34m\]>\[\033[00m\] "
}

function cline_norm {
    PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[1;31m\]\@\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\]"
}
