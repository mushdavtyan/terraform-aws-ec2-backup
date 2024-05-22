resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags = merge(
    local.common_tags,
    tomap({
      "FXC:technology" = "s3",
      "FXC:purpose"    = "Storing backup files from the EC2 instance"
    })
  )
}

resource "aws_s3_bucket_ownership_controls" "fxctask" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "fxctask" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "fxctask" {
  depends_on = [
    aws_s3_bucket_ownership_controls.fxctask,
    aws_s3_bucket_public_access_block.fxctask,
  ]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action":["s3:Get*"],
      "Resource": "${aws_s3_bucket.s3_bucket.arn}/*",
      "Condition" : {
        "StringNotEquals": {
          "aws:sourceVpce": "${aws_vpc_endpoint.s3endpoint.id}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "fxctest-role" {
  name        = "fxctest-role"
  description = "privileges for the EC2 instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "fxctest-policy" {
  name        = "fxctest-policy"
  description = "allow read+write access to the bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*",
        "s3:Put*"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_bucket.arn}",
        "${aws_s3_bucket.s3_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3access" {
  role       = aws_iam_role.fxctest-role.name
  policy_arn = aws_iam_policy.fxctest-policy.arn
}

resource "aws_iam_instance_profile" "fxctask-instance-profile" {
  name = aws_iam_role.fxctest-role.name
  role = aws_iam_role.fxctest-role.id
}

data "aws_ssm_parameter" "latest_amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "fxctesthost" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux_2.value
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  subnet_id     = aws_subnet.fxctask_subnet.id

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}"
  ]
  provisioner "file" {
    source      = "${local.module_path}/../scripts/daily_backup.sh"
    destination = "/home/ec2-user/daily_backup.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/../keys/${var.ssh_key_name}.pem")
      host        = self.public_ip
      timeout     = "2m"
      agent       = true
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/scripts",
      "mv /home/ec2-user/daily_backup.sh /home/ec2-user/scripts/daily_backup.sh",
      "sudo chmod +x /home/ec2-user/scripts/daily_backup.sh",
      "echo '0 2 * * * sudo /home/ec2-user/scripts/daily_backup.sh ${var.backup_folder_path}' | sudo tee -a /etc/crontab",
      "sudo /home/ec2-user/scripts/daily_backup.sh ${var.backup_folder_path}"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/../keys/${var.ssh_key_name}.pem")
      host        = self.public_ip
      timeout     = "2m"
      agent       = true
    }
  }

  iam_instance_profile = aws_iam_instance_profile.fxctask-instance-profile.name

  tags = merge(
    local.common_tags,
    tomap({
      "FXC:Name"       = "fxctesthost",
      "FXC:technology" = "ec2",
      "FXC:purpose"    = "Creating a backup of the files and storing them in the S3 bucket"
    })
  )

  volume_tags = local.common_tags

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum install -y python3-pip
yum update -y aws-cli tar
pip3 install awscli --upgrade
echo 'export BACKUP_FOLDER_PATH=${var.backup_folder_path}' >> /etc/profile.d/backup_file_env.sh
EOF
}
