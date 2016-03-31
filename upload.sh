#!/bin/bash 

set -e

dateISO() {
    date -u '+%Y-%m-%dT%H:%M:%SZ'
}

start=$(dateISO)
echo "Backup started: $start"

if [ "$PREFIX" ]; then
    name="$PREFIX-$start.tgz"
else
    name="$start.tgz"
fi

tar czvf /tmp/$name  -C $DATA_PATH .
openssl enc -aes-256-cbc -salt -k $AES_PASSPHRASE -in /tmp/$name -out /tmp/$name.aes

/usr/local/bin/s3cmd put -m application/octet-stream $PARAMS /tmp/$name.aes "$S3_PATH"

rm -f /tmp/$name
rm -f /tmp/$name.aes

echo "Backup finished: $(dateISO)"
