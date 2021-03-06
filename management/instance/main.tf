data "aws_ami" "standard" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.image-search-path}"]
  }
}

module "role" {
  source      = "../role"
  namespace   = "${var.name_prefix}-profile-${var.namespace}"
  aws_profile = "${var.aws_profile}"
  aws_region  = "${var.aws_region}"
}

resource "aws_instance" "node" {
  count                = "${var.cluster_size}"
  ami                  = "${data.aws_ami.standard.id}"
  instance_type        = "${var.instance_type}"
  subnet_id            = "${element(var.subnet_ids, count.index)}"
  security_groups      = ["${var.security_groups}"]
  key_name             = "${var.key_name}"
  user_data            = "${var.userdata}"
  iam_instance_profile = "${module.role.iam_instance_profile}"

  root_block_device {
    volume_type = "gp2"
  }

  tags {
    Name    = "${var.name_prefix}-cluster-${var.namespace}-${count.index}"
    Service = "${var.ec2_tag_value}"
  }
}
