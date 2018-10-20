resource "aws_instance" "webserver" {
  ami = "${data.aws_ami.webserver.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.webserver_sg.id}"]
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  associate_public_ip_address = "true"
  key_name = "${aws_key_pair.key_ws.id}"
  tags {
    Name = "WebServer"
  }
}

resource "aws_security_group" "webserver_sg" {
  name = "webserver security group"
  description = "security group for the webserver instance"
  vpc_id = "${aws_vpc.vpc-main.id}"
  ingress {
    from_port = 80
    protocol = "6"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for webserver (http:80)"
  }
  ingress {
    from_port = 8080
    protocol = "6"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for webserver (http:8080)"
  }
  ingress {
    from_port = 443
    protocol = "6"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for webserver (https:443)"
  }
  ingress {
    from_port = 8443
    protocol = "6"
    to_port = 8443
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for webserver (https:8443)"
  }
  ingress {
    from_port = 22
    protocol = "6"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for webserver (ssh:22)"
  }
  ingress {
    from_port = 5000
    protocol = "6"
    to_port = 5000
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress rule for web service (http:5000)"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_ws" {
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

data "aws_ami" "webserver" {
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

output "webserver_ip_address" {
  value = "${aws_instance.webserver.public_ip}"
}

output "key_pem_file" {
  value = "${aws_key_pair.key_js.public_key}"
}
