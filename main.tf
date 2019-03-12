provider "aws" {
  region        = "us-east-2"
  }

module "networking" {
  source        = "./networking"
}

resource "aws_instance" "webserver1"{
  ami           = "ami-0de7daa7385332688"
  instance_type = "t2.nano"
  subnet_id     = "${module.networking.subnet1_id}"

  tags = {
    Name        = "webserver1"
    Owner       = "Alipui"
    Project     = "WordpressSite"
  }
  }
