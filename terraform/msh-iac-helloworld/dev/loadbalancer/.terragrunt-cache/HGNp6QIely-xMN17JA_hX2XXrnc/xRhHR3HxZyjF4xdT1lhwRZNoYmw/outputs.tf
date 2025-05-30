
output "backend_services" {
  description = "The backend service resources."
  value       = google_compute_backend_service.default
  sensitive   = true
}

output "http_proxy" {
  description = "The HTTP proxy used by this module."
  value       = google_compute_target_http_proxy.default[*].self_link
}

output "https_proxy" {
  description = "The HTTPS proxy used by this module."
  value       = google_compute_target_https_proxy.default[*].self_link
}

output "url_map" {
  description = "The default URL map used by this module."
  value       = google_compute_url_map.default[*].self_link
}
