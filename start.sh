#!/bin/bash

set -e

: ${S3_PATH:?"S3_PATH env variable is required"}
: ${AES_PASSPHRASE:?"AES_PASSPHRASE env variable is required"}
export DATA_PATH=${DATA_PATH:-/data/}

CRON_SCHEDULE=${CRON_SCHEDULE:-3 5 * * *}

cat > /root/.aws/config <<EOF
[default]
region = ${AWS_REGION:-"us-east-1"}
output = json
EOF

if [ -n "$ACCESS_KEY" ] || [ -n "$SECRET_KEY" ]; then
    echo "AWS Direct credentials given. Using Access Key and Secret Key"
cat > /root/.aws/credentials <<EOF
[default]
aws_access_key_id = ${ACCESS_KEY}
aws_secret_access_key = ${SECRET_KEY}
EOF
else
    echo "No Direct AWS credentials provided, assuming there is an IAM role associated to the EC2 instance"
    iam_role_info=$(wget -q -O- http://169.254.169.254/latest/meta-data/iam/info)
    if [ -n "$iam_role_info" ]; then
        echo "IAM Role : [${iam_role_info}]"
    else
        echo "No IAM Role found, cannot continue"
        exit 2
    fi
fi


case $1 in 
  backup-once)
    exec /backup.sh
    ;;

  schedule)
    echo "Scheduling backup cron:$CRON_SCHEDULE"
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
      mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PARAMS='$PARAMS'\nDATA_PATH='$DATA_PATH'\nS3_PATH='$S3_PATH'\nPREFIX='$PREFIX'\nAES_PASSPHRASE='$AES_PASSPHRASE'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
    cron
    tail -f "$LOGFIFO"
    ;;

  restore)
    : ${VERSION:?"VERSION env variable is required"}
    exec /restore.sh
    ;;

  *)
    echo "Entrypoint could not understand specified operation. Delegating..."
    exec "$@"
    ;;
esac
