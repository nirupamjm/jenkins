provider "aws" {
  region = "ap-southeast-2" # Change this to your desired region
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow inbound traffic for Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access to Jenkins UI
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-07ba57196a766fc6d" 
  instance_type = "t2.micro"
  key_name      = "jenkins-key"
  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-11-amazon-corretto
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              curl -fsSL https://pkg.jenkins.io/redhat/jenkins.io.key -o /tmp/jenkins.io.key
              sudo rpm --import /tmp/jenkins.io.key
              sudo yum install -y jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
