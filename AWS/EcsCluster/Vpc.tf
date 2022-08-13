resource "aws_vpc" "Eks-Vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "dafault"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "EksVpc"
  }

}