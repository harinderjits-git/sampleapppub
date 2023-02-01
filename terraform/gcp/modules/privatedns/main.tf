
data "google_compute_network" "this" {
  name    = var.target_network
  project = var.project
}



resource "google_dns_managed_zone" "private" {
  count         = var.dns.type == "private" ? 1 : 0
  project       = var.project
  name          = var.dns.name
  dns_name      = var.dns.domain
  description   = var.dns.description
  labels        = var.labels
  visibility    = "private"
  force_destroy = var.force_destroy

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.this.id

    }
  }
  # dynamic "networks" {
  #   for_each = var.private_visibility_config_networks
  #   content {
  #     network_url = networks.value
  #   }
  # }

}

# resource "google_dns_record_set" "db" {
#   name = "databasefqdn.${google_dns_managed_zone.private.dns_name}"
#   type = "A"
#   ttl  = 60

#   managed_zone = google_dns_managed_zone.private.name

#   rrdatas = [data.google_sql_database_instance.this.ip_address.0.ip_address]
# }

# resource "google_dns_record_set" "cloud-static-records" {
#   project      = var.project_id
#   managed_zone = var.name

#   for_each = { for record in var.recordsets : join("/", [record.name, record.type]) => record }
#   name = (
#     each.value.name != "" ?
#     "${each.value.name}.${var.domain}" :
#     var.domain
#   )
#   type = each.value.type
#   ttl  = each.value.ttl

#   rrdatas = each.value.records

#   depends_on = [
#     google_dns_managed_zone.private
#   ]
# }
