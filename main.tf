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

# Firestore database (no PITR — policy violation)
resource "google_firestore_database" "users_db" {
  name        = "users-database"
  location_id = "nam5"
  type        = "FIRESTORE_NATIVE"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_DISABLED"
}

# Cloud NAT (cost concern)
resource "google_compute_router" "main" {
  name    = "main-router"
  network = google_compute_network.main.id
  region  = "us-central1"
}
resource "google_compute_router_nat" "main" {
  name                               = "main-nat"
  router                             = google_compute_router.main.name
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
