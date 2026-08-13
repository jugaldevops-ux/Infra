environments = {

  dev = {

    rg_name      = "rg-vb-dev"
    location     = "centralindia"

    acr_name     = "acrdevvb123"

    aks_name     = "aks-dev"

    node_count   = 2
    vm_size      = "Standard_B2s_v2"

    vnet_name    = "vnet-dev"
    subnet_name  = "aks-subnet"

    address_space = ["10.10.0.0/16"]
    subnet_prefix = ["10.10.1.0/24"]
  }
}