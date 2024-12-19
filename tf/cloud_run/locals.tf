locals {
    artifact_image_name = "${var.gcp_location}-docker.pkg.dev/${var.app_project}/${google_artifact_registry_repository.my-repo.repository_id}/${var.image_name}"
}