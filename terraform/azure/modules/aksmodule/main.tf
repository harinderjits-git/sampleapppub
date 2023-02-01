resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  location            = azurerm_resource_group.rg.location
  name                = var.name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.name
  tags     = var.tags
  kubernetes_version = var.kubernetes_version
  default_node_pool {
    name       = "agentpool"
    vm_size    = var.vm_size
    node_count = var.agent_count
  }
  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  identity {
    type = "SystemAssigned"
  }
  #   service_principal {
  #     client_id     = var.aks_service_principal_app_id
  #     client_secret = var.aks_service_principal_client_secret
  #   }
}


resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_kubernetes_cluster.this]
  create_duration = "30s"
}


resource "azurerm_role_assignment" "this" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_resource_id
 # scope                            = data.azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
}
