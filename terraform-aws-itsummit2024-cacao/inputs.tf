variable "region" {
  type = string
  description = "string, aws region name; default = us-west-2"
  default = "us-west-2"
}

variable "instance_name" {
  type = string
  description = "name of instance"
  default = "terraform-aws-itsummit2024"
}

variable "user_data" {
  type = string
  description = "cloud init script"
  default = ""
}