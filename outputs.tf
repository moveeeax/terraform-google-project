output "id" {
  description = "Identifier of the project."
  value       = google_project.this.id
}

output "project_id" {
  description = "Id of the project."
  value       = google_project.this.project_id
}

output "number" {
  description = "Numeric identifier of the project."
  value       = google_project.this.number
}

output "enabled_apis" {
  description = "APIs enabled on the project."
  value       = [for s in google_project_service.this : s.service]
}

output "lien_name" {
  description = "System-generated name of the project lien, or null when no lien is configured."
  value       = one(google_resource_manager_lien.this[*].name)
}
