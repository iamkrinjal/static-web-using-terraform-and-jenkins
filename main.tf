provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "tf-key" {
  key_name   = "static-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "tf-sg" {
  name        = "allow-http"
  description = "Allow HTTP inbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf-key.key_name
  security_groups = [aws_security_group.tf-sg.name]

  user_data = file("userdata.sh")

  tags = {
    Name = "static-web"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
