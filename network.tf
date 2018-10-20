resource "aws_vpc" "vpc-main" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "vpc-main"
  }
}

resource "aws_subnet" "public_subnet_a" {
  cidr_block = "10.0.0.0/18"
  vpc_id = "${aws_vpc.vpc-main.id}"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"
  tags {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet_a" {
  cidr_block = "10.0.64.0/18"
  vpc_id = "${aws_vpc.vpc-main.id}"
  availability_zone = "eu-west-1a"
  tags {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet_b" {
  cidr_block = "10.0.128.0/18"
  vpc_id = "${aws_vpc.vpc-main.id}"
  availability_zone = "eu-west-1b"
  tags {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet_c" {
  cidr_block = "10.0.192.0/18"
  vpc_id = "${aws_vpc.vpc-main.id}"
  availability_zone = "eu-west-1c"
  tags {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc-main.id}"
  tags {
    Name = "igw"
  }
}

resource "aws_route" "internet_route" {
  route_table_id = "${aws_vpc.vpc-main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_eip" "eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc-main.id}"
    tags {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "public_subnet_route_association" {
    subnet_id = "${aws_subnet.public_subnet_a.id}"
    route_table_id = "${aws_vpc.vpc-main.main_route_table_id}"
}

resource "aws_route_table_association" "pr_1_subnet_eu_west_3a_association" {
    subnet_id = "${aws_subnet.private_subnet_a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "pr_2_subnet_eu_west_3b_association" {
    subnet_id = "${aws_subnet.private_subnet_b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "pr_2_subnet_eu_west_3c_association" {
    subnet_id = "${aws_subnet.private_subnet_c.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
