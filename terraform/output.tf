output "fxctest_ssh_command" {
  value = "ssh -oStrictHostKeyChecking=no -i keys/fxctest.pem ec2-user@${aws_instance.fxctesthost.public_ip}"
}
