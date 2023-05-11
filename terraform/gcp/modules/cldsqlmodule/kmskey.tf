

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project  = var.project
}

resource "google_kms_key_ring" "keyring" {
  provider = google-beta
  name     = "${var.name}-keyring4"
  location = var.region
  project  = var.project
}

resource "google_kms_crypto_key" "key" {
  provider = google-beta
  name     = "${var.name}-key"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ENCRYPT_DECRYPT"
#  project  = var.project
}



resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
 # project       = var.project
  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}
