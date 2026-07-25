terraform {
  # The module itself works on >= 1.5. The test suite under tests/ uses
  # mock_provider and therefore needs >= 1.7 (or OpenTofu >= 1.7) to run.
  required_version = ">= 1.5"

  required_providers {
    google = {
      # google_project.deletion_policy was added in 5.41.0. Before that the
      # resource only had the deprecated skip_delete field.
      source  = "hashicorp/google"
      version = ">= 5.41"
    }
  }
}
