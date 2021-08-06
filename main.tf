data "azuread_client_config" "current" {}

resource "azuread_application" "main" {
  display_name     = "frontend-${var.application_short_name}-${var.application_environment}"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {}

  required_resource_access {
    resource_app_id = var.backend_client_id

    dynamic "resource_access" {
      for_each = var.backend_scopes_id
      content {
        id     = resource_access.value
        type = "Scope"
      }
    }

  }

}

resource azuread_service_principal main {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = true
}

resource "null_resource" "single_page_application" {
  # Waiting new resource block: single_page_application
  # https://github.com/hashicorp/terraform-provider-azuread/pull/474
  triggers = {
    frontend_object_id = azuread_application.main.id
    redirect_uri = join("\",\"",var.application_redirect_uris)
  }
  provisioner "local-exec" {
    command = <<EOT
      az rest \
        --method PATCH \
        --uri https://graph.microsoft.com/v1.0/applications/$FRONTEND_OBJECT_ID \
       --body "{\"spa\":{\"redirectUris\":[\"$REDIRECT_URI\"]}}"
    EOT
    environment = {
      FRONTEND_OBJECT_ID = azuread_application.main.id
      REDIRECT_URI = join("\",\"",var.application_redirect_uris)
    }
  }
}

resource "null_resource" "application_pre_authorized" {
  # Waiting new resource: application_pre_authorized
  # https://github.com/hashicorp/terraform-provider-azuread/pull/472
  triggers = {
    backend_object_id = var.backend_object_id
    SCOPES            = join("\",\"",var.backend_scopes_id)
  }
  provisioner "local-exec" {
    command = <<EOT
      az rest --method PATCH \
      --uri https://graph.microsoft.com/v1.0/applications/$BACKEND_OBJECT_ID \
      --body "{\"api\":{\"preAuthorizedApplications\":[{\"appId\": \"$FRONTEND_CLIENT_ID\",\"delegatedPermissionIds\": [\"$SCOPES\"]}]}}"
    EOT
    environment = {
      BACKEND_OBJECT_ID  = var.backend_object_id
      FRONTEND_CLIENT_ID = azuread_application.main.application_id
      SCOPES             = join("\",\"",var.backend_scopes_id)
    }
  }
}
