locals {
  rg_name = "${var.database_server_name}-rg"
}

locals {
  consumable = azurerm_mssql_server.sql_server
}
