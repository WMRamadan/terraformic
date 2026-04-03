data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "this" {
  count      = var.enable_public_ssh ? 1 : 0
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

module "network" {
  source               = "./modules/aws-network"
  name                 = var.project_name
  cluster_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  nat_gateway_per_az   = var.nat_gateway_per_az
}

module "eks" {
  source                               = "./modules/aws-eks"
  name                                 = var.project_name
  vpc_id                               = module.network.vpc_id
  vpc_cidr                             = module.network.vpc_cidr
  subnet_ids                           = module.network.private_subnet_ids
  cluster_version                      = var.cluster_version
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enabled_cluster_log_types            = var.enabled_cluster_log_types
  cluster_log_retention_days           = var.cluster_log_retention_days
  node_instance_type                   = var.node_instance_type
  node_per_az                          = var.node_per_az
  node_min_per_az                      = var.node_min_per_az
  node_max_per_az                      = var.node_max_per_az
  key_name                             = var.enable_public_ssh ? aws_key_pair.this[0].key_name : null
  enable_public_ssh                    = var.enable_public_ssh
  ssh_allowed_cidrs                    = var.ssh_allowed_cidrs
  enable_efs                           = var.enable_efs
}

data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

resource "kubernetes_storage_class" "efs" {
  count      = (var.enable_efs && var.manage_kubernetes_resources) ? 1 : 0
  depends_on = [module.eks]

  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  provisioner         = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"

  parameters = {
    fileSystemId = module.eks.efs_id
  }
}

check "subnet_topology" {
  assert {
    condition     = length(var.public_subnet_cidrs) == length(var.private_subnet_cidrs)
    error_message = "public_subnet_cidrs and private_subnet_cidrs must have the same number of entries."
  }

  assert {
    condition     = length(var.private_subnet_cidrs) <= length(data.aws_availability_zones.available.names)
    error_message = "Not enough availability zones in selected region for the requested subnet layout."
  }
}

check "public_endpoint_cidrs" {
  assert {
    condition = (
      var.cluster_endpoint_public_access == false ||
      length(var.cluster_endpoint_public_access_cidrs) > 0
    )
    error_message = "cluster_endpoint_public_access_cidrs must be set when cluster_endpoint_public_access is true."
  }
}

check "ssh_cidrs" {
  assert {
    condition = (
      var.enable_public_ssh == false ||
      length(var.ssh_allowed_cidrs) > 0
    )
    error_message = "ssh_allowed_cidrs must be set when enable_public_ssh is true."
  }
}
