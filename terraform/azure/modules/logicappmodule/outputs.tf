output "workflow_outbound_ip_addresses" {
  value = azurerm_logic_app_workflow.this.workflow_outbound_ip_addresses 
}


output "connector_outbound_ip_addresses" {
  value = azurerm_logic_app_workflow.this.connector_outbound_ip_addresses 
}


output "name" {
  value = azurerm_logic_app_workflow.this.name 
}


output "workflow_endpoint_ip_addresses" {
  value = azurerm_logic_app_workflow.this.workflow_endpoint_ip_addresses 
}


output "connector_endpoint_ip_addresses" {
  value = azurerm_logic_app_workflow.this.connector_endpoint_ip_addresses 
}


