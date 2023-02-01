
// Used when setting up the GKE cluster to talk to sql.
output "sql_instance" {
  description = "The generated name of the Cloud SQL instance"
  value       = google_sql_database_instance.this.name
}

// Full connection string for the sql DB>
output "sql_connection" {
  description = "The connection string dynamically generated for storage inside the Kubernetes configmap"
  value       = format("%s:%s:%s", var.project, var.region, google_sql_database_instance.this.name)
}


output "kms_sa" {
  value = google_project_service_identity.gcp_sa_cloud_sql.email
}