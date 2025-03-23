
variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  type        = string
  default = null
}


variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources"
  type        = string
}


variable "cloud_armor_policy_name" {
  description = "Name of the cloud armor policy"
  type        = string
  default     = null
}

variable "cloud_armor_policy_ip_ranges" {
  type        = list(string)
  description = "Specify IP ranges to aloow traffic"
  default     = ["*"]
}


variable "services" {
  type        = list(map(string))
  description = " Define Services"
}


variable "create_url_map" {
  description = "Set to `false` if url_map variable is provided."
  type        = bool
  default     = true
}

variable "url_map" {
  description = "The url_map resource to use. Default is to send all traffic to first backend."
  type        = string
  default     = null
}

variable "http_forward" {
  description = "Set to `false` to disable HTTP port 80 forward"
  type        = bool
  default     = true
}

variable "ssl" {
  description = "Set to `true` to enable SSL support, requires variable `ssl_certificates` - a list of self_link certs"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  type        = string
  description = "Selfink to SSL Policy"
  default     = null
}

variable "ssl_certificates" {
  description = "SSL cert self_link list. Required if `ssl` is `true` and no `private_key` and `certificate` is provided."
  type        = list(string)
  default     = null
}

variable "quic" {
  type        = bool
  description = "Set to `true` to enable QUIC support"
  default     = false
}

variable "region" {
  type        = string
  description = "Define region"
  default     = null
}


variable "protocol" {
  description = "Protocol to associate with the backend service"
  type        = string
  default     = null
}


variable "https_redirect" {
  description = "Set to `true` to enable https redirect on the lb."
  type        = bool
  default     = false
}


variable "load_balancing_scheme" {
  description = "Load balancing scheme type (EXTERNAL for classic external load balancer, EXTERNAL_MANAGED for Envoy-based load balancer, and INTERNAL_SELF_MANAGED for traffic director)"
  type        = string
  default     = "EXTERNAL"
}