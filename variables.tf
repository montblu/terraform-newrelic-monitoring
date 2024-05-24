# locals {
#   pagerduty_vendors = [
#     "New Relic",
#     "Prometheus"
#   ]
# }

# data "pagerduty_vendor" "vendor" {
#   for_each = toset(local.pagerduty_vendors)

#   name = each.key
# }

# variable "pagerduty_escalation_policy_slack" {
#   type    = string
#   default = "Slack escalation policy"
# }

# data "pagerduty_escalation_policy" "slack" {
#   name = var.pagerduty_escalation_policy_slack
# }


# variable "newrelic_resource_name_prefix" {
#   description = "The prefix for the newrelic_entity name"
#   type        = string
#   default     = ""
# }

# variable "newrelic_resource_name_suffix" {
#   description = "The suffix for newrelic_entity name"
#   type        = string
#   default     = ""
# }

# variable "newrelic_entity_domain" {
#   description = "NewRelic domain"
#   default     = "APM"
# }

# variable "newrelic_entity_type" {
#   description = "NewRelic type"
#   default     = "APPLICATION"
# }

# data "newrelic_entity" "entities" {
#   name   = "${var.newrelic_resource_name_prefix}${var.newrelic_resource_name_suffix}"
#   domain = var.newrelic_entity_domain
#   type   = var.newrelic_entity_type
# }

variable "synthetic_monitors" {
  description = "Synthetic monitors settings"
  type = list(object({
    name                = string
    type                = optional(string, "SIMPLE")
    period              = optional(string, "EVERY_5_MINUTES")
    status              = optional(string, "ENABLED")
    locations_public    = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    uri                 = string
    validation_string   = optional(string, "")
    verify_ssl          = optional(bool, true)
    bypass_head_request = optional(bool, false)
  }))
}

variable "newrelic_alert_policy" {
  type = list(object({
    name                = string
    incident_preference = optional(string, "PER_CONDITION_AND_TARGET")
  }))
}

variable "newrelic_notification_destination" {
  type = list(object({
    name = optional(string)
    type = optional(string)
    property = list(object({
      key   = optional(string)
      value = optional(string)
    }))
    auth_token = list(object({
      prefix = optional(string)
      token  = optional(string)
    }))
  }))
  default = [{
    name = "resource-notification-destination"
    type = "PAGERDUTY_SERVICE_INTEGRATION"
    property = [{
      key   = ""
      value = ""
    }]
    auth_token = [{
      prefix = ""
      token  = ""
    }]
  }]
}

variable "newrelic_notification_channel" {
  type = list(object({
    name           = string
    type           = string
    destination_id = any
    product        = string
    property = list(object({
      key   = string
      value = any
    }))
  }))
}

variable "newrelic_workflow" {
  type = list(object({
    name                  = string
    muting_rules_handling = optional(string)
    issues_filter = optional(list(object({
      name = optional(string)
      type = optional(string)
      predicate = list(object({
        attribute = optional(string)
        operator  = optional(string)
        values    = any
      }))
    })))
    destination = list(object({
      channel_id            = any
      notification_triggers = optional(list(string))
    }))
  }))
  default = [{
    name                  = "default-workflow-name"
    muting_rules_handling = "NOTIFY_ALL_ISSUES"
    issues_filter = [{
      name = "workflow-filter"
      type = "FILTER"

      predicate = [{
        attribute = "labels.policyIds"
        operator  = "EXACTLY_MATCHES"
        values    = ""
      }]
    }]
    destination = [{
      channel_id            = ""
      notification_triggers = ["ACTIVATED", "CLOSED"]
    }]
  }]
}

variable "newrelic_nrql_alert_condition" {
  type = list(object({
    policy_id   = string
    name        = string
    description = optional(string, "critical-alert")
    enabled     = optional(bool, true)
    nrql = object({
      query = string
    })

    critical = list(object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 3)
      threshold_duration    = optional(number, 300)
      threshold_occurrences = optional(string, "at_least_once")
    }))
    warning = list(object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 1)
      threshold_duration    = optional(number, 900)
      threshold_occurrences = optional(string, "at_least_once")
    }))
    expiration_duration            = optional(number, 300)
    open_violation_on_expiration   = optional(bool, false)
    close_violations_on_expiration = optional(bool, true)
    aggregation_window             = optional(number, 300)
  }))
}

variable "pagerduty_service" {
  type = list(object({
    name                    = string
    auto_resolve_timeout    = optional(any, "null")
    acknowledgement_timeout = optional(number, 600)
    escalation_policy       = string
    alert_creation          = optional(string, "create_alerts_and_incidents")

    incident_urgency_rule = optional(list(object({
      type    = optional(string, "constant")
      urgency = optional(string, "high")
    })))
  }))
}

variable "pagerduty_service_integration" {
  type = list(object({
    name    = string
    service = string
    vendor  = string
  }))
}
