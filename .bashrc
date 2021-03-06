#!/bin/bash # gets me syntax highlighting

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make the file for history files
mkdir -p ~/.history

if [ $(top -b -n 1 | \grep -i ssh-agent | \grep -v grep | wc -l) -ne 1 ]
then
  killall --quiet ssh-agent
  eval `ssh-agent -s | head -n 2`
fi

for i in `ls ~/.ssh/*.pem ~/.ssh/id_rsa`
do
  ssh-add $i > /dev/null 2>/dev/null
done

# patch up ssh by picking up environment variables that were passed in
if [ -n "${LC_TIME_OLD_HOST+x}" ] # if time old host is set
then
	export OLD_DATE=$LC_TIME_OLD_HOST
	NEW_DATE=`date +"%s"` # store the current date in new_date
	unset LC_TIME_OLD_HOST
	# check if on same filesystem by comparing known_hosts files
	if [ "`md5sum ~/.ssh/known_hosts|cut --delimiter=' ' -f 1`" == "$LC_MD5HST" ]
	then
		PWD=$LC_PWD
		OLDPWD=$LC_OLDPWD
		unset LC_PWD
		unset LC_OLDPWD
	fi
	unset LC_MD5HST
fi

## Source global definitions, do we need this?, should it go at the beginning?
if [[ -f /etc/bashrc ]]; then
	. /etc/bashrc 2>/dev/null
fi

####################################################################################################################################
#####    Set Up The Bash History   #################################################################################################
####################################################################################################################################
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
# append to the history file, don't overwrite it
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups # don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoreboth # ignore duplicates and spaces
export HISTFILESIZE=10000
export HISTSIZE=10000
shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s histappend # append to the history file, don't overwrite it
shopt -s huponexit # make ssh exit


# allows you to less gzipped files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

####################################################################################################################################
#########    Set Up Aliases     ####################################################################################################
####################################################################################################################################
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

####################################################################################################################################
#########    Set Up The Path    ####################################################################################################
####################################################################################################################################

PATH="/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin:/usr/games" # basic stuff/fallbacks
PATH="$HOME/common/registry:$PATH"

if [ -d "/opt/bin" ]; then
	PATH="/opt/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]] ; then
	PATH="$HOME/bin:$PATH"
fi

if [[ -d "$HOME/scripts" ]] ; then
	PATH="$HOME/scripts:$PATH"
fi

export PATH

####################################################################################################################################
#########    Set Up Exports     ####################################################################################################
####################################################################################################################################
export COMPILER=gfortran-static
export CVS_RSH=ssh
export EDITOR=gedit
export MAGICK_THREAD_LIMIT=1
export NO_AT_BRIDGE=1
export RSYNC_RSH=ssh
export SIMPLE_BACKUP_SUFFIX=''
export VERSION_CONTROL=numbered
#export GLOBIGNORE=".:..:*~:CVS" # set up to ignore ".","..",".*", and "*~"  :.*
export IGNOREEOF=0
#export MANPATH=/usr/share/man

export SHOTWELL_CRITICAL=1
export SHOTWELL_DEBUG=1
export SHOTWELL_INFO=1
export SHOTWELL_MESSAGE=1
export SHOTWELL_WARNING=1

export TRASH="$HOME/.local/share/Trash/files/"

WHEREAMI=`hostname --fqdn 2>/dev/null`
export WHEREAMI="$WHEREAMI`hostname --alias 2>/dev/null|awk '{print $1}'`"

if [[ `ls -d /usr/lib/thunderbird-* 2>/dev/null` ]]; then
	export LD_LIBRARY_PATH="`ls -d /usr/lib/thunderbir* 2>/dev/null|\grep -v addons|head -n 1`:$LD_LIBRARY_PATH" # add thunderbird to ld_library_path
fi

export MPI_P4SSPORT=4356
export MPI_USEP4SSPORT=yes
export OMP_NUM_THREADS=`grep -c "processor" /proc/cpuinfo`
export P4_RSHCOMMAND=ssh
export RSHCOMMAND=ssh

FULLHOST=`hostname --fqdn 2>/dev/null || hostname`
USER=`whoami`
HOSTHASH=`echo "${USER}${FULLHOST}"| md5sum -|awk '{print "1"$1}'|tr -d '[a-z]'` # removes all letters 
let HOSTHASH=$HOSTHASH%100000000+4
export HOSTHASH

####################################################################################################################################
#########    Set Up The Prompt  ####################################################################################################
####################################################################################################################################
export OFFSET=0
if [[ $OLD_HOST ]]; then
	NEW_DATE=`date +"%s"` # store the current date in new_date
	let OFFSET=$OLD_DATE-$NEW_DATE # store the offset in offset
	export OFFSET
else
  if [[ $USER != "root" ]]; then
  	my_calendar # display the greeting and calendar
  fi
fi

let COLORCODE=$HOSTHASH%7+30
if [[ $USER = "root" ]]; then
    COLORCODE=31
else
  if (( $COLORCODE > 30 )); then
	  let COLORCODE=$COLORCODE+1
	  export COLORCODE
  fi
fi

PS1='\[\033[1;${COLORCODE}m\]\u `date +%T --date="now + $OFFSET seconds"` @ \h \w>\[\033[0m\] ' # set the prompt, ssh directly to caerphilly

PROMPT_COMMAND=$(cat ${HOME}/scripts/prompt_command)

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    export LS_COLORS="${LS_COLORS}*.lrz=01;31:*.nef=01;37:" # add coloring for lrz, do I need to add for .nef as well?
fi

export PKG_CONFIG_DIR=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig
export PYTHONPATH=/home/jbylund/
export LIBOVERLAY_SCROLLBAR=0
if [ -e ~/.moat_env_vars ]
then
  . ~/.moat_env_vars
elif [ -x ~/common/registry/glom.sh ]
then
  eval $( echo 3 | ~/common/registry/glom.sh | \grep export | tail -c +18 | sort )
fi
