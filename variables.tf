variable "project_id" {
  description = "Globally unique id of the project to create."
  type        = string
}

variable "name" {
  description = "Human-readable display name of the project."
  type        = string
}

variable "org_id" {
  description = "Numeric organization id the project belongs to. Mutually exclusive with folder_id."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Numeric folder id the project belongs to. Mutually exclusive with org_id."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "Billing account id to associate with the project, in the bare XXXXXX-XXXXXX-XXXXXX form (not the billingAccounts/... resource name)."
  type        = string
  default     = null

  validation {
    condition     = var.billing_account == null || can(regex("^[0-9A-Za-z]{6}-[0-9A-Za-z]{6}-[0-9A-Za-z]{6}$", coalesce(var.billing_account, "000000-000000-000000")))
    error_message = "billing_account must be a bare billing account id such as \"0123AB-4567CD-89EF01\". The billingAccounts/ prefix is not accepted and is only rejected by the API at apply time."
  }
}

variable "auto_create_network" {
  description = "Whether to create the default network. Leave disabled: the default network ships with permissive firewall rules."
  type        = bool
  default     = false
}

variable "deletion_policy" {
  description = <<-EOT
    What happens to the project when the resource is destroyed. PREVENT blocks the
    destroy, ABANDON drops it from state and leaves the project in place, DELETE
    actually deletes the project and everything in it.
  EOT
  type        = string
  default     = "PREVENT"

  validation {
    condition     = contains(["PREVENT", "ABANDON", "DELETE"], var.deletion_policy)
    error_message = "deletion_policy must be one of PREVENT, ABANDON or DELETE."
  }
}

variable "activate_apis" {
  description = "APIs to enable on the project, as fully qualified service names (e.g. compute.googleapis.com)."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for api in var.activate_apis :
      can(regex("^[a-z0-9][a-z0-9-]*(\\.[a-z0-9][a-z0-9-]*)*\\.(googleapis\\.com|cloud\\.goog)$", api))
    ])
    error_message = "Each entry in activate_apis must be a full service name ending in .googleapis.com (or .cloud.goog for endpoints services), e.g. \"compute.googleapis.com\". Names such as \"compute.googleapis\" or \"compute\" plan cleanly but fail at apply."
  }
}

variable "default_service_account_action" {
  description = <<-EOT
    What to do with the Compute Engine / App Engine default service accounts, which
    GCP creates with roles/editor. One of DEPRIVILEGE (drop roles/editor), DISABLE
    or DELETE. null (the default) leaves them untouched.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.default_service_account_action == null || contains(["DEPRIVILEGE", "DISABLE", "DELETE"], coalesce(var.default_service_account_action, "DEPRIVILEGE"))
    error_message = "default_service_account_action must be null, DEPRIVILEGE, DISABLE or DELETE."
  }
}

variable "labels" {
  description = "Labels applied to the project."
  type        = map(string)
  default     = {}
}
