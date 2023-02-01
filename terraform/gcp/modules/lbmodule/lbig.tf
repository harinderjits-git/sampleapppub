# locals {
#   all_igs = concat(var.primary_igs, var.dr_igs)
# }



data "external" "faigs" {
  program = ["bash", "${path.module}/scripts/get_igs.sh"]
}
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

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/set-portname.sh"
  }
  lifecycle {
    ignore_changes = all

  }
  # ip_address            = google_compute_global_address.default.id
}

resource "google_compute_target_http_proxy" "default" {
  provider = google-beta
  name     = "http-proxy"
  project  = var.project
  url_map  = google_compute_url_map.routerule.self_link
}

resource "google_compute_backend_service" "common" {
  name          = "${var.name}-bs-common-lb"
  project       = var.project
  health_checks = [google_compute_health_check.default.id]
  dynamic "backend" {
    for_each = {
      for key, value in data.external.faigs.result :
      key => value
      if value != ""
    }
    content {
      balancing_mode        = "UTILIZATION"
      capacity_scaler       = 1
      group                 = backend.value
      max_rate_per_instance = 800
      max_utilization       = 0.8
    }
  }
  enable_cdn                      = false
  port_name                       = "http"
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 30

  log_config  {
    enable      = true
    sample_rate = 1.0
  }

  lifecycle {
    ignore_changes = [
      backend
    ]
  }
}

resource "google_compute_health_check" "default" {
  provider           = google-beta
  name               = "lb-1-health-check"
  timeout_sec        = 3
  check_interval_sec = 10
  project            = var.project
  tcp_health_check {
    port = 31025
  }


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

  path_matcher {
    name            = "commonpaths"
    default_service = google_compute_backend_service.common.self_link
    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.common.self_link
    }

  }

}
