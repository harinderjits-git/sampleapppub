locals {
  rg_name = "${var.name}-rg"
}

locals {
  consumable = azurerm_container_registry.this
}
