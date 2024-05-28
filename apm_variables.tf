variable "create_apm_resources" {
  description = "If set to false, only synthetic monitor will be created"
  type        = bool
  default     = true
}

variable "create_critical_resources" {
  description = "Determine if critical apm resources are created"
  type        = bool
}

variable "pagerduty_escalation_policy" {
  type    = string
  default = "Default"
}

variable "newrelic_resource_name_prefix" {
  type    = string
  default = ""
}

variable "newrelic_resource_name_suffix" {
  type    = string
  default = ""
}

variable "newrelic_entity_domain" {
  description = "NewRelic domain"
  type        = string
  default     = "APM"
}

variable "newrelic_entity_type" {
  description = "NewRelic type"
  type        = string
  default     = "APPLICATION"
}

variable "monitor_name_uri" {
  type = map(object({
    name = string
    uri  = string
  }))
}
variable "monitor_type" {
  type    = string
  default = "SIMPLE"
}
variable "monitor_period" {
  type    = string
  default = "EVERY_5_MINUTES"
}
variable "monitor_status" {
  type    = string
  default = "ENABLED"
}
variable "monitor_locations_public" {
  type    = list(string)
  default = ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"]
}
variable "monitor_validation_string" {
  type    = string
  default = ""
}
variable "monitor_verify_ssl" {
  type    = bool
  default = true
}
variable "monitor_bypass_head_request" {
  type    = bool
  default = false
}