resource "google_project" "this" {
  project_id          = var.project_id
  name                = var.name
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  deletion_policy     = var.deletion_policy
  labels              = var.labels
}

resource "google_project_service" "this" {
  for_each = toset(var.activate_apis)

  project = google_project.this.project_id
  service = each.value

  disable_on_destroy = false
}

# GCP grants the Compute Engine / App Engine default service accounts
# roles/editor on the project. Managing them here lets callers strip that
# grant (DEPRIVILEGE) or take the accounts out of service entirely.
resource "google_project_default_service_accounts" "this" {
  count = var.default_service_account_action == null ? 0 : 1

  project = google_project.this.project_id
  action  = var.default_service_account_action

  # The default service accounts only exist once their parent APIs are on.
  depends_on = [google_project_service.this]
}
