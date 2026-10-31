terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "worker_count" {
  type        = number
  description = "Number of Docker Swarm worker nodes"
  default     = 2
  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 5
    error_message = "worker_count must be between 1 and 5."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 Key Pair name"
  default     = "portfolio-swarm-key"
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/portfolio-swarm-key.pub"
  validation {
    condition     = fileexists(pathexpand(var.public_key_path))
    error_message = "SSH public key does not exist."
  }
}

variable "private_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = "~/.ssh/portfolio-swarm-key"
  validation {
    condition     = fileexists(pathexpand(var.private_key_path))
    error_message = "SSH private key does not exist."
  }
}

variable "ssh_user" {
  type        = string
  description = "Ubuntu SSH username"
  default     = "ubuntu"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR allowed to connect through SSH"
  default     = "0.0.0.0/0"
}

variable "app_image" {
  type        = string
  description = "Laravel application image"
  default     = "sortsom/portfolio-laravel:latest"
}

variable "nginx_image" {
  type        = string
  description = "Nginx image"
  default     = "nginx:alpine"
}

variable "mysql_image" {
  type        = string
  description = "MySQL image"
  default     = "mysql:8.4"
}

variable "stack_name" {
  type        = string
  description = "Docker Swarm stack name"
  default     = "portfolio"
}

variable "app_replicas" {
  type        = number
  description = "Number of Laravel application replicas"
  default     = 3
  validation {
    condition     = var.app_replicas >= 1 && var.app_replicas <= 10
    error_message = "app_replicas must be between 1 and 10."
  }
}

variable "nginx_replicas" {
  type        = number
  description = "Number of Nginx replicas"
  default     = 2
  validation {
    condition     = var.nginx_replicas >= 1 && var.nginx_replicas <= 10
    error_message = "nginx_replicas must be between 1 and 10."
  }
}

variable "published_port" {
  type        = number
  description = "Public Nginx port"
  default     = 8000
  validation {
    condition     = var.published_port >= 1 && var.published_port <= 65535
    error_message = "published_port must be between 1 and 65535."
  }
}

variable "app_container_port" {
  type        = number
  description = "HTTP port exposed by Laravel application container"
  default     = 80
  validation {
    condition     = var.app_container_port >= 1 && var.app_container_port <= 65535
    error_message = "app_container_port must be between 1 and 65535."
  }
}

variable "db_database" {
  type        = string
  description = "MySQL database name"
  default     = "portfoliodb"
}

variable "db_username" {
  type        = string
  description = "MySQL application username"
  default     = "portfolio"
}

variable "db_password" {
  type        = string
  description = "MySQL application password"
  sensitive   = true
  default     = "change_me"
}

variable "db_root_password" {
  type        = string
  description = "MySQL root password"
  sensitive   = true
  default     = "change_root_me"
}

variable "deploy_revision" {
  type        = string
  description = "Change this value to force Docker stack redeployment"
  default     = "5"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ec2_instance_type_offerings" "supported" {
  location_type = "availability-zone"
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

data "aws_subnets" "supported" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.supported.locations
  }
}

locals {
  supported_subnet_ids = sort(data.aws_subnets.supported.ids)
  manager_subnet_id    = local.supported_subnet_ids[0]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = trimspace(file(pathexpand(var.public_key_path)))

  tags = {
    Name      = var.key_name
    Project   = "portfolio-laravel"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "swarm_sg" {
  name_prefix = "portfolio-swarm-"
  description = "Security group for Docker Swarm"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = "portfolio-swarm-sg"
    Project   = "portfolio-laravel"
    ManagedBy = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.swarm_sg.id
  description       = "SSH access"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_allowed_cidr
}

resource "aws_vpc_security_group_ingress_rule" "application" {
  security_group_id = aws_security_group.swarm_sg.id
  description       = "Portfolio application through Nginx"
  ip_protocol       = "tcp"
  from_port         = var.published_port
  to_port           = var.published_port
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "swarm_management" {
  security_group_id            = aws_security_group.swarm_sg.id
  description                  = "Docker Swarm management"
  ip_protocol                  = "tcp"
  from_port                    = 2377
  to_port                      = 2377
  referenced_security_group_id = aws_security_group.swarm_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "swarm_tcp" {
  security_group_id            = aws_security_group.swarm_sg.id
  description                  = "Docker Swarm TCP communication"
  ip_protocol                  = "tcp"
  from_port                    = 7946
  to_port                      = 7946
  referenced_security_group_id = aws_security_group.swarm_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "swarm_udp" {
  security_group_id            = aws_security_group.swarm_sg.id
  description                  = "Docker Swarm UDP communication"
  ip_protocol                  = "udp"
  from_port                    = 7946
  to_port                      = 7946
  referenced_security_group_id = aws_security_group.swarm_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "overlay" {
  security_group_id            = aws_security_group.swarm_sg.id
  description                  = "Docker Swarm overlay network"
  ip_protocol                  = "udp"
  from_port                    = 4789
  to_port                      = 4789
  referenced_security_group_id = aws_security_group.swarm_sg.id
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.swarm_sg.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

locals {
  manager_user_data = <<-EOF
#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/docker-install.log) 2>&1
export DEBIAN_FRONTEND=noninteractive
hostnamectl set-hostname swarmmanager
sed -i '/^127\\.0\\.1\\.1/d' /etc/hosts
echo '127.0.1.1 swarmmanager' >> /etc/hosts
apt-get update -y
apt-get install -y docker.io openssh-client curl
systemctl enable --now docker
until docker info >/dev/null 2>&1; do sleep 5; done
usermod -aG docker ${var.ssh_user}
docker --version
EOF

  worker_user_data = [
    for i in range(var.worker_count) : <<-EOF
#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/docker-install.log) 2>&1
export DEBIAN_FRONTEND=noninteractive
hostnamectl set-hostname swarmwork${i + 1}
sed -i '/^127\\.0\\.1\\.1/d' /etc/hosts
echo '127.0.1.1 swarmwork${i + 1}' >> /etc/hosts
apt-get update -y
apt-get install -y docker.io openssh-client curl
systemctl enable --now docker
until docker info >/dev/null 2>&1; do sleep 5; done
usermod -aG docker ${var.ssh_user}
docker --version
EOF
  ]
}

locals {
  docker_compose = <<-YAML
services:
  app:
    image: ${var.app_image}
    working_dir: /var/www/html
    environment:
      APP_ENV: production
      APP_DEBUG: "false"
      LOG_CHANNEL: stderr
      DB_CONNECTION: mysql
      DB_HOST: db
      DB_PORT: "3306"
      DB_DATABASE: ${var.db_database}
      DB_USERNAME: ${var.db_username}
      DB_PASSWORD: ${var.db_password}
    networks:
      - portfolio_network
    deploy:
      mode: replicated
      replicas: ${var.app_replicas}
      placement:
        preferences:
          - spread: node.hostname
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 5
        window: 120s
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        monitor: 30s
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 5s
        failure_action: pause
        monitor: 30s
        order: stop-first

  nginx:
    image: ${var.nginx_image}
    command:
      - /bin/sh
      - -c
      - |
        cat > /etc/nginx/conf.d/default.conf <<'NGINXCONF'
        upstream portfolio_app {
            server app:${var.app_container_port};
        }
        server {
            listen 80;
            server_name _;
            client_max_body_size 100M;
            location / {
                proxy_pass http://portfolio_app;
                proxy_http_version 1.1;
                proxy_set_header Host $$host;
                proxy_set_header X-Real-IP $$remote_addr;
                proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $$scheme;
                proxy_set_header X-Forwarded-Host $$host;
                proxy_set_header X-Forwarded-Port $$server_port;
                proxy_connect_timeout 60s;
                proxy_send_timeout 60s;
                proxy_read_timeout 60s;
            }
        }
        NGINXCONF
        exec nginx -g 'daemon off;'
    ports:
      - target: 80
        published: ${var.published_port}
        protocol: tcp
        mode: ingress
    networks:
      - portfolio_network
    deploy:
      mode: replicated
      replicas: ${var.nginx_replicas}
      placement:
        preferences:
          - spread: node.hostname
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 5
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        monitor: 30s
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 5s
        failure_action: pause
        monitor: 30s
        order: stop-first

  db:
    image: ${var.mysql_image}
    environment:
      MYSQL_DATABASE: ${var.db_database}
      MYSQL_USER: ${var.db_username}
      MYSQL_PASSWORD: ${var.db_password}
      MYSQL_ROOT_PASSWORD: ${var.db_root_password}
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test:
        - CMD-SHELL
        - 'mysqladmin ping -h 127.0.0.1 -uroot -p"$${MYSQL_ROOT_PASSWORD}" --silent'
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s
    networks:
      - portfolio_network
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 10
        window: 120s

networks:
  portfolio_network:
    driver: overlay
    attachable: true

volumes:
  mysql_data:
    driver: local
YAML

  compose_hash = sha256(local.docker_compose)
}

resource "aws_instance" "manager" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.manager_subnet_id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.swarm_sg.id]
  associate_public_ip_address = true
  user_data                   = local.manager_user_data
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "swarmmanager"
    Hostname    = "swarmmanager"
    Role        = "manager"
    Project     = "portfolio-laravel"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "workers" {
  count                       = var.worker_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = element(local.supported_subnet_ids, count.index)
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.swarm_sg.id]
  associate_public_ip_address = true
  user_data                   = local.worker_user_data[count.index]
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "swarmwork${count.index + 1}"
    Hostname    = "swarmwork${count.index + 1}"
    Role        = "worker"
    Project     = "portfolio-laravel"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "null_resource" "swarm_setup" {
  depends_on = [aws_instance.manager, aws_instance.workers]

  triggers = {
    manager_id        = aws_instance.manager.id
    manager_private_ip = aws_instance.manager.private_ip
    worker_ids        = join(",", aws_instance.workers[*].id)
    worker_private_ips = join(",", aws_instance.workers[*].private_ip)
    app_image          = var.app_image
    nginx_image        = var.nginx_image
    mysql_image        = var.mysql_image
    app_replicas       = tostring(var.app_replicas)
    nginx_replicas     = tostring(var.nginx_replicas)
    compose_hash       = local.compose_hash
    deploy_revision    = var.deploy_revision
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = aws_instance.manager.public_ip
    private_key = file(pathexpand(var.private_key_path))
    timeout     = "5m"
  }

  provisioner "file" {
    source      = pathexpand(var.private_key_path)
    destination = "/home/${var.ssh_user}/swarm-worker-key"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/portfolio",
      "echo '${base64encode(local.docker_compose)}' | base64 --decode > /home/${var.ssh_user}/portfolio/docker-compose.yml",
      "chmod 600 /home/${var.ssh_user}/portfolio/docker-compose.yml",
      "chmod 600 /home/${var.ssh_user}/swarm-worker-key",
      "chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/portfolio"
    ]
  }

  provisioner "remote-exec" {
    inline = [<<-SCRIPT
set -eu
KEY_FILE="/home/${var.ssh_user}/swarm-worker-key"
COMPOSE_FILE="/home/${var.ssh_user}/portfolio/docker-compose.yml"
MANAGER_IP="${aws_instance.manager.private_ip}"
WORKER_IPS="${join(" ", aws_instance.workers[*].private_ip)}"
STACK_NAME="${var.stack_name}"
EXPECTED_NODES=$(( ${var.worker_count} + 1 ))

cleanup() {
  echo "Removing temporary SSH key..."
  rm -f "$KEY_FILE"
}
trap cleanup EXIT

remote() {
  IP="$1"
  shift
  ssh -i "$KEY_FILE" -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 "${var.ssh_user}@$IP" "$@"
}

echo "Waiting for Docker on manager..."
until sudo docker info >/dev/null 2>&1; do sleep 5; done

for IP in $WORKER_IPS; do
  echo "Waiting for Docker on worker $IP..."
  until remote "$IP" "sudo docker info >/dev/null 2>&1"; do sleep 10; done
done

MANAGER_STATE="$(sudo docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo inactive)"
MANAGER_CONTROL="$(sudo docker info --format '{{.Swarm.ControlAvailable}}' 2>/dev/null || echo false)"

if [ "$MANAGER_STATE" != "active" ]; then
  sudo docker swarm init --advertise-addr "$MANAGER_IP"
elif [ "$MANAGER_CONTROL" != "true" ]; then
  sudo docker swarm leave --force || true
  sudo docker swarm init --advertise-addr "$MANAGER_IP"
fi

WORKER_TOKEN="$(sudo docker swarm join-token -q worker)"

for IP in $WORKER_IPS; do
  WORKER_STATE="$(remote "$IP" "sudo docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo inactive")"
  WORKER_NODE_ID="$(remote "$IP" "sudo docker info --format '{{.Swarm.NodeID}}' 2>/dev/null || true")"
  NODE_EXISTS=false
  if [ -n "$WORKER_NODE_ID" ] && sudo docker node inspect "$WORKER_NODE_ID" >/dev/null 2>&1; then
    NODE_EXISTS=true
  fi

  if [ "$WORKER_STATE" = "active" ] && [ "$NODE_EXISTS" = "true" ]; then
    echo "Worker $IP already belongs to this Swarm."
  else
    if [ "$WORKER_STATE" = "active" ]; then
      remote "$IP" "sudo docker swarm leave --force || true"
    fi
    remote "$IP" "sudo docker swarm join --token '$WORKER_TOKEN' '$MANAGER_IP:2377'"
  fi
done

ATTEMPT=0
until [ "$(sudo docker node ls --format '{{.Status}}' | grep -c '^Ready$' || true)" -ge "$EXPECTED_NODES" ]; do
  ATTEMPT=$((ATTEMPT + 1))
  if [ "$ATTEMPT" -ge 60 ]; then
    sudo docker node ls || true
    exit 1
  fi
  sleep 10
done

echo "=================================================="
echo "Docker Swarm Nodes"
echo "=================================================="
sudo docker node ls

echo "=================================================="
echo "Validate Docker Stack Configuration"
echo "=================================================="
echo "Compose file: $COMPOSE_FILE"
sudo docker stack config --compose-file "$COMPOSE_FILE" >/dev/null
echo "Docker Stack configuration is valid."

sudo docker pull "${var.app_image}"
sudo docker pull "${var.nginx_image}"
sudo docker pull "${var.mysql_image}"

sudo docker stack deploy --compose-file "$COMPOSE_FILE" --resolve-image always --prune "$STACK_NAME"

ATTEMPT=0
while true; do
  APP_RUNNING="$(sudo docker service ls --filter name="$${STACK_NAME}_app" --format '{{.Replicas}}' 2>/dev/null || true)"
  NGINX_RUNNING="$(sudo docker service ls --filter name="$${STACK_NAME}_nginx" --format '{{.Replicas}}' 2>/dev/null || true)"
  DB_RUNNING="$(sudo docker service ls --filter name="$${STACK_NAME}_db" --format '{{.Replicas}}' 2>/dev/null || true)"

  if [ "$APP_RUNNING" = "${var.app_replicas}/${var.app_replicas}" ] && [ "$NGINX_RUNNING" = "${var.nginx_replicas}/${var.nginx_replicas}" ] && [ "$DB_RUNNING" = "1/1" ]; then
    break
  fi

  ATTEMPT=$((ATTEMPT + 1))
  if [ "$ATTEMPT" -ge 60 ]; then
    sudo docker stack services "$STACK_NAME" || true
    sudo docker stack ps "$STACK_NAME" --no-trunc || true
    exit 1
  fi
  sleep 10
done

sudo docker node ls
sudo docker stack services "$STACK_NAME"
sudo docker stack ps "$STACK_NAME" --no-trunc

echo "Deployment completed successfully."
SCRIPT
    ]
  }
}

output "aws_region" { value = var.aws_region }
output "vpc_id" { value = data.aws_vpc.default.id }
output "supported_availability_zones" { value = data.aws_ec2_instance_type_offerings.supported.locations }
output "supported_subnet_ids" { value = local.supported_subnet_ids }
output "manager_subnet_id" { value = aws_instance.manager.subnet_id }
output "worker_subnet_ids" { value = [for worker in aws_instance.workers : worker.subnet_id] }
output "security_group_id" { value = aws_security_group.swarm_sg.id }
output "key_pair_name" { value = aws_key_pair.deployer.key_name }
output "manager_instance_id" { value = aws_instance.manager.id }
output "manager_public_ip" { value = aws_instance.manager.public_ip }
output "manager_private_ip" { value = aws_instance.manager.private_ip }
output "worker_instance_ids" { value = aws_instance.workers[*].id }
output "worker_private_ips" { value = aws_instance.workers[*].private_ip }
output "worker_public_ips" { value = aws_instance.workers[*].public_ip }
output "swarm_manager_hostname" { value = "swarmmanager" }
output "swarm_worker_hostnames" { value = [for i in range(var.worker_count) : "swarmwork${i + 1}"] }
output "app_image" { value = var.app_image }
output "nginx_image" { value = var.nginx_image }
output "mysql_image" { value = var.mysql_image }
output "docker_compose_path" { value = "/home/${var.ssh_user}/portfolio/docker-compose.yml" }
output "application_url" { value = "http://${aws_instance.manager.public_ip}:${var.published_port}" }
output "ssh_manager_command" { value = "ssh -i ${pathexpand(var.private_key_path)} ${var.ssh_user}@${aws_instance.manager.public_ip}" }
