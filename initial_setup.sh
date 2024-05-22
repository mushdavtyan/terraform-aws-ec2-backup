#!/bin/bash

cd `dirname $0`

[[ -s ./.env.rc ]] && source ./.env.rc

echo "setting up key pair"
aws ec2 describe-key-pairs --region $AWS_REGION --output text --key-name $KEY_NAME >/dev/null 2>&1
if [ $? -gt 0 ]
then
    aws ec2 create-key-pair --region $AWS_REGION --key-name $KEY_NAME --query 'KeyMaterial' --output text > keys/$KEY_NAME.pem
    chmod 400 keys/$KEY_NAME.pem
fi
aws ec2 describe-key-pairs --output text --key-name $KEY_NAME

sed -i "" "s|S3_BUCKET=.*|S3_BUCKET=${S3_BUCKET_NAME}|" scripts/daily_backup.sh

echo "applying terraform"

cd terraform
terraform init
terraform apply -auto-approve \
-var "region=$AWS_REGION" \
-var "ssh_key_name=$KEY_NAME" \
-var "backup_folder_path=$BACKUP_PATH_DIR" \
-var "bucket_name=$S3_BUCKET_NAME" \
