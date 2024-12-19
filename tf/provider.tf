terraform {
  required_version = "~> 1.10.2"
  required_providers {
    google = {
        version = "~> 6.14.0"
    } 
    google-beta ={
        version = "~> 6.14.0"
    }
    null = {
        version = "~> 3.2.3"
    }
    random = {
        version = "~> 3.6.3"
    }
  }
}

provider "google" {

  project     = var.app_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}

provider "google-beta" {
  project = var.app_project
  region  = var.gcp_region
}