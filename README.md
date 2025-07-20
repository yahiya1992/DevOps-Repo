##  Prerequisites

- Terraform v1.3+
- AWS CLI (configured)
- IAM credentials with appropriate access
- Backend storage (S3 bucket and DynamoDB table)

# Initialize Terraform (downloads modules and sets up backend)
terraform init

# Preview changes
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"

terraform destroy -var-file="terraform.tfvars"

# Notes
Make sure the terraform.tfvars file contains required variable values.
Ensure backend resources (like S3 and DynamoDB) are created before running init.

Tools Used

| Category   | Tool                      |
| ---------- | ------------------------- |
| IaC        | Terraform     |
| Platform   | AWS (EKS, RDS, IAM)       |
| CI/CD      | Azure DevOps              |
| Container  | Docker, Helm              |
| Secrets    | External Secrets Operator |
| Monitoring | Prometheus, Loki, Grafana |
| Storage    | AWS S3                    |


##  Assumptions

1. The application is containerized and exposed over HTTPS.
2. External secrets are pre-created and available in AWS Secrets Manager.
3. AWS credentials and permissions are already configured and available to the infrastructure and CI/CD processes.
4. Workloads are deployed to EKS using manifest files or Kubernetes-native deployment methods.

---

##  Reflection

**Decisions made that were not explicitly asked for:**

1. **Adopted External Secrets Operator (ESO):** Instead of injecting secrets manually or via environment variables, I used ESO to dynamically pull secrets from AWS Secrets Manager and inject them into Kubernetes securely.
2. **Implemented full observability stack:** Chose Prometheus, Loki, and Grafana to cover both metrics and logs, offering detailed visibility into application and cluster health.
3. **Chose EKS over ECS, Elastic Beanstalk, or EC2** for the following reasons:
   - **Flexibility & Portability:** Kubernetes APIs provide a more extensible and vendor-agnostic platform for deploying containerized applications.
   - **Support for Multi-Service Architecture:** Kubernetes offers better control over networking (via CNI), role-based access (RBAC), and supports service meshes and ingress patterns out of the box.
   - **Scalability:** EKS allows auto-scaling of nodes and pods, enabling better resource utilization for dynamic workloads.
