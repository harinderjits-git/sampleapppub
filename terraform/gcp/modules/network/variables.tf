

variable "project" {
  type = string
}

# naming
variable "department_code" {
  type        = string
  description = "Code for department, part of naming module"
}

variable "environment" {
  type        = string
  description = "S-Sandbox P-Production Q-Quality D-development"
}

variable "region" {
  type        = string
  description = "Location for naming and resource placement"
  default     = "northamerica-northeast1"
}

variable "owner" {
  type        = string
  description = "Division or group responsible for security and financial commitment."
}



variable "networks" {
  description = "list of netork maps. See examples directory"
  type = list(object({
    network_name                           = string
    routing_mode                           = string
    auto_create_subnetworks                = optional(string)
    description                            = optional(string)
    delete_default_internet_gateway_routes = optional(bool)
    subnet_flow_logs                       = optional(bool)
    mtu                                    = optional(string)
    private_service_address_prefix_length  = optional(string)
    private_service_address_range          = optional(string)
    network_peer_name                      = optional(string)
    subnets = list(object({
      subnet_name           = string
      subnet_ip             = string
      subnet_region         = string
      subnet_private_access = optional(bool)
      description           = optional(string)
      secondary_ip_ranges = optional(list(object({
        range_name    = string
        ip_cidr_range = string
      })))
    }))
    routes = optional(list(object({
      route_name             = string
      description            = optional(string)
      destination_range      = optional(string)
      tags                   = string
      next_hop_internet      = optional(bool)
      next_hop_ip            = optional(string)
      next_hop_instance      = optional(string)
      next_hop_instance_zone = optional(string)
      next_hop_vpn_tunnel    = optional(string)
      next_hop_ilb           = optional(string)
      priority               = optional(string)
    })))
    routers = optional(list(object({
      router_name = string
      description = string
      region      = string
      bgp = optional(object({
        asn              = string
        advertise_groups = optional(string)
      }))
    })))
    nat = optional(list(object({
      nat_name                           = string
      region                             = string
      nat_ips                            = optional(list(string))
      icmp_idle_timeout_sec              = optional(string)
      min_ports_per_vm                   = optional(string)
      nat_ip_allocate_option             = optional(string)
      router_asn                         = optional(string)
      source_subnetwork_ip_ranges_to_nat = optional(string)
      tcp_established_idle_timeout_sec   = optional(string)
      tcp_transitory_idle_timeout_sec    = optional(string)
      udp_idle_timeout_sec               = optional(string)
      nat_subnetworks = optional(list(object({
        name                     = string,
        source_ip_ranges_to_nat  = list(string)
        secondary_ip_range_names = list(string)
      })))
      log_config_enable                   = optional(string)
      log_config_filter                   = optional(string)
      enable_endpoint_independent_mapping = optional(string)
    })))
  }))
}
