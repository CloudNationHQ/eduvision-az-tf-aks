module "kubernetes" {
  #count                  = 1 # some resources could require a cluster pre-existing. in that case, set this to 0 during the first run.
  count                  = length(azurerm_subnet.alb) > 0 ? 1 : 0
  source                 = "./kubernetes"
  aks                    = module.aks.cluster
  alb_identity_client_id = azurerm_user_assigned_identity.alb_identity.client_id
  alb_subnet_id          = azurerm_subnet.alb.id
  depends_on             = [helm_release.alb]
}
