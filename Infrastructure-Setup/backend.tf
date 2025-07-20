terraform {
  backend s3 {
    bucket         = my-tfstate-bucket
    key            = terraformdevterraform.tfstate
    region         = us-east-1
    encrypt        = true
    dynamodb_table = terraform-locks
  }
}
