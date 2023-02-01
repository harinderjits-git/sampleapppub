resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}



data "azurerm_managed_api" "this" {
  name     = "sql"
  location = azurerm_resource_group.this.location
}


resource "azurerm_api_connection" "this" {
  name                = local.api_connection_name
  resource_group_name = azurerm_resource_group.this.name
  managed_api_id      = data.azurerm_managed_api.this.id
  display_name        = local.api_connection_name

  parameter_values = {
    #connectionString = local.connection_string
    server   = "${var.database_server_name}.database.windows.net"
    database = var.database_name
    username = var.administrator_login
    password = var.administrator_login_password
  }

  tags = var.tags
lifecycle {
    ignore_changes = all
  }
}


resource "azurerm_logic_app_workflow" "this" {
  name                = var.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
  lifecycle {
    ignore_changes = all
  }
  }

# resource "azurerm_logic_app_connection_custom" "conn" {
#   name         = "conn"
#   logic_app_id = azurerm_logic_app_workflow.this.id
#   schema = <<SCHEMA
# {
# "connectionId": "${azurerm_api_connection.this.id}",
# "connectionName": "${azurerm_api_connection.this.name}",
# "id": "${data.azurerm_managed_api.this.id}"
# }
# SCHEMA
# }


resource "azurerm_logic_app_trigger_recurrence" "trigger" {
  name         = "Recurrence"
  logic_app_id = azurerm_logic_app_workflow.this.id
  frequency    = "Minute"
  interval     = 2
  depends_on = [
    azurerm_api_connection.this
  ]
  lifecycle {
    ignore_changes = all
  }
}


resource "azurerm_logic_app_action_custom" "action1" {
  name         = "connectloginusername"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = <<BODY
{
    "inputs": {
        "body": {
            "query": "${local.query}"
                },
        "host": {
            "connection": {
                "name": "${azurerm_api_connection.this.id}"
            }
        },
        "method": "post",
        "path": "/v2/datasets/default,default/query/sql"
    },
    "runAfter": {},
    "type": "ApiConnection"

}
BODY
  depends_on = [
    azurerm_logic_app_trigger_recurrence.trigger
  ]
  lifecycle {
    ignore_changes = all
  }
}


data "template_file" "workflow" {
  template = file(local.arm_file_path)
}

resource "azurerm_template_deployment" "workflow" {
  depends_on = [azurerm_logic_app_workflow.this]

  resource_group_name = azurerm_resource_group.this.name
  parameters = merge({
    "workflows_sqlloginuserconnectorue_name" = var.name,
    "connections_sqlloginuserconnectorue_acn_externalid" = "${azurerm_api_connection.this.id}",
    "managedapi_id" = data.azurerm_managed_api.this.id,
    "location"     = var.resource_group_location
  }, var.parameters)

  template_body = data.template_file.workflow.template

  # The filemd5 forces this to run when the file is changed
  # this ensures the keys are up-to-date
  name            = "workflow-${filemd5(local.arm_file_path)}"
  deployment_mode = "Incremental"
  lifecycle {
    ignore_changes = all
  }
}