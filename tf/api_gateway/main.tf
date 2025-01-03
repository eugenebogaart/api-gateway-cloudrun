resource "random_id" "key_suffix" {
  byte_length = 8
}

resource "google_project_service" "api" {
  service            = "apigateway.googleapis.com"
  disable_on_destroy = false
}

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = "sudokumain-fastapi"
  display_name = "${var.app_name}-api"
  depends_on   = [ google_project_service.api ]
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider   = google-beta
  api        = google_api_gateway_api.api_gw.api_id

  openapi_documents {
    document {
      path     = "openapi2-run.yaml"
      contents = base64encode(templatefile( "${var.main_dir}/openapi2-run.tmpl2.yaml", {
            #  base = module.cloud_run.google_cloud_run_v2_service.app.uri
             base = var.uri
          }
      ))
    }
  }
  
  # The config id is updated so a new version is created
  # Lifecycle will drop the previous config after creation
  api_config_id = "config-${random_id.key_suffix.hex}"
  # lifecycle {
  #   create_before_destroy = true
  # }
}



resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "${var.app_name}-gw"
}


resource "google_project_service" "project" {
  depends_on = [  
      google_api_gateway_api.api_gw,
      google_api_gateway_api_config.api_cfg,
      google_api_gateway_gateway.api_gw
  ]
  project = var.app_project
  service = google_api_gateway_api.api_gw.managed_service

}
