
output "kms_sa" {
  value = google_project_service_identity.gcp_sa_cloud_sql.email
}

output "sql_instance" {
  description = "The generated name of the Cloud SQL instance"
  value       = google_sql_database_instance.readreplica["replica1"].name
}
