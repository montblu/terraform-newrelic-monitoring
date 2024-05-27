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

# Synthetic Monitors variables
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

# NewRelic Notification Channel variables

variable "newrelic_notification_channel_synthetics_property" {
  type = list(object({
    key   = string
    value = any
  }))
  default = [{
    key   = ""
    value = ""
  }]
}

# Synthetics workflow

variable "newrelic_workflow_synthetics_issues_filter" {
  type = list(object({
    name = string
    type = string
    predicate = list(object({
      attribute = string
      operator  = string
      values    = any
    }))
  }))
  default = [{
    name = "workflow-filter"
    type = "FILTER"
    predicate = [{
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = ""
    }]
  }]
}

variable "newrelic_workflow_synthetics_destination" {
  type = list(object({
    channel_id            = any
    notification_triggers = list(string)
  }))
  default = [{
    channel_id            = ""
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }]
}

# Synthetics alert conditions

## Critical monitor alert condition

variable "newrelic_nrql_alert_condition_critical_synthetics_description" {
  type    = string
  default = "critical-alert"
}

variable "newrelic_nrql_alert_condition_critical_synthetics_enabled" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_critical_synthetics_critical" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 3
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }]
}

# Non critical monitor alert condition

variable "newrelic_nrql_alert_condition_noncritical_synthetics_description" {
  type    = string
  default = "critical-alert"
}

variable "newrelic_nrql_alert_condition_noncritical_synthetics_enabled" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_noncritical_synthetics_noncritical" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 1
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }]
}

variable "newrelic_nrql_alert_condition_synthetics_expiration_duration" {
  type    = number
  default = 300
}

variable "newrelic_nrql_alert_condition_synthetics_open_violation_on_expiration" {
  type    = bool
  default = false
}

variable "newrelic_nrql_alert_condition_synthetics_close_violations_on_expiration" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_synthetics_aggregation_window" {
  type    = number
  default = 300
}

# Synthetics pagerduty

variable "pagerduty_service_synthetics_auto_resolve_timeout" {
  type    = any
  default = "null"
}

variable "pagerduty_service_synthetics_acknowledgement_timeout" {
  type    = number
  default = 600
}

variable "pagerduty_service_synthetics_alert_creation_type" {
  type    = string
  default = "create_alerts_and_incidents"
}

variable "pagerduty_service_synthetics_incident_urgency_rule" {
  type = list(object({
    type    = string
    urgency = string
  }))
  default = [{
    type    = "constant"
    urgency = "high"
  }]
}
