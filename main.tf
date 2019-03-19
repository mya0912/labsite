provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source = "./networking"
}

module "compute" {
  source = "./compute"
  subnet1_id = "${module.networking.subnet1_id}"
  security_group_id = "${module.networking.webserverSG_id}"
}
