provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source        = "./networking"
  webserver1_id = "${module.compute.webserver1_id}"
  webserver2_id = "${module.compute.webserver2_id}"
}

module "compute" {
  source         = "./compute"
  bastion_subnet = "${module.networking.subnet1_id}"
  websubnet1_id  = "${module.networking.subnet2_id}"
  websubnet2_id  = "${module.networking.subnet3_id}"
  webserverSG_id = "${module.networking.webserverSG_id}"
  bastionSG_id   = "${module.networking.bastionSG_id}"
}

module "database" {
  source        = "./database"
  dbpwd         = "{var.dbpwd}"
  dbSG_id = "${module.networking.databaseSG_id}"
  dbsubnet1_id  = "${module.networking.subnet2_id}"
  dbsubnet2_id  = "${module.networking.subnet3_id}"
}
