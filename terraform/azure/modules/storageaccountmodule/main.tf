
resource "azurerm_resource_group" "this" {
  name     = "${var.name}-rg"
  location = var.resource_group_location
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "container"

}