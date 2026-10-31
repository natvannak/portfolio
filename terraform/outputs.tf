
output "vpc_id" {
  value = data.aws_vpc.portfolio.id
}

output "subnet_id" {
  value = data.aws_subnet.portfolio.id
}

output "security_group_id" {
  value = data.aws_security_group.portfolio_swarm.id
}

output "manager_private_ip" {
  value = data.aws_instance.manager.private_ip
}

output "worker1_private_ip" {
  value = data.aws_instance.worker1.private_ip
}

output "worker2_private_ip" {
  value = data.aws_instance.worker2.private_ip
}
