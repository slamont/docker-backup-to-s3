#!/bin/bash

set -e

: ${ACCESS_KEY:?"ACCESS_KEY env variable is required"}
: ${SECRET_KEY:?"SECRET_KEY env variable is required"}
: ${S3_PATH:?"S3_PATH env variable is required"}
: ${AES_PASSPHRASE:?"AES_PASSPHRASE env variable is required"}
export DATA_PATH=${DATA_PATH:-/data/}
export PARAMS=${PARAMS:--q}
CRON_SCHEDULE=${CRON_SCHEDULE:-3 5 * * *}

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [[ "$1" == 'no-cron' ]]; then
    exec /upload.sh
else
    echo "Scheduling backup cron:$CRON_SCHEDULE" 
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PARAMS='$PARAMS'\nDATA_PATH='$DATA_PATH'\nS3_PATH='$S3_PATH'\nPREFIX='$PREFIX'\nAES_PASSPHRASE='$AES_PASSPHRASE'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /upload.sh > $LOGFIFO 2>&1" | crontab -
    cron
    tail -f "$LOGFIFO"
fi
