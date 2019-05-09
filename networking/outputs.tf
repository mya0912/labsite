output "webserverSG_id" {
  value = "${aws_security_group.webserverSG.id}"
}

output "subnet1_id" {
  value = "${aws_subnet.subnet1.id}"
}

output "bastionSG_id" {
  value = "${aws_security_group.bastionSG.id}"
}

output "subnet2_id" {
  value = "${aws_subnet.subnet2.id}"
}

output "subnet3_id"{
  value = "${aws_subnet.subnet3.id}"
}

output "databaseSG_id" {
  value = "${aws_security_group.databaseSG.id}"
}
