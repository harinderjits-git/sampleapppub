
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}


resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = var.tags

}
