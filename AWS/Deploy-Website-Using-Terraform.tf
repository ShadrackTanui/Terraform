terraform {
    required_providers {
      aws = {
          source  = "hashicorp/aws"
      }
    }
}

# Configure the AWS Provider

provider "aws" {
  region = "us-east-1"
}

# Create VPC

resource "aws_vpc" "website_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
      name = "web-vpc"
    }
  
}

# Create Subnet
resource "aws_subnet" "website_subnet" {
  vpc_id     = aws_vpc.website_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "web_subnet"
  }
}

# Create route table

resource "aws_route" "website_route" {
    vpc_id = aws_vpc.website_vpc.id
  
  tags = {
      Name = web_route
  }
}

#Associate subnet with route table

resource "aws_route_table_association" "website_route_subnet" {
    subnet_id = aws_subnet.website_subnet.id
    route_table_id = aws_route.website_route.id

    tags = {
        Name = web_route_ass
    }
  
}

#Create internet gateway

resource "aws_internet_gateway" "website_igw" {
    vpc_id = aws_vpc.website_vpc.id

    tags = {
      Name = "web_igw"
    }
}

# Add default route into the route table to point to internet gateway

resource "aws_route" "default_route" {
    route_table_id = aws_route.website_route.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.website_igw.id
}

# Create a Security Group

resource "aws_security_group" "website_sg" {
  name        = "web_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.website_vpc.id


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 55
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "web_sg"
  }
}

# Create a private Key
resource "tls_private_key" "web-key" {
    algorithm = "RSA"
}

# Save the private key

resource "aws_key_pair" "website_instance_key" {
    key_name = "web-key"
    public_key = tls_private_key.web-key.public_key_openssh
}

#save your key to the local system

resource "local_file" "web-key" {
    content = tls_private_key.web-key.private_key_pem
    filename = "web-key.pem"
}

resource "aws_instance" "web" {
  ami           = "ami-08d4ac5b634553e16"
  instance_type = "t2.micro"
  count = 1
  subnet_id = aws_subnet.website_subnet.id
  security_groups = [ "aws_security_group.website_sg.id" ]

  provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        private_key = tls_private_key.web-key.private_key_pem
        host = aws_instance.web[0].public_ip
      }
      inline = [
          "sudo yum install httpd php git -y",
          "sudo systemctl restart httpd",
          "sudo systemctl enable httpd",   
      ]
    
  }
  tags = {
    Name = "website-instance"
  }
}

#create a block volume for data persistence

resource "aws_ebs_volume" "website_ebs" {
  availability_zone = "us-east-1a"
  size              = 1

  tags = {
    Name = "web-ebs"
  }
  
}

# Attach  ebs volume to your instance

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.website_ebs.id
  instance_id = aws_instance.web.id
  force_detach = true
}

# Mount the volume to your instance

resource "null_resource" "nullmount" {
  depends_on = [
    aws_ebs_volume.website_ebs
  ]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = tls_private_key.web-key.private_key_pem
    host = aws_instance.web[0].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/username/webpage1.git"

    ]
  
  }
  
}

#define s3 ID

locals {
  s3_origin_id = "s3-origin"
}

#Create a bucket to upload your static data

resource "aws_s3_bucket" "demowebsitebucket" {
  bucket = "demowebsitebucket"
  acl    = "public-read"
  region = "us-east-1"

  versioning {
    enabled = true
  }

  tags = {
    Name = "demowebsitebucket"
    Environment = "prod"
  }

  provisioner "local-exec" {
    command = "git clone https://github.com/username/webpage1.git web-server-image"
  }
}

#Allow public access to the bucket

resource "aws_s3_account_public_access_block" "public_storage" {
  bucket = "demowebsitebucket"
  block_public_acls = false
  block_public_policy = false
}

# Upload your data to s3 bucket

resource "aws_s3_bucket_object" "Object1" {
  bucket = "demowebsitebucket"
  acl = "public-read-write"
  key = "Demo1.PNG"
  source = "web-server-image/Demo1.PNG"

  
}

