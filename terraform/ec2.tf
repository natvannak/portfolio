
resource "aws_instance" "swarm_manager" {
  ami                    = "ami-0d97d7f07b25dd693"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-04a7e95adbf6c6934"
  vpc_security_group_ids = ["sg-03d653a9a0625f4b7"]
  key_name               = "portfolio-swarm-key"

  tags = {
    Name = "portfolio-swarm-manager"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "swarm_worker1" {
  ami                    = "ami-0d97d7f07b25dd693"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-04a7e95adbf6c6934"
  vpc_security_group_ids = ["sg-03d653a9a0625f4b7"]
  key_name               = "portfolio-swarm-key"

  tags = {
    Name = "portfolio-swarm-worker1"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "swarm_worker2" {
  ami                    = "ami-0d97d7f07b25dd693"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-04a7e95adbf6c6934"
  vpc_security_group_ids = ["sg-03d653a9a0625f4b7"]
  key_name               = "portfolio-swarm-key"

  tags = {
    Name = "portfolio-swarm-worker2"
  }

  lifecycle {
    prevent_destroy = true
  }
}
