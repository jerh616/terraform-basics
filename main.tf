provider "aws" {
  region = "eu-west-1"
}

resource "aws_launch_configuration" "example" {
  image_id      = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "Johnnie 5 alive?" > index.html
  nohup busybox httpd -f -p ${var.server_port} &
  EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# Use a datasource to get read-only info from the provider, aws_vpc in this case. 
data "aws_vpc" "default" {
  default = true
}

# Use another datasource that uses a datasource reference, to aws_vpc named default in this case,
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}
