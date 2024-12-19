#define service account credentials
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

# define GCP project name
variable "app_project" {
  type        = string
  description = "GCP project name"
}
# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
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

variable "build_args" {
  type        = string
  description = "docker build arguments"
}

variable "app_name" {
  type        = string
  description = "Name of application on cloud run"
}

variable "main_dir" {
  type        = string
  description = "Directory with Dockerfile & openapi.yaml file"
}

variable "uploader_passwd" {
  type        = string
  description = "Credentials to adding Puzzle"
}

variable "highscore_passwd" {
  type        = string
  description = "Credentials for to adding Score"
}

variable "querier_passwd" {
  type        = string
  description = "Credentials for to Read-only queriers"
}

variable "api_key" {
  type        = string
  description = "Required Key for insert Highscore and Progress"
}

