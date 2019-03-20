resource "aws_instance" "webserver1" {
  ami                         = "ami-0de7daa7385332688"
  instance_type               = "t2.nano"
  subnet_id                   = "${var.subnet1_id}"
  associate_public_ip_address = "true"
  key_name                    = "Alipui_key"
  user_data                   = "${data.template_file.user_data_shell.rendered}"
  vpc_security_group_ids      = ["${var.security_group_id}"]

  tags = {
    Name    = "webserver1"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#specify data object to load user data inline
data "template_file" "user_data_shell"{
  template = <<-EOF
              #!/bin/bash
              sudo yum update
              sudo yum install -y httpd
              wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm.sig
              sudo rpm -U ./amazon-cloudwatch-agent.rpm
              sudo aws configure --profile labsite
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -s
              systemctl start httpd
              EOF
            }

resource "aws_key_pair" "MAkey" {
  key_name   = "Alipui_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7QmtubNRMtlzd5l2+fD6D7W2ZWu6giKFxLf3A9g9RUpAfUBPsKZF7PobLjXcd7ONwca7L3va8TjBSAt37ef0yPtCitPvBP45ZgvweVXMl+yMBHIPm5Tj8u3RrERGcz3C0fl2XtVp/g3XWwjyXEWBDCqz3HGqNXFDUIDft6b0hf/h79g2Ij5YzIL1Y3adjNsS6ZnBSvsLYZ8mK92+L/C8ZWvsDe7w5jf7CRkSTLEOY3Jxc3rdD9pQwcVHPDkZcHsEEQX18YaRUjkIMgzN3g5UxIsLrhWdP+SH36HyCMtS3aZ+TEgGFgiF5r6EJ4VgnuhmQzyOABHN3ocdn/eBbvTZgqtI8ZMFRrfFPtakz+qwtNMiB6rzyYQuBm/18kb4x8BXI+n9JnykkHhnZ42VVNz4tD+JRAFMEKcG13Uvwvg69MfPAlVSzSiz3bMwT7cYMmEvlP62dRw3NAC5uDzDAohmFPMRKarjygFhp6bwAR4IAbi42orF3wMX9ubZm/saYQJoDMt1Tc0LRrhjeTQ1h3tO3vBSl0Py59vKkjysKLNibHTXJnzGkWnW1FjW40t9+fOMLZrDHWYlN1QHdpPlrPaH6AW6DNVpjjREY8GI+/ZopK/B1vildpZ1FgtDKi3MGQ5UGKS2eV/eB8+4547vvNGgQ10Z21ORHc1ouuE1ED1E/Vw== myalipui@gmail.com"
}
