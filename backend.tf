terraform {
  backend "s3" {
    bucket  = "aws-eus1-eks-statefile"
    key     = "eks/networking/terraform.tfstate"
    region  = "us-east-1"
  }
}
