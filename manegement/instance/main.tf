provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

data "aws_ami" "standard" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.image-search-path}"]
  }
}

resource "aws_instance" "node" {
  count                  = "${var.cluster_size}"
  ami                    = "${data.aws_ami.standard.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  security_groups        = "${var.security_groups}"
  key_name               = "${var.key_name}"
  private_ip             = "${element(split("/", cidrsubnet(element(var.subnet_cidr_blocks, count.index), 32 - element( split("/" , element(var.subnet_cidr_blocks, count.index) ), 1), coalesce(var.ip_ini,10) + count.index / length(var.subnet_cidr_blocks))), 0)}"
  user_data              = "${var.userdata}"

  root_block_device {
    volume_type = "gp2"
  }

  tags {
    Name    = "${var.name_prefix}-cluster-${var.namespace}-${count.index}"
    Service = "${var.ec2_tag_value}"
  }
}