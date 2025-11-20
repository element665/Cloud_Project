variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "A unique name for the project, used as a prefix for resources."
  type        = string
  default     = "cloud-resume"
}

variable "domain_name" {
  description = "The root domain name for the website (e.g., example.com)."
  type        = string
}
