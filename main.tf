terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "7454c207-6484-4225-8771-680428895c08"
}

# =========================
# Resource Groups
# =========================

resource "azurerm_resource_group" "rg" {

  for_each = var.environments

  name     = each.value.rg_name
  location = each.value.location
}

# =========================
# Azure Container Registry
# =========================

resource "azurerm_container_registry" "acr" {

  for_each = var.environments

  name                = each.value.acr_name
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  sku                 = "Basic"
  admin_enabled       = true
}

# =========================
# AKS Cluster
# =========================

resource "azurerm_kubernetes_cluster" "aks" {

  for_each = var.environments

  name                = each.value.aks_name
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  dns_prefix          = "${each.key}-dns"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "default"
    node_count = each.value.node_count
    vm_size    = each.value.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }
}
# =========================
# AKS to ACR Permission
# =========================

resource "azurerm_role_assignment" "aks_acr_pull" {

  for_each = var.environments

  principal_id                     = azurerm_kubernetes_cluster.aks[each.key].kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr[each.key].id
  skip_service_principal_aad_check = true
}

resource "azurerm_virtual_network" "vnet" {

  for_each = var.environments

  name                = each.value.vnet_name
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  address_space = each.value.address_space
}

resource "azurerm_subnet" "subnet" {

  for_each = var.environments

  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name

  address_prefixes = each.value.subnet_prefix
}
