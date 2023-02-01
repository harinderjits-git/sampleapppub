

resource "google_project" "project" {
  org_id              = local.parent_type == "organizations" ? local.parent_id : null
  folder_id           = local.parent_type == "folders" ? local.parent_id : null
  project_id          = var.project_id
  name                = var.project_name
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  labels              = var.labels
}

resource "google_compute_project_metadata_item" "oslogin_meta" {
  count   = var.oslogin ? 1 : 0
  project = google_project.project.project_id
  key     = "enable-oslogin"
  value   = "TRUE"
  # depend on services or it will fail on destroy
  depends_on = [google_project_service.project_services]
}

resource "google_project_service" "project_services" {
  for_each                   = toset(var.services)
  project                    = google_project.project.project_id
  service                    = each.value
  disable_on_destroy         = var.service_config.disable_on_destroy
  disable_dependent_services = var.service_config.disable_dependent_services

}


resource "google_service_account" "default" {
  account_id   = "gkek8ssa"
  display_name = "k8s Service Account"
  project      = google_project.project.project_id
}


resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project  = google_project.project.project_id
}
