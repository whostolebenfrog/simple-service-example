/bin/echo "postremove script started [$1]"

if [ "$1" = 0 ]
then
  /usr/sbin/userdel -r simple-service 2> /dev/null || :
  /bin/rm -rf /usr/local/simple-service
fi

/bin/echo "postremove script finished"
exit 0
