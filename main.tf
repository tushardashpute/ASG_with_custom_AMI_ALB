module "security_group" {
  source = "./sg"
}

module "auto_scaling_grp" {
  source = "./asg"


  security_groups  = [module.security_group.security_group_id]
  instance_type    = "t2.medium"
  key_name         = "eks_cluster"

}
