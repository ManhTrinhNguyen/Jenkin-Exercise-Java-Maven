provider "aws" {
 region = var.region
}

variable vpc_cidr_block {
 default = "10.0.0/16"
}

variable subnet_cidr_block {
 default = "10.0.10.0/24"
}

variable avail_zone {
 default = "us-west-1a"
}

variable env_prefix {
 default = "dev"
}

variable my_ip {
 default = "157.131.152.31/32"
}

variable instance_type {
 default = "t3.medium"
}

variable region {
 default = "us-west-1"
}

variable "env-prefix" {
  default = "dev"
}

variable "jenkin_ip" {
  default = "209.38.152.165/32"
}

