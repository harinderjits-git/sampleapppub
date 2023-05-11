
data "google_project" "project" {
  project_id = var.project

}

data "external" "get_ip_addresses" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
}

data "google_sql_database_instance" "this" {
  project = var.project
  name    = var.master_instance_name
}
data "google_compute_network" "this" {
  name    = var.network_name
  project = var.project
}

data "google_dns_managed_zone" "private" {
  name    = var.dnsname
  project = var.project
}

resource "google_sql_database_instance" "this" {
  project          = var.project
  name             = "${var.name}-primary"
  database_version = var.database_version
  region           = var.region

 # deletion_protection = false
  encryption_key_name = google_kms_crypto_key.key.id
  # root_password = var.admin_password
  # labels = var.labels
   master_instance_name = data.google_sql_database_instance.this.name
    replica_configuration {
    failover_target = false
  }
  settings {
    tier                        = "db-custom-2-13312"
   # activation_policy           = "ALWAYS"
    availability_type           = "ZONAL"
    deletion_protection_enabled = false
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

      # authorized_networks {
      #   name  = "MYIP"
      #   value = "${data.external.get_ip_addresses.result.my_ip}/32"
      # }
    }
    # backup_configuration {
    #   enabled = true
    # }
    disk_autoresize = false
    disk_size       = "10"
    disk_type       = "PD_SSD"
    pricing_plan    = "PER_USE"

    location_preference {
      zone           = "${var.region}-a"
      secondary_zone = "${var.region}-b"
    }


  }

  # timeouts {
  #   create = "20m"
  #   update = "20m"
  #   delete = "10m"
  # }
  depends_on = [
    data.google_project.project,
    data.external.get_ip_addresses
  ]

    lifecycle {
      ignore_changes = [
        settings["ip_configuration"]
      ]
    }
}



# resource "google_sql_user" "users" {
#   for_each   = var.dblogins
#   project    = var.project
#   type       = "BUILT_IN"
#   name       = each.value.name
#   password   = each.value.password
#   depends_on = [google_sql_database_instance.this]
#   instance   = google_sql_database_instance.this.name

# }

# resource "google_sql_database" "this" {
#   for_each   = var.databases
#   name       = each.value.name
#   project    = var.project
#   instance   = google_sql_database_instance.this.name
#   depends_on = [google_sql_database_instance.this]

# }

resource "google_dns_record_set" "db" {
  name         = "databasefqdn.${data.google_dns_managed_zone.private.dns_name}"
  type         = "A"
  ttl          = 60
  project      = var.project
  managed_zone = data.google_dns_managed_zone.private.name
  #private IP
  rrdatas = [google_sql_database_instance.this.ip_address.1.ip_address]
  depends_on = [
    google_sql_database_instance.this,
    data.google_dns_managed_zone.private
  ]
}
