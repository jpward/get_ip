#!/bin/bash

#Source adapted from:
#  https://stackoverflow.com/questions/14722556/using-curl-to-send-email
#  https://askubuntu.com/questions/95910/command-for-determining-my-public-ip

set -e

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

if ! [ -f /tmp/mail.txt ]; then
  cp ${HERE}/mail.txt /tmp/mail.txt
fi

OLD_IP="$(grep "IP=" /tmp/mail.txt | sed "s/IP=//")"
echo ${OLD_IP}

NEW_IP="$(nc 4.ifcfg.me 23 | grep IPv4 | cut -d' ' -f4 | sed 's/\r//')"

#if a valid IP is found (invalid will be blank)
if echo ${NEW_IP} | grep -q [0-9] ; then
  echo ${NEW_IP}
else
  #Try again later
  exit 0
fi

if ! [ "${OLD_IP}" = "${NEW_IP}" ]; then
  cp ${HERE}/mail.txt.orig /tmp/mail.txt

  sed -i "s/%IP%/${NEW_IP}/" /tmp/mail.txt

  curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
    --mail-from 'from@gmail.com' --mail-rcpt 'to@gmail.com' \
    --upload-file /tmp/mail.txt --user 'from@gmail.com:password' --insecure

fi
