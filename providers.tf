# provider.tf
provider "aws" {
  version    = "~> 2.22.0"
  region     = "us-east-2"
  assume_role {
	role_arn     = "arn:aws:iam::556952635478:role/ec2-role-for-creating-ekscluster"
  }
}


module "security_group" {
  source = "./sg"
}

module "auto_scaling_grp" {
  source = "./asg"


  security_groups  = [module.security_group.security_group_id]
  instance_type    = "t2.medium"
  key_name         = "eks_cluster"

}
