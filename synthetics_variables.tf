locals {
  pagerduty_vendors = [
    "New Relic",
    "Prometheus"
  ]
}

data "pagerduty_vendor" "vendor" {
  for_each = toset(local.pagerduty_vendors)

  name = each.key
}


variable "pagerduty_escalation_policy_slack" {
  type    = string
  default = "Slack escalation policy"
}

data "pagerduty_escalation_policy" "slack" {
  name = var.pagerduty_escalation_policy_slack
}


variable "newrelic_resource_name_prefix" {
  description = "The prefix for the newrelic_entity name"
  type        = string
  default     = ""
}

variable "newrelic_resource_name_suffix" {
  description = "The suffix for newrelic_entity name"
  type        = string
  default     = ""
}

variable "newrelic_entity_domain" {
  description = "NewRelic domain"
  default     = "APM"
}

variable "newrelic_entity_type" {
  description = "NewRelic type"
  default     = "APPLICATION"
}

data "newrelic_entity" "entities" {
  name   = "${var.newrelic_resource_name_prefix}${var.newrelic_resource_name_suffix}"
  domain = var.newrelic_entity_domain
  type   = var.newrelic_entity_type
}


# Synthetic monitors

variable "synthetic_monitors" {
  description = "Synthetic monitors settings"
  type = object({
    name                = string
    type                = string
    period              = string
    status              = string
    locations_public    = list(string)
    uri                 = map(string)
    validation_string   = optional(string, "")
    verify_ssl          = optional(bool, true)
    bypass_head_request = optional(bool, false)
  })
}

variable "newrelic_synthetics_alert_policy" {
  type = object({
    name                = string
    incident_preference = optional(string, "PER_CONDITION_AND_TARGET")
  })
}

variable "newrelic_synthetics_notification_destination" {
  type = object({
    name       = string
    type       = string
    property   = string(object({ key = string, value = string }), "")
    auth_token = map(object({ prefix = "service-integration-id", token = string }))
  })
}

variable "newrelic_synthetics_notification_channel" {
  type = object({
    name           = string
    type           = string
    destination_id = any
    product        = string
    property = list(object({
      key   = string
      value = any
    }))
  })
}

variable "newrelic_synthetics_workflow" {
  type = object({
    name                  = string
    muting_rules_handling = string
    issues_filter = list(object({
      name = string
      type = string
      predicate = list(object({
        attribute = string
        operator  = string
        values    = any
      }))
    }))
    destination = list(object({
      channel_id            = any
      notification_triggers = optional(list(string, ["ACTIVATED", "CLOSED"]))
    }))
  })
}

variable "newrelic_nrql_critical_monitor_alert_condition" {
  type = object({
    policy_id   = string
    name        = string
    description = optional(string, "health")
    enabled     = optional(bool, true)
    nrql = object({
      query = string
    })

    critical = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 3)
      threshold_duration    = optional(number, 300)
      threshold_occurrences = optional(string, "at_least_once")
    })
    expiration_duration            = optional(number, 300)
    open_violation_on_expiration   = optional(bool, false)
    close_violations_on_expiration = optional(bool, true)
    aggregation_window             = optional(number, 300)
  })
}

variable "newrelic_nrql_non_critical_monitor_alert_condition" {
  type = object({
    policy_id   = string
    name        = string
    description = optional(string, "health")
    enabled     = optional(bool, true)
    nrql = object({
      query = string
    })

    warning = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 1)
      threshold_duration    = optional(number, 900)
      threshold_occurrences = optional(string, "at_least_once")
    })
    expiration_duration            = optional(number, 600)
    open_violation_on_expiration   = optional(bool, false)
    close_violations_on_expiration = optional(bool, true)
    aggregation_window             = optional(number, 300)
  })
}

# APM 

## Critical APM 

variable "newrelic_notification_destination_critical_apm" {
  type = object({

    name = string
    type = string
    property = object({
      key   = string
      value = string
    })
    auth_token = object({
      prefix = string
      token  = string
    })
  })
}

variable "newrelic_alert_policy_critical_apm_response_time" {
  type = object({
    name                = string
    incident_preference = string
  })
}

variable "newrelic_alert_policy_critical_apm_error_rate" {
  type = object({
    name                = string
    incident_preference = string
  })
}

variable "newrelic_notification_channel_critical_apm_response_time" {
  type = object({
    name           = string
    type           = string
    destination_id = string
    product        = string
    property = list(object({
      key   = string
      value = string
    }))
  })
}

variable "newrelic_notification_channel_critical_apm_error_rate" {
  type = object({
    name           = string
    type           = string
    destination_id = string
    product        = string
    property = list(object({
      key   = string
      value = string
    }))
  })
}

variable "newrelic_nrql_alert_condition_critical_response_time" {
  type = object({
    policy_id   = string
    name        = string
    description = optional(string, "response_time")
    enabled     = optional(bool, true)

    nrql = object({
      query = string
    })

    critical = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 0.7)
      threshold_duration    = optional(number, 300)
      threshold_occurrences = optional(string, "at_least_once")
    })
  })
}

variable "newrelic_nrql_alert_condition_critical_error_rate" {
  type = object({

    policy_id   = string
    name        = string
    description = optional(string, "error_rate")
    enabled     = optional(bool, true)

    nrql = object({
      query = string
    })

    critical = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 15)
      threshold_duration    = optional(number, 300)
      threshold_occurrences = optional(string, "at_least_once")
    })
  })
}


variable "newrelic_workflow_critical_apm_response_time" {
  type = object({
    name                  = string
    muting_rules_handling = string

    issues_filter = object({
      name = string
      type = string
    })

    predicate = object({
      attribute = string
      operator  = string
      values    = string
    })

    destination = object({
      channel_id            = string
      notification_triggers = optional(list(string, ["ACTIVATED", "CLOSED"]))
    })
  })
}

variable "newrelic_workflow_critical_apm_error_rate" {
  type = object({
    name                  = string
    muting_rules_handling = string

    issues_filter = object({
      name = string
      type = string
    })

    predicate = object({
      attribute = string
      operator  = string
      values    = string
    })

    destination = object({
      channel_id            = string
      notification_triggers = optional(list(string, ["ACTIVATED", "CLOSED"]))
    })
  })
}

variable "newrelic_notification_destination_non_critical_apm" {
  type = object({
    name = string
    type = string
    property = object({
      key   = string
      value = string
    })
    auth_token = object({
      prefix = string
      token  = string
    })
  })
}

variable "newrelic_alert_policy_non_critical_apm_response_time" {
  type = object({
    name                = string
    incident_preference = string
  })
}

variable "newrelic_alert_policy_non_critical_apm_error_rate" {
  type = object({
    name                = string
    incident_preference = string
  })
}

variable "newrelic_notification_channel_non_critical_apm_response_time" {
  type = object({
    name           = string
    type           = string
    destination_id = string
    product        = string
    property = list(object({
      key   = string
      value = string
    }))
  })
}

variable "newrelic_notification_channel_non_critical_apm_error_rate" {
  type = object({
    name           = string
    type           = string
    destination_id = string
    product        = string
    property = list(object({
      key   = string
      value = string
    }))
  })
}

variable "newrelic_nrql_alert_condition_non_critical_response_time" {
  type = object({
    policy_id   = string
    name        = string
    description = optional(string, "response_time")
    enabled     = optional(bool, true)

    nrql = object({
      query = string
    })

    warning = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 0.5)
      threshold_duration    = optional(number, 900)
      threshold_occurrences = optional(string, "at_least_once")
    })
  })
}

variable "newrelic_nrql_alert_condition_non_critical_error_rate" {
  type = object({

    policy_id   = string
    name        = string
    description = optional(string, "error-rate")
    enabled     = optional(bool, true)

    nrql = object({
      query = string
    })
    warning = object({
      operator              = optional(string, "above_or_equals")
      threshold             = optional(number, 7)
      threshold_duration    = optional(number, 900)
      threshold_occurrences = optional(string, "at_least_once")
    })
  })
}

variable "newrelic_workflow_non_critical_apm_response_time" {
  type = object({
    name                  = string
    muting_rules_handling = string

    issues_filter = object({
      name = string
      type = string

      predicate = object({
        attribute = string
        operator  = string
        values    = string
      })
    })

    destination = object({
      channel_id            = string
      notification_triggers = optional(list(string, ["ACTIVATED", "CLOSED"]))
    })
  })
}

variable "newrelic_workflow_non_critical_apm_error_rate" {
  type = object({
    name                  = string
    muting_rules_handling = string

    issues_filter = object({
      name = string
      type = string

      predicate = object({
        attribute = string
        operator  = string
        values    = string
      })
    })
    destination = object({
      channel_id            = string
      notification_triggers = optional(list(string, ["ACTIVATED", "CLOSED"]))
    })
  })
}

# Pagerduty

## Synthetic monitors

variable "pagerduty_service_synthetics_newrelic" {
  type = object({
    name                    = string
    auto_resolve_timeout    = optional(any, "null")
    acknowledgement_timeout = optional(number, 600)
    escalation_policy       = string
    alert_creation          = optional(string, "create_alerts_and_incidents")

    incident_urgency_rule = optional(object({
      type    = optional(string, "constant")
      urgency = optional(string, "high")
    }))
  })
}

variable "pagerduty_service_integration_synthetics_newrelic" {
  type = object({
    name    = string
    service = string
    vendor  = string
  })
}

variable "pagerduty_service_critical" {
  type = object({
    name                    = string
    auto_resolve_timeout    = optional(any, "null")
    acknowledgement_timeout = optional(number, 600)
    escalation_policy       = string
    alert_creation          = optional(string, "create_alerts_and_incidents")

    incident_urgency_rule = object({
      type    = optional(string, "constant")
      urgency = optional(string, "high")
    })
  })
}

variable "pagerduty_service_non_critical" {
  type = object({
    name                    = string
    auto_resolve_timeout    = optional(any, "null")
    acknowledgement_timeout = optional(number, 600)
    escalation_policy       = string
    alert_creation          = optional(string, "create_alerts_and_incidents")

    incident_urgency_rule = object({
      type    = optional(string, "constant")
      urgency = optional(string, "low")
    })
  })
}

variable "pagerduty_service_integration_critical" {
  type = object({
    name    = string
    service = string
    vendor  = string
  })
}

variable "pagerduty_service_integration_non_critical" {
  type = object({
    name    = string
    service = string
    vendor  = string
  })
}

variable "pagerduty_service_integration_non_critical_events_API_v2" {
  type = object({
    name    = optional(string, "Events API V2")
    service = string
    type    = optional(string, "events_api_v2_inbound_integration")
  })
}

