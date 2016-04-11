strawpay/backup-to-s3
======================

Docker container that periodically backups files to Amazon S3 using [s3cmd](http://s3tools.org/s3cmd) and cron.
All files will be tar:ed and encrypted with AES 256 CBC.

**Always test to restore the files from the backup, before relying on it.**


To decrypt resulting s3 object 2016-04-11T07:25:30Z.tgz.aes:
 
    openssl aes-256-cbc -k <PASSPHRASE> -in 2016-04-11T07:25:30Z.tgz.aes -out restore.tgz -d
    tar xf restore.tgz

### Usage

    docker run -d [Parameters] strawpay/backup-to-s3 backup-once|schedule|restore

* Backup: Make a single backup and exit.
* Schedule: Schedule backups with using cron. 
* Restore: Restore a backup, 

#### Parameters

<table>
<tr><th>Name</th><th>Operation</th><th>Required</th><th>Description</th></tr>
<tr>
	<td>-e ACCESS_KEY=&lt;AWS_KEY&gt;</td>
	<td>all</td>
	<td>yes</td>
	<td>Your AWS key</td>
</tr>
<tr>
	<td>-e SECRET_KEY=&lt;AWS_SECRET&gt;</td>
	<td>all</td>
	<td>yes</td>
	<td>Your AWS secret</td>
</tr>
<tr>
	<td>-e S3_PATH=s3://&lt;BUCKET_NAME&gt;/&lt;PATH&gt;/</td>
	<td>all</td>
	<td>yes</td>
	<td>S3 Bucket name and path. Should end with trailing slash.</td>
</tr>
<tr>
	<td>-e AES_PASSPHRASE=&lt;PASSPHRASE&gt;</td>
	<td>all</td>
	<td>yes</td>
	<td>Passphrase to generate AES-256-CBC encryption keys with.</td>
</tr>
<tr>
	<td>-e VERSION=&lt;VERSION_TO_RESTORE&gt;</td>
	<td>restore</td>
	<td>yes</td>
	<td>The version to restore, must be the full s3 object name without the `tgz.aes` suffix.</td>
</tr>
<tr>
	<td>-e PARAMS="--dry-run"</td>
	<td>all</td>
	<td>no</td>
	<td>Parameters to pass to the s3 command. <a href="http://s3tools.org/usage">(full list here</a>)</td>
</tr>
<tr>
	<td>-e DATA_PATH=/data/</td>
	<td>all</td>
	<td>no</td>
	<td>Container's data folder. Default is `/data/`. Should end with trailing slash.</td>
</tr>
<tr>
	<td>-e PREFIX=prefix</td>
	<td>backup-once, schedule</td>
	<td>no</td>
	<td>Prefix to encrypted tgz file name. The basename is a date stamp with a tgz.aes suffix</td>
</tr>
<tr>
	<td>-e 'CRON_SCHEDULE=5 3 * * *'</td>
	<td>schedule</td>
	<td>no</td>
	<td>Specifies when cron job runs, see <a href="http://en.wikipedia.org/wiki/Cron">format</a>. Default is <code>5 3 * * *</code>, runs every night at 03:05.</td>
</tr>
<tr>
	<td>-v /path/to/backup:/data:ro</td>
	<td>backup-once, schedule</td>
	<td>yes</td>
	<td>Mount target local folder to container's data folder. Content of this folder will be tar:ed, encrypted and uploaded to the S3 bucket.</td>
</tr>
<tr>
	<td>-v /path/to/restore:/data</td>
	<td>restore</td>
	<td>yes</td>
	<td>Mount target local folder to container's data folder. The restored files from the S3 bucket will overwrite all files in the /path/to/restore folder. Note that the folder will not be emptied first, leaving any no overwritten files as is.</td>
</tr>
</table>

### Examples:
 
Backup to S3 everyday at 12:00:

    docker run -d \
    	-e ACCESS_KEY=myawskey \
    	-e SECRET_KEY=myawssecret \
     	-e S3_PATH=s3://my-bucket/backup/ \
		-e AES_PASSPHRASE=secret \
    	-e 'CRON_SCHEDULE=0 12 * * *' \
    	-v /home/user/data:/data:ro \
    	strawpay/backup-to-s3 schedule

Backup once and then delete the container:

    docker run --rm \
    	-e ACCESS_KEY=myawskey \
    	-e SECRET_KEY=myawssecret \
    	-e S3_PATH=s3://my-bucket/backup/ \
	  	-e AES_PASSPHRASE=secret \
    	-v /home/user/data:/data:ro \
    	strawpay/backup-to-s3 backup-once

Restore the backup from `2016-04-11T07:25:30Z` and then delete the container:

    docker run --rm \
    	-e ACCESS_KEY=myawskey \
    	-e SECRET_KEY=myawssecret \
     	-e S3_PATH=s3://my-bucket/backup/ \
	  	-e AES_PASSPHRASE=secret \
	  	-e VERSION=2016-04-11T07:25:30Z
    	-v /home/user/data:/data \
    	strawpay/backup-to-s3 restore
        
        
