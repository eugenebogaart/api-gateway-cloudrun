
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

# define GCP region
variable "gcp_location" {
  type        = string
  description = "GCP region"
}

variable "image_name" {
  type        = string
  description = "image to be deployed on cloud run"
}

variable "readwrite_all_secret" {
    type      = string
    description = "Reference to Secret Id"
}

variable "readonly_querier_secret" {
    type      = string
    description = "Reference to Secret Id"
} 

variable "insert_score_secret" {
    type      = string
    description = "Reference to Secret Id"
} 

variable "api_key_secret" {
    type      = string
    description = "Reference to Secret Id"
}

variable "service_account" {
    type      = string
    description = "Deafault compute service account"
}