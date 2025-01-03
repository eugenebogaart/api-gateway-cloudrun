
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.gcp_location
  repository_id = "cloud-run-source-deploy"
  description   = "Cloud Run Source Deployments"
  format        = "DOCKER"
}

# Step 1: Authenticating Docker with Google Cloud
resource "null_resource" "auth_docker" {
    provisioner "local-exec" {
        command = <<EOF
            gcloud auth configure-docker ${var.gcp_location}-docker.pkg.dev
        EOF
    }
}

# This resources is clearing timestamps for docker build and push 
resource "null_resource" "clean_up" {

  provisioner "local-exec" {
        command = <<EOF
            (cd .. ; make clean) 
        EOF
    }
}

# Step 2: Building the Docker Image
resource "null_resource" "build_image" {
    triggers = {
        always_run = "${timestamp()}"
    }
    provisioner "local-exec" {
        # With good old linux Makefile, image is only rebuild when one
        # the source files is changed.  
        command = <<EOF
            (cd .. ; make build -e image_name=${var.image_name} -e artifact_image_name=${local.artifact_image_name}) 
        EOF
    }

    depends_on = [ null_resource.clean_up ]
}

# Step 3: Pushing the Docker Image to Artifact Registry
resource "null_resource" "push_image" {
    triggers = {
        always_run = "${timestamp()}"
    }
    provisioner "local-exec" {
        # command = <<EOF
        #     docker push ${local.artifact_image_name} 
        # EOF
        command = <<EOF
            (cd .. ; make push -e image_name=${var.image_name} -e artifact_image_name=${local.artifact_image_name} )
          EOF
    }
    
     depends_on = [ 
      # Make sure "docker push" happens after "docker build"
      null_resource.build_image, 
      # and make "Clean Up" is executed before everything 
      null_resource.clean_up,
      # and we cannot push Artifact registry if it not created
      google_artifact_registry_repository.my-repo
     ]
}


resource "google_cloud_run_v2_service" "app" {
  depends_on = [
    google_project_service.run,
    null_resource.push_image,
  ]

  name     = "${var.image_name}-run"
  location = "${var.gcp_location}"
  deletion_protection = false
  # Service will has to be accessible publicly
  # API Gateway does not support internal network/vpc based services 
  # ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.gcp_location}-docker.pkg.dev/${var.app_project}/cloud-run-source-deploy/${var.image_name}:latest"
      env {
        name = "UPLOADER_PASSWD"
        value_source {
          secret_key_ref {
            secret = var.readwrite_all_secret
            version = "latest"
          }
        }
      }
      env {
        name = "QUERIER_PASSWD"
        value_source {
          secret_key_ref {
            secret = var.readonly_querier_secret
            version = "latest"
          }
        }
      }
      env {
        name = "HIGHSCORE_PASSWD"
        value_source {
          secret_key_ref {
            secret = var.insert_score_secret
            version = "latest"
          }
        }
      }
      env {
        name = "API_KEY"
        value_source {
          secret_key_ref {
            secret = var.api_key_secret
            version = "latest"
          }
        }
      }
    }
    #vpc access does not make much sense because
    # API Gateway is not able to connect to internal services
    # at the time of writing
    # vpc_access {
    #   network_interfaces {
    #     network    = "default"
    #     subnetwork = "default"
    #   }
    # }
  }
  # traffic {
  #   percent         = 100
  #   latest_revision = true
  # }

  lifecycle {
     replace_triggered_by = [
        null_resource.push_image.id
     ]
  } 
}

#  Below sample IAM Policy would make the app acccessible for everybody 
#  Option: Allow unauthenticated Invocations
data "google_iam_policy" "all_users_policy" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

#  Only allow service account to access the service
data "google_iam_policy" "service_account_only" {
  binding {
    role = "roles/run.invoker"
    members = [
     "serviceAccount:${var.service_account}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "all_users_iam_policy" {
  location    = google_cloud_run_v2_service.app.location
  service     = google_cloud_run_v2_service.app.name
  policy_data = data.google_iam_policy.all_users_policy.policy_data
}

data "google_cloud_run_v2_service_iam_policy" "policy" {
  project = "${var.app_project}"
  location = google_cloud_run_v2_service.app.location
  name = google_cloud_run_v2_service.app.name
}
