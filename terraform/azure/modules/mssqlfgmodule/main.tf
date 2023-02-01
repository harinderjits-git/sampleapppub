resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}

data "azurerm_mssql_server" "primary" {
  name                = var.primary_instance_name
  resource_group_name = "${var.primary_instance_name}-rg"

}

data "azurerm_mssql_server" "secondary" {
  name                = var.secondary_instance_name
  resource_group_name = "${var.secondary_instance_name}-rg"

}

data "azurerm_mssql_database" "db1" {
  name = var.database_db1_name
  server_id = data.azurerm_mssql_server.primary.id
}

data "azurerm_mssql_database" "db2" {
  name = var.database_db2_name
  server_id = data.azurerm_mssql_server.primary.id
}


resource "azurerm_mssql_failover_group" "mssqlfg" {
  name      = var.fg_name
  server_id = data.azurerm_mssql_server.primary.id
  databases = [
    data.azurerm_mssql_database.db1.id,
    data.azurerm_mssql_database.db2.id
  ]

  partner_server {
    id = data.azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = var.tags
}
