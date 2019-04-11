provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source = "./networking"
}

module "compute" {
  source         = "./compute"
  bastion_subnet    = "${module.networking.subnet1_id}"
  websubnet1_id     = "${module.networking.subnet2_id}"
  websubnet2_id     = "${module.networking.subnet3_id}"
  webserverSG_id = "${module.networking.webserverSG_id}"
  bastionSG_id   = "${module.networking.bastionSG_id}"
}
