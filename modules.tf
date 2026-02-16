module "vpc_subnets" {
  source = "./vpc_subnets"
}

module "acm" {
  source = "./acm"
}

module "alb" {
  source = "./alb"
  public_subnet_1_id = module.vpc_subnets.public_subnet_1_id
  vpc_id = module.vpc_subnets.vpc_id
  public_instance_id = module.EC2_instances.public_instance_id
  # my_ip = var.my_ip
  cert_arn = module.acm.cert_arn
  public_subnet_2_id = module.vpc_subnets.public_subnet_2_id
  public_instance_2_id = module.EC2_instances.public_instance_2_id
}

module "EC2_instances" {
  source = "./EC2_instances"
  cidr = module.vpc_subnets.vpc_cidr
  vpc_id = module.vpc_subnets.vpc_id
  my_ip = var.my_ip
  public_subnet_1_id = module.vpc_subnets.public_subnet_1_id
  public_subnet_2_id = module.vpc_subnets.public_subnet_2_id
  private_subnet_1_id = module.vpc_subnets.private_subnet_1_id
}


module "route53" {
  source = "./route53"
  lb_dns_name = module.alb.lb_dns_name
  lb_zone_id = module.alb.lb_zone_id
}





# 1. output from source
# 2. call the output variable from this block
# 3. Create an input variable (variables.tf) in the folder and call