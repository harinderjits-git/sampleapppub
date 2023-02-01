
output "kms_sa" {
  value = google_project_service_identity.gcp_sa_cloud_sql.email
}