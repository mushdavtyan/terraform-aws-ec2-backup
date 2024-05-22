#!/bin/bash

# This script creates a daily backup for the folder given as an argument and uploads it to an S3 bucket.

# Stop script if any command fails
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 <source_dir>"
    exit 1
}

# Check if the source directory argument is provided
if [ -z "$1" ]; then
    usage
fi

# Variables
BACKUP_DIR="/home/ec2-user/backup"
SOURCE_DIR=$1
DATE=$(date +%Y-%m-%d)
BACKUP_FILE="$BACKUP_DIR/backup-$DATE.tar.gz"
S3_BUCKET=fxc-my-backup-bucket

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check if the source directory exists
if [ ! -d $SOURCE_DIR ]; then
    echo "Source directory does not exist"
    exit 1
fi

# Create the backup
tar -czf $BACKUP_FILE $SOURCE_DIR > /dev/null 2>&1

# Upload the backup to the S3 bucket
aws s3 cp $BACKUP_FILE s3://$S3_BUCKET/backup/ || { echo "Failed to upload backup to S3"; exit 1; }

echo "Backup and upload completed successfully."
