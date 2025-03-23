resource "google_compute_global_address" "default" {
  project      = var.project
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}


locals {
  url_map             = var.create_url_map ? join("", google_compute_url_map.default.*.self_link) : var.url_map
  create_http_forward = var.http_forward || var.https_redirect
  }


resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  project    = var.project
  count      = local.create_http_forward ? 1 : 0
  name       = "${var.name}"
  target     = google_compute_target_http_proxy.default[0].self_link
  ip_address = google_compute_global_address.default.address
  load_balancing_scheme = var.load_balancing_scheme
  port_range = "80"
  labels = {
    "environment" = split("-", var.name)[0]
    "app"         = split("-", var.name)[1]
  }
}

resource "google_compute_global_forwarding_rule" "https" {
  provider   = google-beta
  project    = var.project
  count      = var.ssl ? 1 : 0
  name       = "${var.name}-https-redirect"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = google_compute_global_address.default.address
  load_balancing_scheme = var.load_balancing_scheme
  port_range = "443"
  labels = {
    "environment" = split("-", var.name)[0]
    "app"         = split("-", var.name)[1]
  }
}


resource "google_compute_target_http_proxy" "default" {
  project = var.project
  count   = local.create_http_forward ? 1 : 0
  name    = "${var.name}-http-proxy"
  url_map = var.https_redirect == false ? local.url_map : join("", google_compute_url_map.https_redirect.*.self_link)
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project
  count   = var.ssl ? 1 : 0
  name    = "${var.name}-https-proxy"
  url_map = local.url_map
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
  quic_override    = var.quic ? "ENABLE" : null
}



resource "google_compute_url_map" "default" {
  project         = var.project
  count           = var.create_url_map ? 1 : 0
  name            = var.name
    default_service = var.services[0].service

  host_rule {
    hosts        = ["*"]
    path_matcher = "default"
  }
  path_matcher {
    name            = "default"
    default_service = var.services[0].service

    dynamic "path_rule" {
      for_each = var.services
      content {
        paths   = [path_rule.value.path]
        service = google_compute_backend_service.default[path_rule.value.service].self_link
        dynamic "route_action" {
          for_each = can(path_rule.value.path_prefix_rewrite) ? [{ "path_prefix_rewrite" : path_rule.value.path_prefix_rewrite }] : []
          content {
            url_rewrite {
              path_prefix_rewrite = route_action.value.path_prefix_rewrite
            }
          }
        }
      }
    }
  }
}


resource "google_compute_url_map" "https_redirect" {
  project = var.project
  count   = var.https_redirect ? 1 : 0
  name    = "${var.name}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_security_policy" "default_policy" {
  name        = var.cloud_armor_policy_name
  description = "allows all traffic but is ready to restrict"

  rule {
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    action      = "deny(403)"
    description = "Deny all other traffic"
  }

  rule {
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.cloud_armor_policy_ip_ranges
      }
    }
    action      = "allow"
    description = "Restrict traffic to specific IPs"
  }
}

resource "google_compute_backend_service" "default" {
  provider = google-beta
  for_each = { for service in var.services : "${service.service}" => service }
  description = each.value.service
  name  = each.value.service
  load_balancing_scheme = var.load_balancing_scheme
  project = var.project
  backend {
      
          group = google_compute_region_network_endpoint_group.neg[each.value.service].self_link
        }
  enable_cdn              = false
  security_policy         = each.value.security_policy
  protocol                = "${var.protocol}"
  log_config {
    enable      = true
    sample_rate = 1
  }
}


resource "google_compute_region_network_endpoint_group" "neg" {
  for_each              = { for service in var.services : "${service.service}" => service }
  name                  = each.value.service
  network_endpoint_type = "SERVERLESS"
  region                = lookup(each.value, "region", var.region)
  project               = var.project

  dynamic "cloud_run" {
    for_each = each.value.type == "cloud_run" ? [{ "service" : each.value.service }] : []
    content {
      service = cloud_run.value.service
    }
  }

  dynamic "cloud_function" {
    for_each = each.value.type == "cloud_function" ? [{ "service" : each.value.service }] : []
    content {
      function = cloud_function.value.service
    }
  }
}
