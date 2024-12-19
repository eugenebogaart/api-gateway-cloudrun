# define GCP project name
variable "app_project" {
  type        = string
  description = "GCP project name"
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