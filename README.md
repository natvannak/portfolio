# Terraform AWS Docker Swarm – CI/CD

## Project Overview
This project automates cloud infrastructure provisioning and application deployment using Terraform, AWS EC2, Docker, Docker Hub, Docker Swarm, Jenkins, and GitHub.

## Technologies
- **GitHub:** Source Code Management
- **Jenkins:** CI/CD Automation
- **Terraform:** Infrastructure as Code (IaC)
- **AWS EC2:** Cloud Servers
- **Docker:** Containerization
- **Docker Hub:** Image Registry
- **Docker Swarm:** Container Orchestration

## Architecture

```text
Developer
    |
  GitHub
    |
  Jenkins
    |
 Terraform
    |
  AWS EC2
    |
 Docker Swarm
    |
 Manager + Workers
    |
 Application Deployment
```

## Jenkins Pipeline
1. Checkout GitHub
2. Verify Project Files
3. Prepare SSH Keys
4. Terraform Init
5. Terraform Validate
6. Terraform Plan
7. Terraform Apply
8. Terraform Output

## Docker Commands

```bash
docker ps
docker images
docker build -t username/app:1.0 .
docker push username/app:1.0
docker pull username/app:1.0
```

## Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Docker Swarm Commands

```bash
docker swarm init
docker node ls
docker service ls
docker stack deploy -c docker-compose.yml portfolio
docker stack ls
docker stack rm portfolio
```

## Deployment
After successful deployment, access the application through:

```text
http://EC2-PUBLIC-IP
```

