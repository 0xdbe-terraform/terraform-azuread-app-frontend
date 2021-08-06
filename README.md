# Terraform Azure AD Application for Frontend

Terraform module to create an application (aka app registration) in Azure Active Directory.

This module sets suitable configuration for Frontend, suck as redirect URI.

This module use the Microsoft Graph API and not the AzureAD Graph API.
Azure CLI is needed to make some requests not yet supported by provider.

## Usage

```hcl
locals {
  application_short_name    = "HW"
  application_environment   = "dev"
  application_homepage      = "https://localhost:4200"
  application_redirect_uris = "${local.application_homepage}/callback"
  backend_api_scope = [
    {
      name = "product:read"
      description = "read all product"
    },
    {
      name = "product:write"
      description = "write all product"
    },
    {
      name = "invoice:write"
      description = "Edit all invoice"
    }
  ]
}

module "azuread_app_backend" {
  source                    = "git::https://github.com/0xdbe-terraform/terraform-azuread-app-backend.git?ref=v1.0.1"
  application_short_name    = local.application_short_name
  application_environment   = local.application_environment
  application_api_scope     = local.backend_api_scope
}

module "azuread_app_frontend" {
  source                    = "git::https://github.com/0xdbe-terraform/terraform-azuread-app-frontend.git?ref=v1.0.0"
  application_short_name    = local.application_short_name
  application_environment   = local.application_environment
  application_homepage      = local.application_homepage
  application_redirect_uris = [local.application_redirect_uris]
  backend_object_id         = module.azuread_app_backend.object_id
  backend_client_id         = module.azuread_app_backend.client_id
  backend_scopes_id         = module.azuread_app_backend.scopes_id
}
```

## Warning

Don't try to change scopes list after apply.
This will return a new ``required_resource_access`` and raise an error:

```
│ Error: Provider produced inconsistent final plan
│
│ When expanding the plan for module.azuread_app_frontend.azuread_application.main to include new values learned so far during apply, provider "registry.terraform.io/hashicorp/azuread" produced an invalid new value for
│ .required_resource_access: planned set element cty.ObjectVal(map[string]cty.Value{"resource_access":cty.ListVal([]cty.Value{cty.ObjectVal(map[string]cty.Value{"id":cty.StringVal("028691ce-96a9-cfb3-c482-d90959cc7f1b"),
│ "type":cty.StringVal("Scope")}), cty.ObjectVal(map[string]cty.Value{"id":cty.StringVal("e82e7807-3a6a-81cc-bd7b-39118ef64fc7"), "type":cty.StringVal("Scope")}), cty.ObjectVal(map[string]cty.Value{"id":cty.UnknownVal(cty.String),
│ "type":cty.StringVal("Scope")})}), "resource_app_id":cty.StringVal("ee1612f9-4323-4a22-ba2e-f6d21969b4e6")}) does not correlate with any element in actual.
```

Workarround: if you need to change scopes list, destroy then apply


## What still needs to be done

- [ ] Ignore backend to configure only frontend
- [ ] Create App Role
- [ ] user and group assignement