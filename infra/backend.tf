# Remote Backend Configuration
# Stores Terraform state in S3 so that CI/CD runs share state
# and don't attempt to re-create existing resources.
#
# ⚠️ ONE-TIME PREREQUISITE: You must create the S3 bucket and DynamoDB
#    table BEFORE running `terraform init` with this backend.
#    See the README for setup commands.

terraform {
  backend "s3" {
    bucket         = "newsapp-terraform-state"    # S3 bucket for state file
    key            = "newsapp/terraform.tfstate"   # Path inside the bucket
    region         = "eu-north-1"                  # Must match your provider region
    encrypt        = true                          # Encrypt state at rest
    dynamodb_table = "newsapp-terraform-lock"      # DynamoDB table for state locking
  }
}
