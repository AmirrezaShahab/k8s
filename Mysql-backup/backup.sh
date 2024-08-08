#!/bin/bash

DB_HOST="<change me>"
DB_USER="change me"
DB_PASSWORD="change me"
DB_NAME="<change me>"

S3_BUCKET="<change me>"
S3_ENDPOINT="<change me>"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")

BACKUP_FILE="/tmp/${DB_NAME}_${TIMESTAMP}.sql.gz"

mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME | gzip > $BACKUP_FILE

aws s3 cp $BACKUP_FILE s3://${S3_BUCKET}/ --endpoint-url $S3_ENDPOINT

rm $BACKUP_FILE