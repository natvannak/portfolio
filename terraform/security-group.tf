
resource "aws_security_group" "portfolio_swarm" {
  name        = "portfolio-swarm-sg"
  description = "Portfolio Docker Swarm Cluster"
  vpc_id      = "vpc-09688e076d4814617"

  lifecycle {
    prevent_destroy = true
  }
}
