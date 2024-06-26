module "kubernetes" {
  source                       = "./kubernetes"
  service_account_name         = local.service_account_name
  namespace                    = local.namespace
  workload_managed_identity_id = azurerm_user_assigned_identity.workload.client_id
  key_vault_name               = module.kv.vault.name
}

resource "terraform_data" "kubernetes" {
  depends_on = [azurerm_role_assignment.aks_admin]
  input      = azurerm_kubernetes_cluster.default.kube_config
}


# data "azuread_service_principal" "aks" {
#   display_name = "Azure Kubernetes Service AAD Server"
# }


# provider "kubernetes" {
#   host                   = module.aks.cluster.kube_config.0.host
#   client_certificate     = base64decode(module.aks.cluster.kube_admin_config.0.client_certificate)
#   client_key             = base64decode(module.aks.cluster.kube_admin_config.0.client_key)
#   cluster_ca_certificate = base64decode(module.aks.cluster.kube_admin_config.0.cluster_ca_certificate)
# }

provider "kubectl" {
  load_config_file = false
  host             = terraform_data.kubernetes.output.0.host
  cluster_ca_certificate = base64decode(
    terraform_data.kubernetes.output.0.cluster_ca_certificate,
  )
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" # data.azuread_service_principal.aks.client_id
    ]
  }
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

output "name" {
  value = terraform_data.kubernetes.output.0.host
}

provider "kubernetes" {
  #host = module.aks.cluster.kube_config.0.host
  host = terraform_data.kubernetes.output.0.host
  cluster_ca_certificate = base64decode(
    #module.aks.cluster.kube_config[0].cluster_ca_certificate,
    terraform_data.kubernetes.output.0.cluster_ca_certificate,
  )
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" # data.azuread_service_principal.aks.client_id
    ]
  }
}
