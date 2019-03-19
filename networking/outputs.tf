output "webserverSG_id" {
  value = "${aws_security_group.webserverSG.id}"
}

output "subnet1_id" {
  value = "${aws_subnet.subnet1.id}"
}
