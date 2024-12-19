# define GCP project name
variable "app_project" {
  type        = string
  description = "GCP project name"
}

variable "app_name" {
  type        = string
  description = "Name of application on cloud run"
}

variable "main_dir" {
  type        = string
  description = "Directory with Dockerfile & openapi.yaml file"
}

# variable "api" {
#   type        = string
#   description = "API that is deployed"
# }

variable "uri" {
  type      = string
  default   = "URI of back-end Cloud Run Service"
}