terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
#    bucket             = "remote_state_s3_bucket_name"
    bucket             = "eks-amazonq-tfstate-ndg"
    key              	 = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
    dynamodb_table = "app-state"
  }

}
provider "awscc" {
  region = var.region
}

provider "kubernetes" { 
 # config_path    = "${path.root}/modules/eks/config_map_aws_auth.yaml"
}

provider "aws" {
  region = var.region
}
