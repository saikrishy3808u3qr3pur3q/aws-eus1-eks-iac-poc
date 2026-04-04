# terraform {
#   backend "s3" {
#     bucket  = "your-terraform-state-bucket"
#     key     = "eks/networking/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }
