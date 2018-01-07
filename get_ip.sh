#!/bin/bash

#Source adapted from:
#  https://stackoverflow.com/questions/14722556/using-curl-to-send-email
#  https://askubuntu.com/questions/95910/command-for-determining-my-public-ip

set -e
OLD_IP="$(grep "IP=" mail.txt | sed "s/IP=//")"
echo ${OLD_IP}

NEW_IP="$(nc 4.ifcfg.me 23 | grep IPv4 | cut -d' ' -f4 | sed 's/\r//')"
echo ${NEW_IP}

if ! [ "${OLD_IP}" = "${NEW_IP}" ]; then
  cp mail.txt.orig mail.txt

  sed -i "s/%IP%/${NEW_IP}/" mail.txt


  curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
    --mail-from 'from@gmail.com' --mail-rcpt 'to@gmail.com' \
    --upload-file mail.txt --user 'from@gmail.com:password' --insecure

fi
