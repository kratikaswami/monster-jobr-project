resource "aws_db_instance" "db_instance" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "jobrdb"
  username             = "kratika"
  password             = "kratikaswami"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
  apply_immediately = "true"
  skip_final_snapshot = true
}

resource "aws_security_group" "db_sg" {
  name = "DB security group"
  description = "Security group for the DB instance."
  vpc_id = "${aws_vpc.vpc-main.id}"
  ingress {
    from_port = 3306
    protocol = "6"
    to_port = 3306
    security_groups = ["${aws_security_group.jumpstation-sg.id}", "${aws_security_group.webserver_sg.id}"]
  }
  egress {
    from_port = 3306
    protocol = "6"
    to_port = 3306
    security_groups = ["${aws_security_group.jumpstation-sg.id}", "${aws_security_group.webserver_sg.id}"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = ["${aws_subnet.private_subnet_a.id}",
    "${aws_subnet.private_subnet_b.id}",
    "${aws_subnet.private_subnet_c.id}"]
}

# strip out the port number from the db_instance endpoint
output "mysql_endpoint" {
  value = "${aws_db_instance.db_instance.endpoint}"
}

output "mysql_username" {
  value = "${aws_db_instance.db_instance.username}"
}

output "mysql_password" {
  value = "${aws_db_instance.db_instance.password}"
}

output "mysql_db" {
  value = "${aws_db_instance.db_instance.name}"
}
