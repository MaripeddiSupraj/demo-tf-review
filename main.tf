provider "google" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

# Bucket with public access (security issue)
resource "google_storage_bucket" "public_data" {
  name     = "${var.project_id}-public-data"
  location = "US"
}
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.public_data.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Bucket with proper labels
resource "google_storage_bucket" "app_logs" {
  name     = "${var.project_id}-app-logs"
  location = "US"
  labels = {
    environment = "production"
    owner       = "platform-team"
    name        = "App logs"
  }
}

# VM missing labels (policy violation)
resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }
  network_interface { network = "default" }
}

# Network
resource "google_compute_network" "main" {
  name = "main-network"
}

# Overly permissive IAM (security issue)
resource "google_project_iam_member" "admin" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:tf-sa@${var.project_id}.iam.gserviceaccount.com"
}
