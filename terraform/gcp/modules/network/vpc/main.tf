# VPC
resource "google_compute_network" "vpc" {
  name                            = var.network.network_name
  auto_create_subnetworks         = lookup(var.network, "auto_create_subnetworks", false) == null ? false : var.network.auto_create_subnetworks
  routing_mode                    = var.network.routing_mode
  project                         = var.project
  description                     = lookup(var.network, "description", null)
  delete_default_routes_on_create = lookup(var.network, "delete_default_internet_gateway_routes", true)
  mtu                             = lookup(var.network, "mtu", 0)
}

# Subnets
locals {
  subnets = {
    for x in var.network.subnets :
    "${x.subnet_region}/${x.subnet_name}" => x # "
  }
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each                 = local.subnets
  name                     = each.value.subnet_name
  ip_cidr_range            = each.value.subnet_ip
  region                   = each.value.subnet_region
  private_ip_google_access = lookup(each.value, "subnet_private_access", "false")
  dynamic "log_config" {
    for_each = lookup(each.value, "subnet_flow_logs", false) ? [{
      aggregation_interval = lookup(each.value, "subnet_flow_logs_interval", "INTERVAL_5_SEC")
      flow_sampling        = lookup(each.value, "subnet_flow_logs_sampling", "0.5")
      metadata             = lookup(each.value, "subnet_flow_logs_metadata", "INCLUDE_ALL_METADATA")
    }] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
    }
  }
  network     = google_compute_network.vpc.name
  project     = var.project
  description = lookup(each.value, "description", null)
  dynamic "secondary_ip_range" {
    for_each = toset(lookup(each.value, "secondary_ip_ranges", []))
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  depends_on = [
    google_compute_network.vpc,
  ]
}

# Routes 
locals {
  routes_list = lookup(var.network, "routes", []) == null ? [] : var.network.routes
  routes = {
    for i, route in local.routes_list :
    lookup(route, "route_name", format("%s-%s-%d", lower(var.network.network_name), "route_name", i)) => route
  }
}

resource "google_compute_route" "route" {
  for_each = local.routes

  project = var.project
  network = google_compute_network.vpc.name

  name                   = each.key
  description            = lookup(each.value, "description", null)
  tags                   = compact(split(",", lookup(each.value, "tags", "")))
  dest_range             = lookup(each.value, "destination_range", null)
  next_hop_gateway       = lookup(each.value, "next_hop_internet", false) == true ? "default-internet-gateway" : null
  next_hop_ip            = lookup(each.value, "next_hop_ip", null) == "" ? null : each.value.next_hop_ip
  next_hop_instance      = lookup(each.value, "next_hop_instance", null) == "" ? null : each.value.next_hop_instance
  next_hop_instance_zone = lookup(each.value, "next_hop_instance_zone", null) == "" ? null : each.value.next_hop_instance_zone
  next_hop_vpn_tunnel    = lookup(each.value, "next_hop_vpn_tunnel", null) == "" ? null : each.value.next_hop_vpn_tunnel
  next_hop_ilb           = lookup(each.value, "next_hop_ilb", null) == "" ? null : each.value.next_hop_ilb
  priority               = lookup(each.value, "priority", null)

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnetwork,
  ]
}

# routers
locals {
  routers_list = lookup(var.network, "routers", []) == null ? [] : var.network.routers
  routers = {
    for i, router in local.routers_list :
    lookup(router, "router_name", format("%s-%s-%d", lower(var.network.network_name), "router_name", i)) => router
  }
}

resource "google_compute_router" "router" {
  for_each    = local.routers
  name        = each.value.router_name
  network     = google_compute_network.vpc.name
  region      = each.value.region
  project     = var.project
  description = each.value.description
  dynamic "bgp" {
    for_each = each.value.bgp != null ? [each.value.bgp] : []
    content {
      asn = each.value.bgp.asn

      # advertise_mode is intentionally set to CUSTOM to not allow "DEFAULT".
      # This forces the config to explicitly state what subnets and ip ranges
      # to advertise. To advertise the same range as DEFAULT, set
      # `advertise_groups = ["ALL_SUBNETS"]`.
      advertise_mode    = "CUSTOM"
      advertised_groups = lookup(each.value.bgp, "advertised_groups", null) # == null ? null : each.value.bgp.advertised_groups

      dynamic "advertised_ip_ranges" {
        for_each = lookup(each.value.bgp, "advertised_ip_ranges", [])
        content {
          range       = advertised_ip_ranges.value.range
          description = lookup(advertised_ip_ranges.value, "description", null)
        }
      }
    }
  }
  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnetwork,
  ]
}

# Nat
locals {
  nat = lookup(var.network, "nat", []) == null ? [] : var.network.nat
}


# module "cloud_nat" {
#   for_each                            = { for nat in local.nat : nat.nat_name => nat }
#   source                              = "../nat"
#   project                             = var.project
#   department_code                     = var.department_code
#   environment                         = var.environment
#   network                             = google_compute_network.vpc.name
#   network_short_name                  = var.network.network_name
#   name                                = each.value.nat_name
#   region                              = lookup(each.value, "region", null) == null ? null : each.value.region
#   nat_ips                             = lookup(each.value, "nat_ips", null) == null ? [] : each.value.nat_ips
#   icmp_idle_timeout_sec               = lookup(each.value, "icmp_idle_timeout_sec", null) == null ? null : each.value.icmp_idle_timeout_sec
#   min_ports_per_vm                    = lookup(each.value, "min_ports_per_vm", null) == null ? null : each.value.min_ports_per_vm
#   nat_ip_allocate_option              = lookup(each.value, "nat_ip_allocate_option", null) == null ? false : each.value.nat_ip_allocate_option
#   router_asn                          = lookup(each.value, "router_asn", null) == null ? 64514 : each.value.router_asn
#   source_subnetwork_ip_ranges_to_nat  = lookup(each.value, "source_subnetwork_ip_ranges_to_nat", null) == null ? "ALL_SUBNETWORKS_ALL_IP_RANGES" : each.value.source_subnetwork_ip_ranges_to_nat
#   tcp_established_idle_timeout_sec    = lookup(each.value, "tcp_established_idle_timeout_sec", null) == null ? null : each.value.tcp_established_idle_timeout_sec
#   tcp_transitory_idle_timeout_sec     = lookup(each.value, "tcp_transitory_idle_timeout_sec", null) == null ? null : each.value.tcp_transitory_idle_timeout_sec
#   udp_idle_timeout_sec                = lookup(each.value, "udp_idle_timeout_sec", null) == null ? null : each.value.udp_idle_timeout_sec
#   nat_subnetworks                     = lookup(each.value, "nat_subnetworks", null) == null ? [] : each.value.nat_subnetworks
#   log_config_enable                   = lookup(each.value, "log_config_enable", null) == null ? false : each.value.log_config_enable
#   log_config_filter                   = lookup(each.value, "log_config_filter", null) == null ? null : each.value.log_config_filter
#   enable_endpoint_independent_mapping = lookup(each.value, "enable_endpoint_independent_mapping", null) == null ? false : each.value.enable_endpoint_independent_mapping
#   depends_on = [
#     google_compute_network.vpc,
#     google_compute_subnetwork.subnetwork,
#   ]
# }

# Service Connections
locals {
  private_service_address_range = lookup(var.network, "private_service_address_range", null) == null ? [] : [var.network.private_service_address_range]
}

resource "google_compute_global_address" "private_ip_alloc" {
  for_each      = toset(local.private_service_address_range)
  project       = var.project
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.network.private_service_address_prefix_length
  address       = var.network.private_service_address_range
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private-services" {
  for_each                = toset(local.private_service_address_range)
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc["${var.network.private_service_address_range}"].name]
}


# resource "google_compute_network_peering_routes_config" "peering_routes" {
#   for_each                = toset(local.private_service_address_range)
#   peering = google_service_networking_connection.private-services[each.value].peering
#   network = google_compute_network.vpc.id
#   project = var.project
#   import_custom_routes = true
#   export_custom_routes = true
#   depends_on = [
#     google_service_networking_connection.private-services
#   ]
# }