output "aks_names" {
  value = {
    for k, v in azurerm_kubernetes_cluster.aks :
    k => v.name
  }
}

output "acr_login_server" {
  value = {
    for k, v in azurerm_container_registry.acr :
    k => v.login_server
  }
}