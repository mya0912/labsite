#creates database
resource "aws_db_instance" "labsite_db" {
  identifier                = "labsite-db"
  allocated_storage         = 5
  storage_type              = "standard"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t2.micro"
  name                      = "labsitedb"
  username                  = "admin"
  password                  = "${var.dbpwd}"
  backup_retention_period   = 5
  db_subnet_group_name      = "db_subnet"
  vpc_security_group_ids    = ["${var.dbSG_id}"]
  skip_final_snapshot       = "true"

  tags = {
    Name    = "WP backend db"
    Owner   = "Alipui"
    Project = "labsite"
  }
}

#backlog item - sns topic to publish database events

#creates db subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = ["${var.dbsubnet1_id}", "${var.dbsubnet2_id}"]
}
