#!/bin/bash

set -e

started=$(date +%s)
startedAt=$(date -u -d @${started}  +"%Y-%m-%dT%H:%M:%SZ")

s3obj=${VERSION}.tgz.aes
tarfile=restore.tgz

echo "Starting restore ${S3_PATH}${s3obj} to:${DATA_PATH}"

#Convertion to aws cli
output=$(/usr/local/bin/aws --output text s3 cp "${S3_PATH}${s3obj}" ${DATA_PATH} ${PARAMS} --no-progress 2>&1)
code=$?
if [ $code ]; then
    result=ok
    cd ${DATA_PATH}
    openssl aes-256-cbc -k "${AES_PASSPHRASE}" -in ${s3obj} -out ${tarfile} -d
    tar xzvf ${tarfile}
else
    result="error:${code}"
fi

rm -f ${s3obj}
rm -f ${tarfile}

finished=$(date +%s)
duration=$(( finished - started ))
#printf "restore:\n\tstartedAt:'%s'\n\tduration:'PT%is'\n\tfrom:'%s/%s'\n\tresult:'%s'\n\toutput:'%s'\n" "${startedAt}" "${duration}" "${S3_PATH}" "${s3obj}" "${result}" "${output}"
cat <<EOF
restore:
    startedAt: '${startedAt}'
    duration: 'PT${duration}s'
    from: '${S3_PATH}/${s3obj}'
    result: '${result}'
    output: '${output}'
EOF
