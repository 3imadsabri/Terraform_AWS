variable "aws_region" {
  type    = string
  default = "eu-west-3"
}
variable "project_name" {
  type    = string
  default = "wordpress-exam"
}
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "db_name" {
  type    = string
  default = "wordpress"
}
variable "db_username" {
  type    = string
  default = "wpadmin"
}
variable "db_password" {
  type      = string
  sensitive = true
  nullable   = false
}
