resource "aws_instance" "jumpstation" {
  ami = "${data.aws_ami.jump_station.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.jumpstation-sg.id}"]
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  associate_public_ip_address = "true"
  key_name = "${aws_key_pair.key_js.id}"
  tags {
    Name = "JumpStation"
  }
}

resource "aws_security_group" "jumpstation-sg" {
  name = "jumpstation security group"
  description = "security group for the jumpstation instance"
  vpc_id = "${aws_vpc.vpc-main.id}"
}

resource "aws_security_group_rule" "js_ssh_rule" {
  from_port = 22
  protocol = "6"
  security_group_id = "${aws_security_group.jumpstation-sg.id}"
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 22
  type = "ingress"
}

resource "aws_security_group_rule" "js_egress_rule" {
  from_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jumpstation-sg.id}"
  to_port = 0
  type = "egress"
}

resource "aws_key_pair" "key_js" {
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

data "aws_ami" "jump_station" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = ["available"]
  }

  owners = ["amazon"] # Canonical
}

output "jumphost_ip_address" {
  value = "${aws_instance.jumpstation.public_ip}"
}
