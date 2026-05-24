# Cloud Router + NAT — will trigger cost alert (~$32/month)
resource "google_compute_router" "main" {
  name    = "main-router"
  network = google_compute_network.main.name
  region  = "us-central1"
}

resource "google_compute_router_nat" "main" {
  name                               = "main-nat"
  router                             = google_compute_router.main.name
  region                             = google_compute_router.main.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Cloud SQL — cost alert + security check (no backup label)
resource "google_sql_database_instance" "main" {
  name             = "main-postgres"
  database_version = "POSTGRES_15"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = false
}

# KMS key for encryption (good practice)
resource "google_kms_key_ring" "main" {
  name     = "main-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "main" {
  name     = "main-key"
  key_ring = google_kms_key_ring.main.id

  lifecycle {
    prevent_destroy = true
  }
}
