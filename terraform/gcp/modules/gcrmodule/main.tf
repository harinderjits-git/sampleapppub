
resource "google_container_registry" "registry" {
  project  = var.project
  location = var.location
 # name =var.name
}



resource "google_service_account" "gcr_login" {
  project      = var.project
  account_id   = "${var.name}-accesssa"
  
  display_name = "Service Account to pull push to GCR"
    depends_on = [
    google_container_registry.registry
  ]
}

resource "google_service_account_key" "this" {
  service_account_id = google_service_account.gcr_login.name
  public_key_type    = "TYPE_X509_PEM_FILE"
   depends_on = [
    google_service_account.gcr_login
  ]
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.registry.id
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gcr_login.email}"
  depends_on = [
    google_container_registry.registry,
    google_service_account.gcr_login
  ]
}

resource "local_file" "private_key" {
    content  = base64decode(google_service_account_key.this.private_key)
    #content  = google_service_account_key.this.private_key
    filename = "/tmp/private_key.pem"
}