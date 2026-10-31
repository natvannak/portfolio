
# Reference the existing AWS VPC
data "aws_vpc" "portfolio" {
  id = "vpc-09688e076d4814617"
}

# Reference the existing subnet
data "aws_subnet" "portfolio" {
  id = "subnet-04a7e95adbf6c6934"
}

# Reference the existing Swarm security group
data "aws_security_group" "portfolio_swarm" {
  id = "sg-03d653a9a0625f4b7"
}

# Reference existing EC2 instances
data "aws_instance" "manager" {
  instance_id = "i-092faf5979fe9dee9"
}

data "aws_instance" "worker1" {
  instance_id = "i-03ee0ff0ac46081c2"
}

data "aws_instance" "worker2" {
  instance_id = "i-0bcde6e0204afe762"
}
