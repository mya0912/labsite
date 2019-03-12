output "vpc_id" {
  value  = "${aws_vpc.labsiteVPC.id}"
}

output "subnet1_id"{
  value   = "${aws_subnet.subnet1.id}"
}
