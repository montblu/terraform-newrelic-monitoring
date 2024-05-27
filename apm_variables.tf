variable "create_critical_resources" {
  description = "Determine if critical apm resources are created"
  type        = bool
}

variable "newrelic_nrql_alert_condition_critical_response_time_description" {
  type    = string
  default = "response-time"
}

variable "newrelic_nrql_alert_condition_critical_response_time_enabled" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_critical_response_time_critical" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 0.7
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }]
}

variable "critical_error_threshold" {
  type    = number
  default = 15
}

variable "newrelic_nrql_alert_condition_critical_error_rate_description" {
  type    = string
  default = "error-rate"
}

variable "newrelic_nrql_alert_condition_critical_error_rate_enabled" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_critical_error_rate_critical" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 15
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }]
}

variable "newrelic_workflow_critical_apm_response_time_issues_filter" {
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

variable "newrelic_workflow_critical_apm_response_time_destination" {
  type = list(object({
    channel_id            = any
    notification_triggers = list(string)
  }))
  default = [{
    channel_id            = ""
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }]
}



variable "newrelic_workflow_critical_apm_error_rate_issues_filter" {
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

variable "newrelic_workflow_critical_apm_error_rate_destination" {
  type = list(object({
    channel_id            = any
    notification_triggers = list(string)
  }))
  default = [{
    channel_id            = ""
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }]
}

variable "newrelic_nrql_alert_condition_non_critical_response_time_warning" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 0.5
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }]
}

variable "newrelic_nrql_alert_condition_non_critical_error_rate_description" {
  type    = string
  default = "error-rate"
}

variable "newrelic_nrql_alert_condition_non_critical_error_rate_enabled" {
  type    = bool
  default = true
}

variable "newrelic_nrql_alert_condition_non_critical_error_rate_warning" {
  type = list(object({
    operator              = string
    threshold             = number
    threshold_duration    = number
    threshold_occurrences = string
  }))
  default = [{
    operator              = "above_or_equals"
    threshold             = 7
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }]
}
