provider "aws" {
  region        = "us-east-2"
  }

resource "aws_vpc" "labsiteVPC" {
  cidr_block    = "20.0.0.0/16"

  tags          = {
    Name        = "labsiteVPC"
    Owner       = "Alipui"
    Project     = "WordpressSite"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id        = "${aws_vpc.labsiteVPC.id}"
  cidr_block    = "20.0.10.0/24"
  availability_zone = "us-east-2a"

  tags          = {
    Name        = "labsiteVPC-subnet1"
    Owner       = "Alipui"
    Project     = "WordpressSite"
  }
}
