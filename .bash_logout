# ~/.bash_logout: executed by bash(1) when login shell exits.
WHOAMI=`whoami`
if [ `users|xargs -n 1 echo|grep -c $WHOAMI` -eq 1 ]
then
      killall --signal SIGKILL --user $WHOAMI dbus-launch dbus-daemon
fi

