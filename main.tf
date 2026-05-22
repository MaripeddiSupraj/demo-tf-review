provider "google" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

# Secure bucket with public access prevention
resource "google_storage_bucket" "public_data" {
  name                        = "${var.project_id}-public-data"
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  labels = {
    environment = "production"
    owner       = "platform-team"
    name        = "Public data bucket"
  }
}

# Bucket with proper labels and versioning
resource "google_storage_bucket" "app_logs" {
  name     = "${var.project_id}-app-logs"
  location = "US"
  labels = {
    environment = "production"
    owner       = "platform-team"
    name        = "App logs"
  }
  versioning {
    enabled = true
  }
}

# VM with proper labels
resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  labels = {
    environment = "production"
    owner       = "platform-team"
    name        = "Bastion host"
  }
  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }
  network_interface { network = "default" }
}

# Network with labels
resource "google_compute_network" "main" {
  name                    = "main-network"
  auto_create_subnetworks = true
  labels = {
    environment = "production"
    owner       = "platform-team"
    name        = "Main network"
  }
}

# Least-privilege IAM (no more owner role)
resource "google_project_iam_member" "admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:tf-sa@${var.project_id}.iam.gserviceaccount.com"
}
