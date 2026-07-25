# Requires Terraform >= 1.7 / OpenTofu >= 1.7 for mock_provider.
# No credentials and no network access are needed.

mock_provider "google" {}

variables {
  project_id = "example-project-1234"
  name       = "Example Project"
  org_id     = "123456789012"
}

run "defaults_are_safe" {
  assert {
    condition     = google_project.this.auto_create_network == false
    error_message = "auto_create_network must default to false; the default VPC ships with permissive firewall rules."
  }

  assert {
    condition     = google_project.this.deletion_policy == "PREVENT"
    error_message = "deletion_policy must default to PREVENT so a stray destroy cannot take the project with it."
  }

  assert {
    condition     = length(google_project_default_service_accounts.this) == 0
    error_message = "The default service accounts must be left untouched unless default_service_account_action is set."
  }
}

run "apis_are_enabled_without_being_disabled_on_destroy" {
  variables {
    activate_apis = ["compute.googleapis.com", "run.googleapis.com"]
  }

  assert {
    condition     = length(google_project_service.this) == 2
    error_message = "Every entry in activate_apis must produce a google_project_service resource."
  }

  assert {
    condition     = alltrue([for s in google_project_service.this : s.disable_on_destroy == false])
    error_message = "disable_on_destroy must stay false so removing an API from the list does not break live workloads."
  }
}

run "default_service_accounts_can_be_deprivileged" {
  variables {
    default_service_account_action = "DEPRIVILEGE"
  }

  assert {
    condition     = one(google_project_default_service_accounts.this).action == "DEPRIVILEGE"
    error_message = "Setting default_service_account_action must manage the default service accounts."
  }
}

run "rejects_invalid_deletion_policy" {
  # Variable validation fires during plan; expected failures must be planned, not applied.
  command = plan

  variables {
    deletion_policy = "Prevent"
  }

  expect_failures = [var.deletion_policy]
}

run "rejects_unqualified_api_name" {
  # Variable validation fires during plan; expected failures must be planned, not applied.
  command = plan

  variables {
    activate_apis = ["compute.googleapis"]
  }

  expect_failures = [var.activate_apis]
}

run "rejects_billing_account_resource_name" {
  # Variable validation fires during plan; expected failures must be planned, not applied.
  command = plan

  variables {
    billing_account = "billingAccounts/0123AB-4567CD-89EF01"
  }

  expect_failures = [var.billing_account]
}

run "accepts_bare_billing_account_id" {
  variables {
    billing_account = "0123AB-4567CD-89EF01"
  }

  assert {
    condition     = google_project.this.billing_account == "0123AB-4567CD-89EF01"
    error_message = "A bare billing account id must be accepted and passed through unchanged."
  }
}

run "rejects_invalid_default_service_account_action" {
  # Variable validation fires during plan; expected failures must be planned, not applied.
  command = plan

  variables {
    default_service_account_action = "deprivilege"
  }

  expect_failures = [var.default_service_account_action]
}
