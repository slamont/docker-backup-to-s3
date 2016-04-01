strawpay/backup-to-s3
======================

Docker container that periodically backups files to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync) and cron.
The files will be tar:ed and the resulting tar file encrypted with AES 256 CBC.

To decrypt file.tgz.aes:

    openssl aes-256-cbc -k <PASSPHRASE> -in file.tgz.aes -out file.tgz -d

### Usage

    docker run -d [OPTIONS] strawpay/backup-to-s3

### Parameters:

* `-e ACCESS_KEY=<AWS_KEY>`: Your AWS key.
* `-e SECRET_KEY=<AWS_SECRET>`: Your AWS secret.
* `-e S3_PATH=s3://<BUCKET_NAME>/<PATH>/`: S3 Bucket name and path. Should end with trailing slash.
* `-e AES_PASSPHRASE=<PASSPHRASE>`: Passphrase to do AES-256-CBC encryption with.
* `-v /path/to/backup:/data:ro`: mount target local folder to container's data folder. Content of this folder will be tar:ed, encrypted and uploaded to the S3 bucket.

### Optional parameters:

* `-e PARAMS="--dry-run"`: parameters to pass to the sync command ([full list here](http://s3tools.org/usage)). Defaults to -q.
* `-e DATA_PATH=/data/`: container's data folder. Default is `/data/`. Should end with trailing slash.
* `-e PREFIX=prefix`: Prefix to encrypted tgz file name. The basename is a date stamp.
* `-e 'CRON_SCHEDULE=0 1 * * *'`: specifies when cron job starts ([details](http://en.wikipedia.org/wiki/Cron)). Default is `5 3 * * *` (runs every night at 03:05).
* `no-cron`: run container once and exit (no cron scheduling).

### Examples:

Run upload to S3 everyday at 12:00:

    docker run -d \
        -e ACCESS_KEY=myawskey \
        -e SECRET_KEY=myawssecret \
        -e S3_PATH=s3://my-bucket/backup/ \
	-e AES_PASSPHRASE=secret \
        -e 'CRON_SCHEDULE=0 12 * * *' \
        -v /home/user/data:/data:ro \
        strawpay/backup-to-s3

Run once then delete the container:

    docker run --rm \
        -e ACCESS_KEY=myawskey \
        -e SECRET_KEY=myawssecret \
        -e S3_PATH=s3://my-bucket/backup/ \
	-e AES_PASSPHRASE=secret \
        -v /home/user/data:/data:ro \
        strawpay/backup-to-s3 no-cron
