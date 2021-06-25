locals {
  application_short_name  = "HW"
  application_environment = "dev"
  application_homepage    = "https://localhost:4200"
}

module "azuread_app_frontend" {
  #source                  = "git::https://github.com/0xdbe-terraform/terraform-azure-resource-group.git?ref=v2.0.1"
  source = "../"
  application_short_name    = local.application_short_name
  application_environment   = local.application_environment
  application_homepage      = local.application_homepage
  application_redirect_uris = [local.application_homepage]
}