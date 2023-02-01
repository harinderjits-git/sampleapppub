locals {
  rg_name = "${var.name}-rg"
}

locals {
  consumable = azurerm_logic_app_workflow.this
}
# locals {
#   connection_string=format("Server=tcp:%s.database.windows.net,1433;Initial Catalog=%s;Persist Security Info=False;User ID=%s;Password=%s;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",var.sqlserver_instance_name,var.database_name,var.adminusername,var.adminpassword)
# }

locals {
  api_connection_name = "${var.name}-acn"
}

locals {
  query=format("ALTER USER %s WITH LOGIN = %s;",var.appuser,var.applogin)
}

locals {
  arm_file_path = "${path.module}/template/armtemplate.json"
}

# connection_string=format(Server=tcp:sampleappproddrdbserver-ue2-dr.database.windows.net,1433;Initial Catalog=sampleappdb;Persist Security Info=False;User ID=sqladmin;Password=lecturer7-matrimony-speak;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
