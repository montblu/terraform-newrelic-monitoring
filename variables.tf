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
    name                              = string
    uri                               = string
    type                              = optional(string, "SIMPLE")
    period                            = optional(string, "EVERY_5_MINUTES")
    status                            = optional(string, "ENABLED")
    locations_public                  = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    validation_string                 = optional(string, "")
    verify_ssl                        = optional(bool, true)
    bypass_head_request               = optional(bool, false)
    custom_header                     = optional(list(map(string)))
    critical_response_time            = optional(number, 0.7)
    non_critical_response_time        = optional(number, 0.5)
    critical_error_rate               = optional(number, 15)
    non_critical_error_rate           = optional(number, 7)
    create_non_critical_monitor       = optional(bool, false)
    create_critical_monitor           = optional(bool, false)
    create_non_critical_apm_resources = optional(bool, false)
    create_critical_apm_resources     = optional(bool, false)
  }))
}
