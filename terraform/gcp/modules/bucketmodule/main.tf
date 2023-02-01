
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_storage_bucket" "tfstate_bucket" {
  project       = data.google_project.project.project_id
  location      = var.location
  name          = var.bucketname
  storage_class = "STANDARD"
  force_destroy = true
  labels = var.labels
  
}
