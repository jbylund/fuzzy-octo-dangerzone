#!/bin/bash # gets me syntax highlighting

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make the file for history files
mkdir -p ~/.history

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

if [[ `arch` == i686 && `/home/friesner/jhb2147/bin32/bin/ls 2>/dev/null` ]]; then
	PATH="/home/friesner/jhb2147/bin32/bin:$PATH"
	export AUTOSSH_PATH=/home/friesner/jhb2147/bin32/bin/ssh
elif [[ `arch` == x86_64 && `/home/friesner/jhb2147/bin64/bin/ls 2>/dev/null` ]]; then
	PATH="/home/friesner/jhb2147/bin64/bin:$PATH"
	export LD_LIBRARY_PATH="/usr/local/lib64:/usr/local/lib32:$LD_LIBRARY_PATH"
  # /home/friesner/jz2300/local/intel/Compiler/11.1/072/mkl/lib/em64t:/home/friesner/jz2300/local/intel/Compiler/11.1/072/lib/intel64:
fi

if [ -d "/opt/bin" ]; then
	PATH="/opt/bin:$PATH"
fi

if [[ -d "/usr/local/software/schrodinger2011_64/utilities" ]]; then
	PATH="/usr/local/software/schrodinger2011_64/utilities:$PATH" # add schrodinger stuff to path
fi

if [[ $HOSTNAME != surmgt1 && -f /export/sge6.2_U7/ChemQ/common/settings.sh ]]; then
	source /export/sge6.2_U7/ChemQ/common/settings.sh
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]] ; then
	PATH="$HOME/bin:$PATH"
fi

if [[ -d "$HOME/scripts" ]] ; then
	PATH="$HOME/scripts/im_scripts:$HOME/scripts:$PATH"
fi

#source /opt/intel/bin/compilervars.sh intel64 2>/dev/null

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
export PLOP_COMPILER_FLAGS="-O2 -ffast-math -fexternal-blas -funroll-loops"

export SHOTWELL_CRITICAL=1
export SHOTWELL_DEBUG=1
export SHOTWELL_INFO=1
export SHOTWELL_MESSAGE=1
export SHOTWELL_WARNING=1

export TRASH="$HOME/.local/share/Trash/files/"

WHEREAMI=`hostname --fqdn 2>/dev/null`
export WHEREAMI="$WHEREAMI`hostname --alias 2>/dev/null|awk '{print $1}'`"

export LD_LIBRARY_PATH='/home/friesner/jhb2147/bin64/lib64:/usr/local/lib:/opt/namd:/usr/local/lib/gegl-0.2'
if [[ `ls -d /usr/lib/thunderbird-* 2>/dev/null` ]]; then
	export LD_LIBRARY_PATH="`ls -d /usr/lib/thunderbir* 2>/dev/null|\grep -v addons|head -n 1`:$LD_LIBRARY_PATH" # add thunderbird to ld_library_path
fi

#if [[ -d "/opt/intel/composer_xe_2011_sp1.6.233/mkl/lib/intel64" ]]; then
#  export LD_LIBRARY_PATH="/opt/intel/composer_xe_2011_sp1.6.233/mkl/lib/intel64/:$LD_LIBRARY_PATH"
#fi

export LM_LICENSE_FILE="@aqfctl.chem.columbia.edu"
export LM_LICENSE_FILE="@aqfctl" # should I have quotes or no?
export MPI_P4SSPORT=4356
export MPI_USEP4SSPORT=yes
export OMP_NUM_THREADS=`grep -c "processor" /proc/cpuinfo`
export P4_RSHCOMMAND=ssh
export RSHCOMMAND=ssh
export SCHRODINGER="/home/friesner/cao/schrodinger/"
export SCHRODINGER_MPI_DEBUG=yes
export SCHRODINGER_MPI_FLAGS="-v --mca btl tcp.self"
export SCHRODINGER_MPI_START=yes
export SCHRODINGER=/opt/schrodinger
export SCHRODINGER_RSH=ssh
export SCHRODINGER="/usr/local/software/schrodinger2011_64/"


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

# attempt to maintain directory if inside home directory
# and md5sum of ~/.ssh/known_hosts matches on old and new machine
function ssh()
{
    export LC_PWD="$PWD"
    export LC_OLDPWD="$OLDPWD"
    export LC_MD5HST=`md5sum ~/.ssh/known_hosts|cut --delimiter=' ' -f 1`
    export LC_TIME_OLD_HOST=`date --date="now + $OFFSET seconds" +"%s"`
    touch ~/.ssh/config
    `which ssh` -q -F ~/.ssh/config $* # connect to the specified machine
    unset LC_PWD
    unset LC_OLDPWD
    unset LC_TIME_OLD_HOST
    unset LC_MD5HST
}

#function ssh()
#{
#	echo "cd $PWD" > ~/.ccwd
#	`which ssh` $* "echo `date --date="now + $OFFSET seconds" +"%s"` > ~/.timeoldhost" 2> /dev/null # write the date in seconds from the current machine to .timeoldhost on the new machine
#	`which ssh` -F ~/.ssh/config $* # connect to the specified machine
#	# actual changing of directory happens in .bash_login
#	source ~/.ccwd # on getting back to this machine go back to the directory I was in
#}

PS1='\[\033[1;${COLORCODE}m\]\u `date +%T --date="now + $OFFSET seconds"` @ \h \w>\[\033[0m\] ' # set the prompt, ssh directly to caerphilly

function plop()
{
	MOST_RECENT_PLOP=`\ls -t ~/plop/executables/plop-gfortran-static-*|head -n 1`
	echo "Running plop $MOST_RECENT_PLOP"
	$MOST_RECENT_PLOP $*
}

# to append
# gzip -c file2 >> foo.gz

PROMPT_COMMAND='echo
echo
thiscommand=`fc -ln -1 | perl -pe "s/^\s+//"`
if [[ "$thiscommand" != "" ]]; then
	pwd > ~/.tmp_command
	echo "$thiscommand" >> ~/.tmp_command
    mv ~/.tmp_command ~/.history/`md5sum ~/.tmp_command | cut -c 1-32`
fi

echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
' # set the window title and touch the date file


# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    export LS_COLORS="${LS_COLORS}*.lrz=01;31:*.nef=01;37:" # add coloring for lrz, do I need to add for .nef as well?
fi

export PKG_CONFIG_DIR=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig


