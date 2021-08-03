provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-02b4e72b17337d6c1"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
