# provider.tf
provider "aws" {
  version    = "~> 2.22.0"
  region     = "us-east-2"
  assume_role {
	role_arn     = "arn:aws:iam::************:role/ec2-role-for-creating-ekscluster"
  }
}
