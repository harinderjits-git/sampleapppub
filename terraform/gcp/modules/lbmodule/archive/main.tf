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
  name     = "${var.name}-gfr"
  provider = google-beta
  project  = var.project
  #network               = var.network
  ip_protocol           = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  # ip_address            = google_compute_global_address.default.id
}

resource "google_compute_target_http_proxy" "default" {
  provider = google-beta
  name     = "http-proxy"
  project  = var.project
  url_map  = google_compute_url_map.routerule.self_link
}

resource "google_compute_backend_service" "pr" {
  name          = "${var.name}-bs-pr-lb"
  project       = var.project
  health_checks = [google_compute_health_check.default.id]
  backend {
    group                 = google_compute_network_endpoint_group.prnep.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 1
  }

  # backend {
  #   group                 = google_compute_network_endpoint_group.drnep.self_link
  #   balancing_mode        = "RATE"
  #   max_rate_per_endpoint = 1
  # }
  enable_cdn = false

  port_name                       = "http"
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 30
}


resource "google_compute_backend_service" "dr" {
  name          = "${var.name}-bs-dr-lb"
  project       = var.project
  health_checks = [google_compute_health_check.default.id]
  # backend {
  #   group                 = google_compute_network_endpoint_group.prnep.self_link
  #   balancing_mode        = "RATE"
  #   max_rate_per_endpoint = 1
  # }

  backend {
    group                 = google_compute_network_endpoint_group.drnep.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 1
  }
  enable_cdn = false

  port_name                       = "http"
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 30
}


resource "google_compute_backend_service" "common" {
  name          = "${var.name}-bs-common-lb"
  project       = var.project
  health_checks = [google_compute_health_check.default.id]
  backend {
    group                 = google_compute_network_endpoint_group.prnep.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 1
  }

  backend {
    group                 = google_compute_network_endpoint_group.drnep.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 1
  }
  enable_cdn = false

  port_name                       = "http"
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 30
}

resource "google_compute_health_check" "default" {
  provider           = google-beta
  name               = "lb-1-health-check"
  timeout_sec        = 1
  check_interval_sec = 5
  project            = var.project
  http_health_check {
    port = "80"
  }
}

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
  count                  = data.external.get_ip_addresses_pr.result.ip_address_gke == "" ? 0 : 1
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
  count                  = data.external.get_ip_addresses_dr.result.ip_address_gke == "" ? 0 : 1
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





resource "google_compute_url_map" "routerule" {
  // note that this is the name of the load balancer
  name            = "${var.name}-rr-lb"
  default_service = google_compute_backend_service.common.self_link
  project         = var.project
  host_rule {
    hosts        = [var.appurl]
    path_matcher = "commonpaths"
  }
  host_rule {
    hosts        = [var.primary_url]
    path_matcher = "prpaths"
  }
  host_rule {
    hosts        = [var.dr_url]
    path_matcher = "drpaths"
  }
    path_matcher {
    name            = "commonpaths"
    default_service = google_compute_backend_service.common.self_link
    path_rule {
      paths = ["/*"]
      service = google_compute_backend_service.common.self_link
    }

  }
  path_matcher {
    name            = "prpaths"
    default_service = google_compute_backend_service.pr.self_link
    path_rule {
      paths = ["/*"]
      service = google_compute_backend_service.pr.self_link
    }
  }

    path_matcher {
    name            = "drpaths"
    default_service = google_compute_backend_service.dr.self_link
    path_rule {
      paths = ["/*"]
      service = google_compute_backend_service.dr.self_link
    }

  }
}
