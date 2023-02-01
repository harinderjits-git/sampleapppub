data "external" "get_ip_addresses_pr" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
  query = {
    "gke"     = var.primary_gkename
    "region"  = var.primary_region
    "project" = var.project
  }
}


data "external" "get_ip_addresses_dr" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
  query = {
    "gke"     = var.dr_gkename
    "region"  = var.dr_region
    "project" = var.project
  }
  depends_on = [
    data.external.get_ip_addresses_pr
  ]
}

# resource "local_file" "get_ip_addresses_pr" {
#   content = data.external.get_ip_addresses_pr.result.ip_address_gke
#   #content  = google_service_account_key.this.private_key
#   filename = "/tmp/get_ip_addresses_pr"
# }



# resource "local_file" "get_ip_addresses_dr" {
#   content = data.external.get_ip_addresses_dr.result.ip_address_gke
#   #content  = google_service_account_key.this.private_key
#   filename = "/tmp/get_ip_addresses_dr"
# }

# locals {
#   instances = concat(tolist(data.external.get_ip_addresses_pr.result.ip_address_gke), tolist(data.external.get_ip_addresses_dr.result.ip_address_gke))
# }


# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name}-lb"
  provider              = google-beta
  project               = var.project
  #network               = var.network
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_tcp_proxy.default.id
  # ip_address            = google_compute_global_address.default.id
}

resource "google_compute_target_tcp_proxy" "default" {
  provider        = google-beta
  name            = "test-proxy-health-check"
  project         = var.project
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-bs-prip"
 #load_balancing_scheme = "INTERNAL_SELF_MANAGED"
  project               = var.project
  #locality_lb_policy    = "ROUND_ROBIN"
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group                        = google_compute_network_endpoint_group.prnep.self_link
    balancing_mode               = "CONNECTION"
    max_connections_per_endpoint = 3000
    #  max_connections = "3000"
  }

  backend {
    group                        = google_compute_network_endpoint_group.drnep.self_link
    balancing_mode               = "CONNECTION"
    max_connections_per_endpoint = 3000
    # max_connections = "3000"
  }
  enable_cdn = false
  # log_config {
  #   enable      = true
  #   sample_rate = 1.0
  # }

  port_name   = "http"
  protocol    = "TCP"
  timeout_sec = 60
}


# resource "google_compute_backend_service" "drip" {
#   name                  = "${var.name}-bs-drip"
#   load_balancing_scheme = "INTERNAL_SELF_MANAGED"
#   locality_lb_policy    = "ROUND_ROBIN"
#   backend {
#     group = google_compute_network_endpoint_group.drip.self_link
#   }
#   enable_cdn = false
#   log_config {
#     enable      = true
#     sample_rate = 1.0
#   }

#   port_name   = "http"
#   protocol    = "HTTP"
#   timeout_sec = 60
# }



resource "google_compute_network_endpoint_group" "prnep" {
  name                  = "ineg-${var.name}-pr"
  network               = var.network
  zone                  = "${var.primary_region}-a"
  network_endpoint_type = "NON_GCP_PRIVATE_IP_PORT"
  project               = var.project
  default_port          = "80"

}

resource "google_compute_network_endpoint_group" "drnep" {
  name                  = "ineg-${var.name}-dr"
  network               = var.network
  project               = var.project
  zone                  = "${var.dr_region}-a"
  network_endpoint_type = "NON_GCP_PRIVATE_IP_PORT"
  default_port          = "80"

}

resource "google_compute_network_endpoint" "pripne" {
  network_endpoint_group = google_compute_network_endpoint_group.prnep.name
  port                   = 80
  project                = var.project
  zone                   = "${var.primary_region}-a"
  ip_address             = data.external.get_ip_addresses_pr.result.ip_address_gke
  depends_on = [
    data.external.get_ip_addresses_pr
  ]
}


resource "google_compute_network_endpoint" "dripne" {
  network_endpoint_group = google_compute_network_endpoint_group.drnep.name
  port                   = 80
  zone                   = "${var.dr_region}-a"
  project                = var.project
  ip_address             = data.external.get_ip_addresses_dr.result.ip_address_gke
  depends_on = [
    data.external.get_ip_addresses_dr,
    data.external.get_ip_addresses_pr
  ]
}




resource "google_compute_health_check" "default" {
  provider           = google-beta
  name               = "tcp-proxy-health-check"
  timeout_sec        = 1
  check_interval_sec = 1
  project            = var.project
  tcp_health_check {
    port = "80"
  }
}
