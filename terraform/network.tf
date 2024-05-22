resource "aws_vpc" "fxctask_vpc" {
  cidr_block           = var.fxctest_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    tomap({
      "FXC:Name"       = "fxctask",
      "FXC:technology" = "aws_vpc",
      "FXC:purpose"    = "VPC for fxctask"
    })
  )
}

resource "aws_subnet" "fxctask_subnet" {
  vpc_id                  = aws_vpc.fxctask_vpc.id
  cidr_block              = cidrsubnet(var.fxctest_vpc_cidr, 8, 1)
  map_public_ip_on_launch = true
  tags = merge(
    local.common_tags,
    tomap({
      "FXC:Name"       = "fxctask",
      "FXC:technology" = "aws_subnet",
      "FXC:purpose"    = "Subnet for fxctask"
    })
  )
}

resource "aws_internet_gateway" "fxctask_igw" {
  vpc_id = aws_vpc.fxctask_vpc.id
  tags = merge(
    local.common_tags,
    tomap({
      "FXC:Name"       = "fxctask-gw",
      "FXC:technology" = "internet_gateway",
      "FXC:purpose"    = "Internet gateway for VPC"
    })
  )

}

resource "aws_route_table" "fxctask_rt" {
  vpc_id = aws_vpc.fxctask_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fxctask_igw.id
  }
  tags = merge(
    local.common_tags,
    tomap({
      "FXC:Name"       = "fxctask-routing-table",
      "FXC:technology" = "route_table",
      "FXC:purpose"    = "Route table for VPC"
    })
  )
}

resource "aws_route_table_association" "fxctask_rta" {
  subnet_id      = aws_subnet.fxctask_subnet.id
  route_table_id = aws_route_table.fxctask_rt.id
}

resource "aws_vpc_endpoint" "s3endpoint" {
  vpc_id          = aws_vpc.fxctask_vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${aws_route_table.fxctask_rt.id}"]
}

# data "aws_ip_ranges" "s3ip" {
#   regions  = ["${var.region}"]
#   services = ["s3"]
# }

resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.fxctask_vpc.id
  name_prefix = "fxctask"
  description = "Allow all inbound ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = data.aws_ip_ranges.s3ip.cidr_blocks
  }

  tags = merge(
    local.common_tags,
    tomap({
      "FXC:technology" = "security-group",
      "FXC:purpose"    = "Allow all inbound ssh traffic"
    })
  )

}
