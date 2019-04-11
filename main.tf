provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source = "./networking"
}

module "compute" {
  source         = "./compute"
  subnet1_id     = "${module.networking.subnet1_id}"
  subnet2_id     = "${module.networking.subnet2_id}"
  webserverSG_id = "${module.networking.webserverSG_id}"
  bastionSG_id   = "${module.networking.bastionSG_id}"
}
