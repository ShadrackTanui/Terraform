variable "mycount" {
  default = 1
}

variable "aws_vpc" {
  count   = 2
  type    = list(any)
  default = ["Eks-Vpc-1", "Eks-Vpc-2"]
}

variable "aws_cidr" {
  default = {
    "Eks-Vpc-2"      = "10.1.0.0/16"
    "vpc-devt-proja" = "10.3.0.0/16"
    "Eks-Vpc-1"      = "10.2.0.0/16"
    "vpc-devt-projx" = "10.4.0.0/16"
  }
}


