
data "google_project" "project" {
  project_id = var.project

}

data "external" "get_ip_addresses" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
}

data "google_compute_network" "this" {
  name    = var.network_name
  project = var.project
}

data "google_sql_database_instance" "this" {
  project = var.project
  name    = var.master_instance_name
}

resource "google_sql_database_instance" "readreplica" {
  for_each = { for key, value in var.readreplica :
    key => value
    if value != null
  }
  project              = var.project
  name                 = "${data.google_sql_database_instance.this.name}-${each.value.name}"
 # master_instance_name = data.google_sql_database_instance.this.name
  region               = each.value.region
  database_version     = var.database_version
  encryption_key_name = google_kms_crypto_key.key.id
  # replica_configuration {
  #   failover_target = false
  # }

  settings {
    tier              = "db-custom-2-13312"
    availability_type = "ZONAL"
    disk_size         = "10"
    disk_autoresize   = false
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = data.google_compute_network.this.id
      dynamic "authorized_networks" {
        #  for_each = data.external.get_ip_addresses.result
        for_each = {
          for key, value in data.external.get_ip_addresses.result :
          key => value
          if value != ""
        }
        content {
          name  = "${authorized_networks.value}-rule"
          value = "${authorized_networks.value}/32"
        }
      }
    }
    location_preference {
      zone = "${each.value.region}-b"
    }
    deletion_protection_enabled = false
  }
    lifecycle {
      ignore_changes = [
        settings["ip_configuration"]
      ]
    }
}
