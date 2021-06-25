data "azuread_client_config" "current" {}

resource "azuread_application" "main" {
  display_name     = "frontend-${var.application_short_name}-${var.application_environment}"
  owners           = [data.azuread_client_config.current.object_id]

  web {
    homepage_url  = var.application_homepage
    redirect_uris = var.application_redirect_uris
  }
}