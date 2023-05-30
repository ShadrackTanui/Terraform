region  = "eu-west-1"
project = "nkm-sbacc"
tags = {
  "Environment"     = "sandbox"
  "Terraform"       = "true"
  "sharedResource"  = "Yes"
  "Owner"           = "nkmakau"
  "ManagedBy"       = "DevSecOps"
  "BusinessOwner"   = "Digital Engineering"
  "Project"         = "nkm-sbacc"
  "CreatedBy"       = "Noah Makau"
  "OrgBackupPolicy" = "None"
}

## EKS Nodes Values
eks_cluster_id         = "eu-west-1-nkm-sbacc-EKS-Cluster"
eks_cluster_name       = "eu-west-1-nkm-sbacc-EKS-Cluster"
eks_worker_subnet_id   = ["subnet-00a89cadf72a9902e", "subnet-0943ce65f16a37c62"]
ami_type               = "AL2_x86_64"
capacity_type          = "ON_DEMAND"
create_launch_template = true
desired_size           = "2"
instance_type_lt       = "t2.medium"
lt_version             = "$Latest"
max_size               = "6"
min_size               = "2"
node_group_name        = "nodegroup"
volume_size            = "80"
volume_type            = "gp3"

addons = [
    {
      name    = "coredns"
      version = "v1.9.3-eksbuild.3"
    }
  ]


##Karpenter Values
karpenter_namespace = "karpenter"
karpenter_version   = "v0.16.2"

# The variables below are used for the default Karpenter Provisioner that is deployed in this script
karpenter_ec2_instance_types = [
  "t3.large",
  "t3.medium",
  "m5.large",
  "m5a.large",
  "m5.xlarge",
  "m5a.xlarge",
  "m5.2xlarge",
  "m5a.2xlarge",
  "m6g.large",
  "m6g.xlarge",
  "m6g.2xlarge",
]
karpenter_vpc_az = [
  "eu-west-1a",
  "eu-west-1b",
]
karpenter_ec2_arch                  = ["amd64"]
karpenter_ec2_capacity_type         = ["spot", "on-demand"]
karpenter_ttl_seconds_after_empty   = 300
karpenter_ttl_seconds_until_expired = 604800            