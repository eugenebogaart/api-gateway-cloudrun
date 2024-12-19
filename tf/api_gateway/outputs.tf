output "managed_service" {
  value = google_api_gateway_api.api_gw.managed_service
}

# output "api_gw" {
#   value = google_api_gateway_api.api_gw
# }

# output "api_cfg" {
#   value = google_api_gateway_api_config.api_cfg
# }

# output "api_gw_gw" {
#   value = google_api_gateway_gateway.api_gw
# }

output "gateway_address" {
  description = "Gateway Address:"
  value = google_api_gateway_gateway.api_gw.default_hostname
}


# Print the config after provisioning
output "api_config_doc" {
  description = "API Gateway config:"
  value = base64decode(google_api_gateway_api_config.api_cfg.openapi_documents[0].document[0].contents)
}