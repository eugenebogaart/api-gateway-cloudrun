module "cloud_run" {
  source           = "./cloud_run"
  app_project      = var.app_project
  app_name         = var.app_name
  main_dir         = var.main_dir
  gcp_location     = var.gcp_location
  image_name       = var.image_name
  service_account  = var.service_account
  readwrite_all_secret =  module.secrets.readwrite_all_secret
  readonly_querier_secret = module.secrets.readonly_querier_secret
  insert_score_secret =  module.secrets.insert_secore_secret
  api_key_secret   = module.secrets.api_key_secret

  depends_on = [ google_project_service.run ]
}


module "api_gateway" {
  source           = "./api_gateway"
  app_project      = var.app_project
  app_name        = var.app_name
  main_dir        = var.main_dir
  # api             = google_project_service.api
  uri             = module.cloud_run.cloud_run_app.uri

  depends_on = [ google_project_service.run, module.cloud_run ]
}

output "gateway_address" {
  value = module.api_gateway.gateway_address
}

output api_config_doc {
  value = module.api_gateway.api_config_doc
}

module "secrets" {
  source    = "./secrets"
  app_project      = var.app_project
  uploader_passwd = var.uploader_passwd
  highscore_passwd = var.highscore_passwd
  querier_passwd = var.querier_passwd
  api_key = var.api_key

  depends_on = [ google_project_service.run ]
}





# Service account needs to have: 'Secret Manager Admin' 
#  -> IAM -> View By Roles -> Grant Access 

resource "google_project_service" "run" {
  for_each = toset([
      "run.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "cloudbuild.googleapis.com",
      "secretmanager.googleapis.com",
      "apigateway.googleapis.com",
      "apikeys.googleapis.com",
      "servicecontrol.googleapis.com",
      "compute.googleapis.com"
  ])
  service = each.value
  disable_on_destroy = false
}

resource "random_id" "key_suffix" {
  byte_length = 8
}

# Key are not actually deleted, can be restored witin 30 days
# Therefor the name is taken, and should be randomized.
resource "google_apikeys_key" "cloud_run" {
  name         = "fast-api-ex-key-${random_id.key_suffix.hex}"
  display_name = "Key for access to SudokuMain API"

  restrictions {
        # Example of whitelisting Maps Javascript API and Places API only
        api_targets {
            # The APi on Gateway needs to be on restriction list
            # of the API KEY
            service = module.api_gateway.managed_service
        }
  }
}

output "API_gateway_key" {
   sensitive = true
   value = google_apikeys_key.cloud_run.key_string
}

# resource "google_compute_network" "network" {
#   project                 = var.app_project # Replace this with your project ID in quotes
#   name                    = "tf-prod-network"
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "vpc_subnetwork" {
#   project                  = google_compute_network.network.project
#   name                     = "tf-prod-subnetwork"
#   ip_cidr_range            = "10.2.0.0/16"
#   region                   = var.gcp_location
#   network                  = google_compute_network.network.id
#   private_ip_google_access = true
# }