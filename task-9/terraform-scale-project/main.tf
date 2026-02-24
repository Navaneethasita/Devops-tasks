resource "aws_instance" "app" {
  count         = 5
  ami           = "ami-0320940581663281e" # Amazon Linux 2 (us-east-1)
  instance_type = "t3.micro"

  tags = {
    Name = "scaled-instance-${count.index}"
  }
}

