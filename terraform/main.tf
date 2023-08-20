variable "cluster_name" {
  default = "Rocket-app-cluster"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "172.31.0.0/16"
}

variable "subnet_cidr_block" {
  default = "172.31.32.0/20"
}
