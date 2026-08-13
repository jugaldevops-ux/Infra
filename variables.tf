variable "environments" {

  type = map(object({
    rg_name      = string
    location     = string
    acr_name     = string
    aks_name     = string
    node_count   = number
    vm_size      = string
    vnet_name    = string
    subnet_name  = string
    address_space = list(string)
    subnet_prefix = list(string)
  }))
}