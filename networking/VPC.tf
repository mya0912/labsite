#specify provider
provider "aws" {
  region = "us-east-2"
}

#create VPC for lab site
resource "aws_vpc" "labsiteVPC" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name    = "labsiteVPC"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create internet gateway and attach vpc
resource "aws_internet_gateway" "labsiteIGW" {
  vpc_id = "${aws_vpc.labsiteVPC.id}"

  tags = {
    Name    = "labsiteIGW"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create subnet to house bastion bost - subnet1 is public
resource "aws_subnet" "subnet1" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.10.0/28"
  availability_zone = "us-east-2a"

  tags = {
    Name    = "labsiteVPC-subnet1"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#Route table for subnet1
resource "aws_route_table" "routetbl" {
  vpc_id = "${aws_vpc.labsiteVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.labsiteIGW.id}"
  }

  tags = {
    Name    = "labsite Route Table"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#association between routetable1 and subnet1
resource "aws_route_table_association" "subnet1-a" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.routetbl.id}"
}

#create private subnet to place webservers in
resource "aws_subnet" "subnet2" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.20.0/28"
  availability_zone = "us-east-2b"

  tags = {
    Name    = "labsiteVPC-subnet2"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create second private subnet to place webservers in
resource "aws_subnet" "subnet3" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.30.0/28"
  availability_zone = "us-east-2c"

  tags = {
    Name    = "labsiteVPC-subnet3"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create security group for bastion host
resource "aws_security_group" "bastionSG" {
  name        = "bastionSG"
  description = "port 22 open IP restricted"
  vpc_id      = "${aws_vpc.labsiteVPC.id}"

  ingress {
    # ssh port open, restricted to my ip
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["108.56.71.0/24", "67.154.234.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create security group for webservers - modify once placed behind load balancer
resource "aws_security_group" "webserverSG" {
  name        = "webserverSG"
  description = "Allow all traffic"
  vpc_id      = "${aws_vpc.labsiteVPC.id}"

  ingress {
    # ssh port open, restricted to my ip
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["20.0.10.0/28"]
  }

  ingress {
    # http open
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # https open
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
