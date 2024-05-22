#!/bin/bash

cd `dirname $0`
[[ -s ./.env.rc ]] && source ./.env.rc

echo "emptying S3 bucket"

for S3_BUCKET in $(aws s3api list-buckets --output table --query 'Buckets[*].Name' | grep $S3_BUCKET_NAME | sed -e 's/ //g' -e 's/|//g')
do
    aws s3 rm s3://$S3_BUCKET --recursive
done

echo "destroying terraform resources"

pushd terraform
terraform init
terraform destroy -auto-approve \
-var "region=$AWS_REGION" \
-var "ssh_key_name=$KEY_NAME" \
-var "backup_folder_path=$BACKUP_PATH_DIR" \
-var "bucket_name=$S3_BUCKET_NAME"

popd
echo "removing key pair"
aws ec2 delete-key-pair --key-name $KEY_NAME --region $AWS_REGION > /dev/null 2>&1
rm -f "keys/${KEY_NAME}.pem" > /dev/null 2>&1
echo "teardown completed successfully."