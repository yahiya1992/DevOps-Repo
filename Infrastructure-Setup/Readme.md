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
