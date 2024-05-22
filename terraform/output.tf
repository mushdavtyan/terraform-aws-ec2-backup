output "fxctest_ssh_command" {
  value = "ssh -oStrictHostKeyChecking=no -i keys/fxctest.pem ec2-user@${aws_instance.fxctesthost.public_ip}"
}

output "backup_folder_path" {
  value = "s3://${var.bucket_name}/backup/"
}