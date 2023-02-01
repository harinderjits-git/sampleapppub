locals {
  rg_name = "${var.name}-rg"
}

locals {
  consumable = azurerm_traffic_manager_profile.this
}
