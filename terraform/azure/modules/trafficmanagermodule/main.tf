data "external" "get_ip_addresses_pr" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
  query = {
    "aks" = var.primary_aksname
  }
}

data "external" "get_ip_addresses_dr" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
  query = {
    "aks" = var.dr_aksname
  }
  depends_on = [
    data.external.get_ip_addresses_pr
  ]
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}


resource "azurerm_traffic_manager_profile" "this" {
  name                   = var.name
  resource_group_name    = azurerm_resource_group.rg.name
  traffic_routing_method = var.routing_method

  dns_config {
    relative_name = var.name
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = var.tags
}

# resource "azurerm_traffic_manager_endpoint" "ep1" {
#   for_each = var.endpoints
#   name                = each.value.name
#   resource_group_name = azurerm_resource_group.rg.name
#   profile_name        = var.name
#   target              = each.value.Public_IP
#   type                = "externalEndpoints"
#   weight              = each.value.priority
# }

resource "azurerm_traffic_manager_external_endpoint" "ep_pr" {
  count = data.external.get_ip_addresses_pr.result.ip_address_aks == ""? 0:1
  name       = var.ep_pr.name
  profile_id = azurerm_traffic_manager_profile.this.id
  priority   = var.ep_pr.priority
  target     = data.external.get_ip_addresses_pr.result.ip_address_aks
}

resource "azurerm_traffic_manager_external_endpoint" "ep_dr" {
  count = data.external.get_ip_addresses_dr.result.ip_address_aks == ""? 0:1
  name       = var.ep_dr.name
  profile_id = azurerm_traffic_manager_profile.this.id
  priority   = var.ep_dr.priority
  target     = data.external.get_ip_addresses_dr.result.ip_address_aks
}
