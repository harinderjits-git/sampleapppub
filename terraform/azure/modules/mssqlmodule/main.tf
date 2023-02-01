resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}

# An Azure SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                = var.database_server_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  minimum_tls_version = "1.2"
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }
}

data "external" "get_ip_addresses" {
  program = ["bash", "${path.module}/scripts/get_ip_addresses.sh"]
}


resource "azurerm_mssql_firewall_rule" "sql_server_fw_rule1" {
  #  for_each = data.external.get_ip_addresses.result
  for_each = {
    for key, value in data.external.get_ip_addresses.result :
    key => value
    if value != ""
  }
  name             = "AllowIP ${each.value}"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

data "azurerm_logic_app_workflow" "wf1" {
  name = var.logicapp_name
  resource_group_name = "${var.logicapp_name}-rg"
}
resource "azurerm_mssql_firewall_rule" "sql_server_fw_rule2" {
    for_each = {
    for  key, value in toset(data.azurerm_logic_app_workflow.wf1.connector_outbound_ip_addresses) :
    key => value
    if length(regexall("/", value)) > 0 
  }

  name             = "AllowIP logic app IP  ${cidrhost("${each.value}",0)}"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = cidrhost("${each.value}",0)
  end_ip_address   = cidrhost("${each.value}",-1)
}

resource "azurerm_mssql_firewall_rule" "sql_server_fw_rule3" {
    for_each = {
    for  key, value in toset(data.azurerm_logic_app_workflow.wf1.connector_outbound_ip_addresses) :
    key => value
    if length(regexall("/", value)) == 0 
  }

  name             = "AllowIP logic app IP ${each.key}"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value
  end_ip_address   = each.value
}
# resource "azurerm_mssql_firewall_rule" "sql_server_fw_rule2" {
#   count            = length(jsonencode(data.external.get_ip_addresses.result.ip_address_aks))
#   name             = "AllowIPAKS${count.index}"
#   server_id        = azurerm_mssql_server.sql_server.id
#   start_ip_address = jsonencode(data.external.get_ip_addresses.result.ip_address_aks)[count.index]
#   end_ip_address   = jsonencode(data.external.get_ip_addresses.result.ip_address_aks)[count.index]
# }


# The Azure SQL Database used in tests
resource "azurerm_mssql_database" "db" {
  for_each                    = var.databases
  name                        = each.value.name
  server_id                   = azurerm_mssql_server.sql_server.id
  sku_name                    = each.value.sku
  sample_name                 = try(each.value.sample_name, null)
  auto_pause_delay_in_minutes = each.value.sku == "GP_S_Gen5_2" ? 60 : null
  #license_type   = "LicenseIncluded"
  max_size_gb    = 4
  min_capacity   = 1
  zone_redundant = true
  tags           = var.tags
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_mssql_database.db]

  create_duration = "60s"
}


resource "mssql_login" "server" {
  for_each = var.dblogins
  server {
    host = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    login {
      username = azurerm_mssql_server.sql_server.administrator_login
      password = azurerm_mssql_server.sql_server.administrator_login_password
    }
  }
  login_name = each.value.name
  password   = each.value.password

  depends_on = [time_sleep.wait_60_seconds]
}

resource "mssql_user" "server" {
  # for_each                    = var.databases
  for_each = { for key, value in var.databases :
    key => value
    if value != null
  }
  server {
    host = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    login {
      username = azurerm_mssql_server.sql_server.administrator_login
      password = azurerm_mssql_server.sql_server.administrator_login_password
    }
  }
  database   = each.value.name
  username   = each.value.user
  login_name = each.value.login
  roles      = ["db_owner"]

  depends_on = [time_sleep.wait_60_seconds]
}
