

variable "vpc_cidr" {
  description = "vpc cidr block"
  type = string
}
variable "public_subnets" {
  description = "List of public subnets"
  type = list(string)
}

variable "private_subnets" {
    description = "List of private subnets"
    type = list(string)
}

variable "aws_availability_zones" {
    description = "list of availability zones"
    type = list(string)
    default = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  
}

variable "max_size_node" {
  description = "Number of maximum nodes"
  type = number
  default = 1
}

variable "min_size_node" {
  description = "Number of minimum nodes"
  type = number
  default = 1
}

variable "desired_size_node" {
  description = "Number of desired nodes"
  type = number
  default = 1
}

variable "account_id" {
  description = "aws account id"
  type = number
}

variable "username"{
  description="username for secretmanager"
  default = "admin"
}

variable "password"{
  description="password for secret manager"
  default= "Admin1234"
}