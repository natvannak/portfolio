Portfolio Cloud Computing Project
Overview
This project demonstrates a multi-service application deployed on AWS EC2 using Docker Swarm, with GitHub for version control, Jenkins for CI, Docker Hub as the image registry, and Terraform for infrastructure-as-code tracking.
Implementation status note: Jenkins build, automated tests, and Docker image push have been verified in the current project history. Deployment/rollback to the live AWS Swarm has also been performed manually. An automated Jenkins-to-AWS deployment stage and GitHub webhook/SCM trigger have not yet been verified; do not describe them as completed until tested.

Architecture

Components
- GitHub: source control and version history.
- Jenkins (WSL): checks out code, builds Docker images, runs PHPUnit tests, and pushes images to Docker Hub.
- Docker Hub: stores versioned container images.
- Terraform (Windows): AWS provider configuration and imported resources for the existing VPC, subnet, security group, and three EC2 instances.
- AWS EC2: one Docker Swarm manager and two worker nodes.
- Docker Swarm: runs the application stack and service replicas.
- Nginx: public HTTP entry point/load balancer.
- Database: database service with persistent storage.
Technology Stack
- Git / GitHub
- Jenkins
- Terraform (AWS provider)
- Docker / Docker Compose
- Docker Swarm
- AWS EC2
- Nginx
- Laravel / PHP
- MySQL (confirm the database engine used by the deployed stack)
Repository Structure
portfolio/
├── app/                       # Application source (if present)
├── docker-compose.yml         # Local development services (if present)
├── Dockerfile                 # Application image build
├── Jenkinsfile                # CI pipeline
├── terraform/
│   ├── .terraform.lock.hcl
│   ├── ec2.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── security-group.tf
│   └── versions.tf
├── docker-stack.yml           # Swarm stack (confirm actual filename)
├── docs/
│   ├── architecture-diagram.png
│   └── screenshots/           # Add actual evidence screenshots
└── README.md
Adjust the tree above to match the actual repository. Remove entries that do not exist and add the real service/configuration filenames.

AWS Infrastructure
The current environment was recorded as:
- AWS Region: us-east-1
- Swarm manager: i-092faf5979fe9dee9 (172.31.27.31)
- Worker 1: i-03ee0ff0ac46081c2 (172.31.16.46)
- Worker 2: i-0bcde6e0204afe762 (172.31.31.13)
- VPC: vpc-09688e076d4814617
- Subnet: subnet-04a7e95adbf6c6934
- Security group: sg-03d653a9a0625f4b7
These identifiers are included as project documentation, not credentials. Do not publish private keys, access keys, .env files, Terraform state, or state backups.
Terraform
Run from the terraform/ directory:
terraform init
terraform fmt
terraform validate
terraform plan
terraform state list
The verified plan output was:
No changes. Your infrastructure matches the configuration.
The existing EC2 instances and security group were imported into Terraform state. This confirms that Terraform state matches the current configuration; it does not by itself prove that all infrastructure was originally provisioned by Terraform.

Terraform state is local and ignored by Git:
- terraform/terraform.tfstate
- terraform/terraform.tfstate.backup
- terraform/.terraform/
Do not commit state files. For a team/production workflow, configure a secure remote backend with locking before sharing state.
Jenkins CI Pipeline
The verified Jenkins pipeline includes:
1. Checkout selected Git tag/source.
2. Workspace preparation and validation.
3. Docker Compose build.
4. Composer install and Laravel setup.
5. PHPUnit automated tests.
6. Build versioned Docker images.
7. Docker Hub authentication and image push.
8. Verify image versions for rollback.
The recorded successful run completed the build, PHPUnit, and Docker Hub push stages. Confirm the current Jenkinsfile and add the Jenkins build URL/screenshot to the report.
Docker Swarm Operations
Use the commands below on the Swarm manager to collect current evidence:
docker node ls
docker stack ls
docker stack services portfolio
docker stack ps portfolio
docker service ls
Only run deployment commands after confirming the actual stack file and service names:
docker stack deploy -c docker-stack.yml portfolio
Do not remove database volumes or recreate live services during evidence collection.
Testing and Verification
Record actual outputs/screenshots for:
- Jenkins successful pipeline and PHPUnit test result.
- Docker image tags in Docker Hub.
- docker node ls showing manager and two Ready workers.
- docker stack services portfolio and docker stack ps portfolio.
- HTTP request to the public application URL.
- Rolling update and service availability test, if performed.
- Terraform terraform validate and terraform plan.
Example HTTP check:
Invoke-WebRequest http://<PUBLIC-IP> -UseBasicParsing
Replace <PUBLIC-IP> with the current public IP and record the actual HTTP status/result.
Challenges and Solutions
Document only challenges actually encountered. Examples from this implementation:
- Terraform initially planned unwanted instance replacement/destruction: the resource configuration did not contain all imported instance blocks. Restoring all three resource blocks aligned configuration with state; a subsequent plan reported no changes.
- Terraform state appeared as untracked files: .gitignore was updated to exclude .terraform/, *.tfstate, backups, and plan files while retaining .terraform.lock.hcl.
- Windows line-ending warning: Git warned that LF may be converted to CRLF for the provider lock file. This was a line-ending notice, not a commit failure.
- Jenkins workspace permissions: ownership/permissions of the workspace were corrected so the Jenkins service user could access generated files.
Security Notes
- Keep AWS access keys and private SSH keys out of Git.
- Restrict SSH access to trusted source IPs.
- Expose HTTP/HTTPS publicly only when required.
- Allow Swarm control/data-plane ports only between cluster nodes.
- Keep database ports private.
- Never publish .env, Terraform state, or credentials.
References
- Course handout: Cloud Computing Project Rubric (uploaded course document).
- HashiCorp Terraform documentation: https://developer.hashicorp.com/terraform/docs
- Docker documentation: https://docs.docker.com/
- Docker Swarm documentation: https://docs.docker.com/engine/swarm/
- Jenkins User Documentation: https://www.jenkins.io/doc/
- AWS EC2 User Guide: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html
- GitHub documentation: https://docs.github.com/
Final Submission Checklist
- [ ] Verify repository structure and correct all placeholder filenames.
- [ ] Add actual screenshots under docs/screenshots/.
- [ ] Confirm GitHub webhook/SCM trigger, or state clearly that builds are manual.
- [ ] Confirm Jenkins deployment stage, or state clearly that AWS deployment was manual.
- [ ] Capture current Swarm node/service/task outputs.
- [ ] Complete report cover page with student/course/date details.
- [ ] Export final report to PDF if the instructor requires PDF.