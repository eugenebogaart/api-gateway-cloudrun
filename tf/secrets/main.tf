resource "google_secret_manager_secret" "readwrite_all" {
  secret_id = "readwrite_all"
  project = var.app_project
  labels = {
    label = lower("UPLOADER-PASSWD")
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "readwrite_all_policy" {
  secret = google_secret_manager_secret.readwrite_all.id
  secret_data = "${var.uploader_passwd}"
  lifecycle {
    ignore_changes = [secret_data, enabled]
  }
}

resource "google_secret_manager_secret" "readonly_querier" {
  secret_id = "readonly_querier"
  project = var.app_project
  labels = {
    label = lower("QUERIER-PASSWD")
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "readonly_querier_policy" {
  secret = google_secret_manager_secret.readonly_querier.id
  secret_data = "${var.querier_passwd}"
  lifecycle {
    ignore_changes = [secret_data, enabled]
  }
}

resource "google_secret_manager_secret" "insert_score" {
  secret_id = "insert_score"
  project = var.app_project
  labels = {
    label = lower("HIGHSCORE-PASSWD")
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "insert_score_policy" {
  secret = google_secret_manager_secret.insert_score.id
  secret_data = "${var.highscore_passwd}"
  lifecycle {
    ignore_changes = [secret_data, enabled]
  }
}

# api-key
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"
  project = var.app_project
  labels = {
    label = lower("API_KEY")
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_key_policy" {
  secret = google_secret_manager_secret.api_key.id
  secret_data = "${var.api_key}"
  lifecycle {
    ignore_changes = [secret_data, enabled]
  }
}

