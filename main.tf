provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-02b4e72b17337d6c1"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Johnnie 5 alive?" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "terraform-example"
  }
}
