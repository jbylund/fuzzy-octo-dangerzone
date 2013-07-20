#!/bin/bash

alias cat='cat -v'
alias clip='xclip -selection c'
alias clusterkill='\qstat|\grep jbylund|awk '\''{print $1}'\''|xargs -r qdel'
alias cp='cp --no-dereference'
alias df='df -h --local'
alias diff='diff --side-by-side --report-identical-files --suppress-blank-empty --suppress-common-lines --ignore-all-space --ignore-case --width=`tput cols`'
alias fix_display='xrandr --size 0'
alias gedit='gedit --new-window'
alias grep='grep -a --color=auto -n'
alias libreoffice='libreoffice --nologo'
alias ls='timeout 7 ls -F --color=auto --hide='\''*~'\'' --hide='\''.*~'\'' --hide='\''CVS'\'' --hide='\''Maildir'\'' --hide='\''Insync'\'' --group-directories-first'
alias maestro='ssh aqfserv "/home/friesner/jhb2147/bin32/bin/ssh foct03 \"hostname; export LM_LICENSE_FILE=@aqfctl; /usr/local/software/schrodinger_2012/maestro\""'
alias make='while [ ! `ls [Mm]akefile` ]; do cd ..; done; make -j `\grep -c processor /proc/cpuinfo`'
alias man='man -P cat'
alias qmon='qmon -nologo'
alias qstat='better_qstat'
alias tcsh='unset LS_COLORS; tcsh'
alias vmd='unset LS_COLORS; vmd -m -nt'
alias shotwell='shotwell --no-runtime-monitoring'

# disable the bash builtin history for my own
enable -n history
