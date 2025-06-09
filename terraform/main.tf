terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Artifact Registry リポジトリ
resource "google_artifact_registry_repository" "microfrontend" {
  repository_id = "microfrontend"
  location      = var.region
  format        = "DOCKER"
  description   = "Microfrontend Docker images repository"
  
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }
}

# GKE クラスター
module "gke" {
  source = "./gke"
  
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  cluster_name = var.cluster_name
}

# Output values
output "cluster_name" {
  value = module.gke.cluster_name
}

output "cluster_endpoint" {
  value = module.gke.cluster_endpoint
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.microfrontend.name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.microfrontend.repository_id}"
}