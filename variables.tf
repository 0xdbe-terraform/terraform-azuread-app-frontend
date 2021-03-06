variable "application_short_name" {
  type        = string
  description = "Short name of your application using abbreviations or acronyms."
  validation {
    condition     = can(regex("^\\w+$", var.application_short_name))
    error_message = "Application short name can only consist of letters and numbers."
  }
}

variable "application_environment" {
  type        = string
  default     = "prod"
  description = "Name of the environment (example: dev, test, prod, ...)"
}

variable "application_homepage" {
  type        = string
  description = "The URL to the application's home page"
}

variable "application_redirect_uris" {
  type        = set(string)
  description = "The redirect uris to the application's"
}

variable "backend_object_id" {
  type        = string
  description = "Object ID of the backend"
}

variable "backend_client_id" {
  type        = string
  description = "Client ID or App ID of the backend"
}

variable "backend_scopes_id" {
  type        = set(string)
  description = "list of scope id of the backend"
}