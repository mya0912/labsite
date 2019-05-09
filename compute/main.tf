resource "aws_instance" "bastion" {
  ami                         = "ami-0de7daa7385332688"
  instance_type               = "t2.nano"
  subnet_id                   = "${var.bastion_subnet}"
  associate_public_ip_address = "true"
  key_name                    = "Alipui_key"
  user_data                   = "${data.template_file.bastion_init.rendered}"
  vpc_security_group_ids      = ["${var.bastionSG_id}"]
  monitoring                  = "true"

  tags = {
    Name    = "bastion host"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

resource "aws_instance" "webserver1" {
  ami           = "ami-0de7daa7385332688"
  instance_type = "t2.nano"
  subnet_id     = "${var.websubnet1_id}"

  #delete following ilne once load ballancer built
  #associate_public_ip_address = "true"
  key_name = "Alipui_key"

  user_data              = "${data.template_file.webserver_init.rendered}"
  vpc_security_group_ids = ["${var.webserverSG_id}"]
  monitoring             = "true"

  tags = {
    Name    = "webserver1"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

resource "aws_instance" "webserver2" {
  ami           = "ami-0de7daa7385332688"
  instance_type = "t2.nano"
  subnet_id     = "${var.websubnet2_id}"

  #delete following line once load balancer built
  #associate_public_ip_address = "true"
  key_name = "Alipui_key"

  user_data              = "${data.template_file.webserver_init.rendered}"
  vpc_security_group_ids = ["${var.webserverSG_id}"]
  monitoring             = "true"

  tags = {
    Name    = "webserver2"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create data template resource for bastion user data
data "template_file" "bastion_init" {
    template = "${file("compute/bastion_init.sh")}"
}

#create data template resource for webserver user data
data "template_file" "webserver_init" {
  template = "${file("compute/webserver_init.sh")}"
}

resource "aws_key_pair" "MAkey" {
  key_name   = "Alipui_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7QmtubNRMtlzd5l2+fD6D7W2ZWu6giKFxLf3A9g9RUpAfUBPsKZF7PobLjXcd7ONwca7L3va8TjBSAt37ef0yPtCitPvBP45ZgvweVXMl+yMBHIPm5Tj8u3RrERGcz3C0fl2XtVp/g3XWwjyXEWBDCqz3HGqNXFDUIDft6b0hf/h79g2Ij5YzIL1Y3adjNsS6ZnBSvsLYZ8mK92+L/C8ZWvsDe7w5jf7CRkSTLEOY3Jxc3rdD9pQwcVHPDkZcHsEEQX18YaRUjkIMgzN3g5UxIsLrhWdP+SH36HyCMtS3aZ+TEgGFgiF5r6EJ4VgnuhmQzyOABHN3ocdn/eBbvTZgqtI8ZMFRrfFPtakz+qwtNMiB6rzyYQuBm/18kb4x8BXI+n9JnykkHhnZ42VVNz4tD+JRAFMEKcG13Uvwvg69MfPAlVSzSiz3bMwT7cYMmEvlP62dRw3NAC5uDzDAohmFPMRKarjygFhp6bwAR4IAbi42orF3wMX9ubZm/saYQJoDMt1Tc0LRrhjeTQ1h3tO3vBSl0Py59vKkjysKLNibHTXJnzGkWnW1FjW40t9+fOMLZrDHWYlN1QHdpPlrPaH6AW6DNVpjjREY8GI+/ZopK/B1vildpZ1FgtDKi3MGQ5UGKS2eV/eB8+4547vvNGgQ10Z21ORHc1ouuE1ED1E/Vw== myalipui@gmail.com"
}
