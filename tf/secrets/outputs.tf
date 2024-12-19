output "readwrite_all_secret" {
    value = google_secret_manager_secret.readwrite_all.secret_id
}

output "readonly_querier_secret" {
    value = google_secret_manager_secret.readonly_querier.secret_id
}

output "insert_secore_secret" {
    value =  google_secret_manager_secret.insert_score.secret_id
}

output "api_key_secret" {
    value = google_secret_manager_secret.api_key.secret_id
}
