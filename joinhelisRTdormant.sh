#!/usr/bin/bash

HOST='dormant.org'
USER='u990972409'
PASSWD='7406/Lambe!'

ftp -n -v $HOST << EOT
ascii
user $USER $PASSWD
prompt
cd heliwatch
put xhelis.png
bye
EOT
