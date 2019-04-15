#specify provider
provider "aws" {
  region = "us-east-2"
}

#create VPC for lab site
resource "aws_vpc" "labsiteVPC" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name    = "labsiteVPC"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create internet gateway and attach vpc
resource "aws_internet_gateway" "labsiteIGW" {
  vpc_id = "${aws_vpc.labsiteVPC.id}"

  tags = {
    Name    = "labsiteIGW"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create subnet to house bastion bost - subnet1 is public
resource "aws_subnet" "subnet1" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.10.0/28"
  availability_zone = "us-east-2a"

  tags = {
    Name    = "labsiteVPC-subnet1"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#Route table for subnet1
resource "aws_route_table" "routetbl" {
  vpc_id = "${aws_vpc.labsiteVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.labsiteIGW.id}"
  }

  tags = {
    Name    = "labsite Route Table"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#association between routetable1 and subnet1
resource "aws_route_table_association" "subnet1-a" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.routetbl.id}"
}

resource "aws_route_table_association" "subnet4-a" {
  subnet_id      = "${aws_subnet.subnet4.id}"
  route_table_id = "${aws_route_table.routetbl.id}"
}

#create private subnet to place webservers in
resource "aws_subnet" "subnet2" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.20.0/28"
  availability_zone = "us-east-2b"

  tags = {
    Name    = "labsiteVPC-subnet2"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create second private subnet to place webservers in
resource "aws_subnet" "subnet3" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.30.0/28"
  availability_zone = "us-east-2c"

  tags = {
    Name    = "labsiteVPC-subnet3"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}

#create additional public subnet for load balancer
resource "aws_subnet" "subnet4" {
  vpc_id            = "${aws_vpc.labsiteVPC.id}"
  cidr_block        = "20.0.40.0/28"
  availability_zone = "us-east-2b"

  tags = {
    Name    = "labsiteVPC-subnet4"
    Owner   = "Alipui"
    Project = "WordpressSite"
  }
}
#create security group for bastion host
resource "aws_security_group" "bastionSG" {
  name        = "bastionSG"
  description = "port 22 open IP restricted"
  vpc_id      = "${aws_vpc.labsiteVPC.id}"

  ingress {
    # ssh port open, restricted to my ip
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["108.56.71.0/24", "67.154.234.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create security group for webservers - modify once placed behind load balancer
resource "aws_security_group" "webserverSG" {
  name        = "webserverSG"
  description = "Allow all traffic"
  vpc_id      = "${aws_vpc.labsiteVPC.id}"

  ingress {
    # ssh port open, restricted to my ip
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["20.0.10.0/28"]
  }

  ingress {
    # http open
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # https open
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create load balancer
resource "aws_lb" "labsite_lb" {
  name               = "labsitelb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.webserverSG.id}"]
  subnets            = ["${aws_subnet.subnet2.id}", "${aws_subnet.subnet3.id}"]

  enable_deletion_protection = false

  access_logs {
    bucket  = "${aws_s3_bucket.logstash.bucket}"
    prefix  = "alb"
    enabled = true
  }

  tags = {
    Project = "WordpressSite"
    Owner   = "Alipui"
  }
}

#create s3 bucket for load balancer logs`
resource aws_s3_bucket "logstash" {
  bucket = "alipui-labsite-logs"
  acl    = "log-delivery-write"

  policy = <<POLICY
  {
      "Id": "LoggingBucketPolicy",
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "GrantPutS3LoggingBucket",
              "Action": "s3:PutObject",
              "Effect": "Allow",
              "Resource": "arn:aws:s3:::alipui-labsite-logs/alb/*",
              "Principal": {"AWS": ["033677994240"]}
          }
        ]
    }
POLICY
}

#add listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.labsite_lb.arn}"
  port              = "80"
  protocol          = "HTTP"
#  certificate_arn   = "${aws_acm_certificate.LabsiteCert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.labsitelb_tg.arn}"
  }
}

/*resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = "${aws_lb_listener.front_end.arn}"

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "LabsiteCert" {
  listener_arn    = "${aws_lb_listener.front_end.arn}"
  certificate_arn = "${aws_acm_certificate.LabsiteCert.arn}"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  */

#create load balancer target group
resource "aws_lb_target_group" "labsitelb_tg" {
  name     = "labsite-lb-targets"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.labsiteVPC.id}"

  health_check {
    path                = "/healthcheck"
    port                = "443"
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200-308"
  }
}

/*attach target group to instances - future improvement make this attachment to
an ASG as opposed to individual instances*/
resource "aws_lb_target_group_attachment" "labsitelb_tg_attachement1" {
  target_group_arn = "${aws_lb_target_group.labsitelb_tg.arn}"
  target_id        = "${var.webserver1_id}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "labsitelb_tg_attachement2" {
  target_group_arn = "${aws_lb_target_group.labsitelb_tg.arn}"
  target_id        = "${var.webserver2_id}"
  port             = 443
}
