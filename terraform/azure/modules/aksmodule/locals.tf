locals {
  rg_name = "${var.name}-rg"
}

locals {
  consumable = azurerm_kubernetes_cluster.this
}
