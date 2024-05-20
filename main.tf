# Synthetic monitors

resource "newrelic_synthetics_monitor" "all" {
  name                = var.synthetic_monitors.name
  type                = var.synthetic_monitors.type
  period              = var.synthetic_monitors.period
  status              = var.synthetic_monitors.status
  locations_public    = var.synthetic_monitors.locations_public
  uri                 = var.synthetic_monitors.uri
  validation_string   = var.synthetic_monitors.validation_string
  verify_ssl          = var.synthetic_monitors.verify_ssl
  bypass_head_request = var.synthetic_monitors.bypass_head_request
}

resource "newrelic_alert_policy" "synthetics" {
  name                = var.newrelic_synthetics_alert_policy.name
  incident_preference = var.newrelic_synthetics_alert_policy.incident_preference
}

resource "newrelic_notification_destination" "synthetics" {
  name = var.newrelic_synthetics_notification_destination.name
  type = var.newrelic_synthetics_notification_destination.type

  property {
    key   = var.newrelic_synthetics_notification_destination.property[key]
    value = var.newrelic_synthetics_notification_destination.property[value]
  }
  auth_token {
    prefix = var.newrelic_synthetics_notification_destination.auth_token[prefix]
    token  = var.newrelic_synthetics_notification_destination.auth_token[token]
  }
}

resource "newrelic_notification_channel" "synthetics" {
  name           = var.newrelic_synthetic_notification_channel.name
  type           = var.newrelic_synthetic_notification_channel.type
  destination_id = var.newrelic_synthetic_notification_channel.destination_id
  product        = var.newrelic_synthetic_notification_channel.product

  dynamic "property" {
    for_each = var.newrelic_synthetic_notification_channel.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_workflow" "synthetic_monitors" {

  name                  = var.newrelic_synthetics_workflow.name
  muting_rules_handling = var.newrelic_synthetics_workflow.muting_rules_handling
  issues_filter {
    name = var.newrelic_synthetics_workflow.issues_filter.name
    type = var.newrelic_synthetics_workflow.issues_filter.type
    # name and type are required but not really relevant:
    # https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow#type

    predicate {
      attribute = var.newrelic_synthetics_workflow.predicate.attribute
      operator  = var.newrelic_synthetics_workflow.predicate.operator
      values    = var.newrelic_synthetics_workflow.predicate.values
    }
  }
  destination {
    channel_id            = var.newrelic_synthetics_workflow.destination.channel_id
    notification_triggers = var.newrelic_synthetics_workflow.destination.notification_triggers
  }
}

resource "newrelic_nrql_alert_condition" "critical_monitor_health" {

  policy_id   = var.newrelic_nrql_critical_alert_condition.policy_id
  name        = var.newrelic_nrql_critical_alert_condition.name
  description = var.newrelic_nrql_critical_alert_condition.description
  enabled     = var.newrelic_nrql_critical_alert_condition.enabled

  nrql {
    query = var.newrelic_nrql_critical_alert_condition.nrql.query
  }
  critical {
    operator              = var.newrelic_nrql_critical_alert_condition.critical.operator
    threshold             = var.newrelic_nrql_critical_alert_condition.critical.threshold
    threshold_duration    = var.newrelic_nrql_critical_alert_condition.critical.threshold_duration
    threshold_occurrences = var.newrelic_nrql_critical_alert_condition.critical.threshold_occurrences
  }
  expiration_duration            = var.newrelic_nrql_critical_alert_condition.expiration_duration
  open_violation_on_expiration   = var.newrelic_nrql_critical_alert_condition.open_violation_on_expiration
  close_violations_on_expiration = var.newrelic_nrql_critical_alert_condition.close_violations_on_expiration
  aggregation_window             = var.newrelic_nrql_critical_alert_condition.aggregation_window
}

resource "newrelic_nrql_alert_condition" "non_critical_monitor_health" {

  policy_id   = var.newrelic_nrql_non_critical_monitor_alert_condition.policy_id
  name        = var.newrelic_nrql_non_critical_monitor_alert_condition.name
  description = var.newrelic_nrql_non_critical_monitor_alert_condition.description
  enabled     = var.newrelic_nrql_non_critical_monitor_alert_condition.enabled

  nrql {
    query = var.newrelic_nrql_non_critical_monitor_alert_condition.nrql.query
  }
  warning {
    operator              = var.newrelic_nrql_non_critical_monitor_alert_condition.warning.operator
    threshold             = var.newrelic_nrql_non_critical_monitor_alert_condition.warning.threshold
    threshold_duration    = var.newrelic_nrql_non_critical_monitor_alert_condition.warning.threshold_duration
    threshold_occurrences = var.newrelic_nrql_non_critical_monitor_alert_condition.warning.threshold_occurrences
  }
  expiration_duration            = var.newrelic_nrql_non_critical_monitor_alert_condition.expiration_duration
  open_violation_on_expiration   = var.newrelic_nrql_non_critical_monitor_alert_condition.open_violation_on_expiration
  close_violations_on_expiration = var.newrelic_nrql_non_critical_monitor_alert_condition.close_violations_on_expiration
  aggregation_window             = var.newrelic_nrql_non_critical_monitor_alert_condition.aggregation_window
}

# APM

# Critical APM resources

resource "newrelic_notification_destination" "critical_apm" {
  name = var.newrelic_notification_destination_critical_apm.name
  type = var.newrelic_notification_destination_critical_apm.type

  property {
    key   = var.newrelic_notification_destination_critical_apm.property.key
    value = var.newrelic_notification_destination_critical_apm.property.value
  }
  auth_token {
    prefix = var.newrelic_notification_destination_critical_apm.auth_token.prefix
    token  = var.newrelic_notification_destination_critical_apm.auth_token.token
  }
}

resource "newrelic_alert_policy" "critical_apm_response_time" {
  name                = var.newrelic_alert_policy_critical_apm_response_time.name
  incident_preference = var.newrelic_alert_policy_critical_apm_response_time.incident_preference
}

resource "newrelic_alert_policy" "critical_apm_error_rate" {
  name                = var.newrelic_alert_policy_critical_apm_error_rate.name
  incident_preference = var.newrelic_alert_policy_critical_apm_error_rate.incident_preference
}

resource "newrelic_notification_channel" "critical_apm_response_time" {

  name           = var.newrelic_notification_channel_critical_apm_response_time.name
  type           = var.newrelic_notification_channel_critical_apm_response_time.type
  destination_id = var.newrelic_notification_channel_critical_apm_response_time.destination_id
  product        = var.newrelic_notification_channel_critical_apm_response_time.product

  dynamic "property" {
    for_each = var.newrelic_notification_channel_critical_apm_response_time.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_notification_channel" "critical_apm_error_rate" {

  name           = var.newrelic_notification_channel_critical_apm_error_rate.name
  type           = var.newrelic_notification_channel_critical_apm_error_rate.type
  destination_id = var.newrelic_notification_channel_critical_apm_error_rate.destination_id
  product        = var.newrelic_notification_channel_critical_apm_error_rate.product

  dynamic "property" {
    for_each = var.newrelic_notification_channel_critical_apm_error_rate.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_nrql_alert_condition" "critical_response_time" {

  policy_id   = var.newrelic_nrql_alert_condition_critical_response_time.policy_id
  name        = var.newrelic_nrql_alert_condition_critical_response_time.name
  description = var.newrelic_nrql_alert_condition_critical_response_time.description
  enabled     = var.newrelic_nrql_alert_condition_critical_response_time.enabled

  nrql {
    query = var.newrelic_nrql_alert_condition_critical_response_time.nrql.query
  }
  critical {
    operator              = var.newrelic_nrql_alert_condition_critical_response_time.critical.operator
    threshold             = var.newrelic_nrql_alert_condition_critical_response_time.critical.threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_critical_response_time.critical.threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_critical_response_time.critical.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "critical_error_rate" {

  policy_id   = var.newrelic_nrql_alert_condition_critical_error_rate.policy_id
  name        = var.newrelic_nrql_alert_condition_critical_error_rate.name
  description = var.newrelic_nrql_alert_condition_critical_error_rate.description
  enabled     = var.newrelic_nrql_alert_condition_critical_error_rate.enabled

  nrql {
    query = var.newrelic_nrql_alert_condition_critical_error_rate.nrql.query
  }
  critical {
    operator              = var.newrelic_nrql_alert_condition_critical_error_rate.critical.operator
    threshold             = var.newrelic_nrql_alert_condition_critical_error_rate.critical.threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_critical_error_rate.critical.threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_critical_error_rate.critical.threshold_occurrences
  }
}

resource "newrelic_workflow" "critical_apm_response_time" {

  name                  = var.newrelic_workflow_critical_apm_response_time.name
  muting_rules_handling = var.newrelic_workflow_critical_apm_response_time.muting_rules_handling

  issues_filter {
    name = var.newrelic_workflow_critical_apm_response_time.issues_filter.name
    type = var.newrelic_workflow_critical_apm_response_time.issues_filter.type

    predicate {
      attribute = var.newrelic_workflow_critical_apm_response_time.predicate.attribute
      operator  = var.newrelic_workflow_critical_apm_response_time.predicate.operator
      values    = var.newrelic_workflow_critical_apm_response_time.predicate.values
    }
  }
  destination {
    channel_id            = var.newrelic_workflow_critical_apm_response_time.destination.channel_id
    notification_triggers = var.newrelic_workflow_critical_apm_response_time.destination.notification_triggers
  }
}

resource "newrelic_workflow" "critical_apm_error_rate" {

  name                  = var.newrelic_workflow_critical_apm_error_rate.name
  muting_rules_handling = var.newrelic_workflow_critical_apm_error_rate.muting_rules_handling

  issues_filter {
    name = var.newrelic_workflow_critical_apm_error_rate.issues_filter.name
    type = var.newrelic_workflow_critical_apm_error_rate.issues_filter.type

    predicate {
      attribute = var.newrelic_workflow_critical_apm_error_rate.predicate.attribute
      operator  = var.newrelic_workflow_critical_apm_error_rate.predicate.operator
      values    = var.newrelic_workflow_critical_apm_error_rate.predicate.values
    }
  }
  destination {
    channel_id            = var.newrelic_workflow_critical_apm_error_rate.destination.channel_id
    notification_triggers = var.newrelic_workflow_critical_apm_error_rate.destination.notification_triggers
  }
}

# Non-Critical APM resources

resource "newrelic_notification_destination" "non_critical_apm" {
  name = var.newrelic_notification_destination_non_critical_apm.name
  type = var.newrelic_notification_destination_non_critical_apm.type

  property {
    key   = var.newrelic_notification_destination_non_critical_apm.property.key
    value = var.newrelic_notification_destination_non_critical_apm.property.value
  }
  auth_token {
    prefix = var.newrelic_notification_destination_non_critical_apm.auth_token.prefix
    token  = var.newrelic_notification_destination_non_critical_apm.auth_token.token
  }
}

resource "newrelic_alert_policy" "non_critical_apm_response_time" {
  name                = var.newrelic_alert_policy_non_critical_apm_response_time.name
  incident_preference = var.newrelic_alert_policy_non_critical_apm_response_time.incident_preference
}

resource "newrelic_alert_policy" "non_critical_apm_error_rate" {
  name                = var.newrelic_alert_policy_non_critical_apm_error_rate.name
  incident_preference = var.newrelic_alert_policy_non_critical_apm_error_rate.incident_preference
}

resource "newrelic_notification_channel" "non_critical_apm_response_time" {
  name           = var.newrelic_notification_channel_non_critical_apm_response_time.name
  type           = var.newrelic_notification_channel_non_critical_apm_response_time.type
  destination_id = var.newrelic_notification_channel_non_critical_apm_response_time.destination_id
  product        = var.newrelic_notification_channel_non_critical_apm_response_time.product

  dynamic "property" {
    for_each = var.newrelic_notification_channel_non_critical_apm_response_time.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_notification_channel" "non_critical_apm_error_rate" {
  name           = var.newrelic_notification_channel_non_critical_apm_error_rate.name
  type           = var.newrelic_notification_channel_non_critical_apm_error_rate.type
  destination_id = var.newrelic_notification_channel_non_critical_apm_error_rate.destination_id
  product        = var.newrelic_notification_channel_non_critical_apm_error_rate.product

  dynamic "property" {
    for_each = var.newrelic_notification_channel_non_critical_apm_error_rate.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_response_time" {
  policy_id   = var.newrelic_nrql_alert_condition_non_critical_response_time.policy_id
  name        = var.newrelic_nrql_alert_condition_non_critical_response_time.name
  description = var.newrelic_nrql_alert_condition_non_critical_response_time.description
  enabled     = var.newrelic_nrql_alert_condition_non_critical_response_time.enabled

  nrql {
    query = var.newrelic_nrql_alert_condition_non_critical_response_time.nrql.query
  }
  warning {
    operator              = var.newrelic_nrql_alert_condition_non_critical_response_time.warning.operator
    threshold             = var.newrelic_nrql_alert_condition_non_critical_response_time.warning.threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_non_critical_response_time.warning.threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_non_critical_response_time.warning.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_error_rate" {

  policy_id   = var.newrelic_nrql_alert_condition_non_critical_error_rate.policy_id
  name        = var.newrelic_nrql_alert_condition_non_critical_error_rate.name
  description = var.newrelic_nrql_alert_condition_non_critical_error_rate.description
  enabled     = var.newrelic_nrql_alert_condition_non_critical_error_rate.enabled

  nrql {
    query = var.newrelic_nrql_alert_condition_non_critical_error_rate.nrql.query
  }
  warning {
    operator              = var.newrelic_nrql_alert_condition_non_critical_error_rate.warning.operator
    threshold             = var.newrelic_nrql_alert_condition_non_critical_error_rate.warning.threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_non_critical_error_rate.warning.threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_non_critical_error_rate.warning.threshold_occurrences
  }
}

resource "newrelic_workflow" "non_critical_apm_response_time" {
  name                  = var.newrelic_workflow_non_critical_apm_response_time.name
  muting_rules_handling = var.newrelic_workflow_non_critical_apm_response_time.muting_rules_handling

  issues_filter {
    name = var.newrelic_workflow_non_critical_apm_response_time.issues_filter.name
    type = var.newrelic_workflow_non_critical_apm_response_time.issues_filter.type

    predicate {
      attribute = var.newrelic_workflow_non_critical_apm_response_time.predicate.attribute
      operator  = var.newrelic_workflow_non_critical_apm_response_time.predicate.operator
      values    = var.newrelic_workflow_non_critical_apm_response_time.predicate.values
    }
  }
  destination {
    channel_id            = var.newrelic_workflow_non_critical_apm_response_time.destination.channel_id
    notification_triggers = var.newrelic_workflow_non_critical_apm_response_time.destination.notification_triggers
  }
}

resource "newrelic_workflow" "non_critical_apm_error_rate" {
  name                  = var.newrelic_workflow_non_critical_apm_error_rate.name
  muting_rules_handling = var.newrelic_workflow_non_critical_apm_error_rate.muting_rules_handling

  issues_filter {
    name = var.newrelic_workflow_non_critical_apm_error_rate.issues_filter.name
    type = var.newrelic_workflow_non_critical_apm_error_rate.issues_filter.type

    predicate {
      attribute = var.newrelic_workflow_non_critical_apm_error_rate.predicate.attribute
      operator  = var.newrelic_workflow_non_critical_apm_error_rate.predicate.operator
      values    = var.newrelic_workflow_non_critical_apm_error_rate.predicate.values
    }
  }
  destination {
    channel_id            = var.newrelic_workflow_non_critical_apm_error_rate.destination.channel_id
    notification_triggers = var.newrelic_workflow_non_critical_apm_error_rate.destination.notification_triggers
  }
}

# Pagerduty resources

## Synthetic monitors

resource "pagerduty_service" "synthetics_newrelic" {
  name                    = var.pagerduty_service_synthetics_newrelic.name
  auto_resolve_timeout    = var.pagerduty_service_synthetics_newrelic.auto_resolve_timeout
  acknowledgement_timeout = var.pagerduty_service_synthetics_newrelic.acknowledgement_timeout
  escalation_policy       = var.pagerduty_service_synthetics_newrelic.escalation_policy
  alert_creation          = var.pagerduty_service_synthetics_newrelic.alert_creation

  incident_urgency_rule {
    type    = var.pagerduty_service_synthetics_newrelic.incident_urgency_rule.type
    urgency = var.pagerduty_service_synthetics_newrelic.incident_urgency_rule.urgency
  }
}

resource "pagerduty_service_integration" "synthetics_newrelic" {
  name    = var.pagerduty_service_integration_synthetics_newrelic.name
  service = var.pagerduty_service_integration_synthetics_newrelic.service
  vendor  = var.pagerduty_service_integration_synthetics_newrelic.vendor
}

resource "pagerduty_service" "critical" {

  name                    = var.pagerduty_service_critical.name
  auto_resolve_timeout    = var.pagerduty_service_critical.auto_resolve_timeout
  acknowledgement_timeout = var.pagerduty_service_critical.acknowledgement_timeout
  escalation_policy       = var.pagerduty_service_critical.escalation_policy
  alert_creation          = var.pagerduty_service_critical.alert_creation

  incident_urgency_rule {
    type    = var.pagerduty_service_critical.incident_urgency_rule.type
    urgency = var.pagerduty_service_critical.incident_urgency_rule.urgency
  }
}

resource "pagerduty_service" "non_critical" {
  name                    = var.pagerduty_service_non_critical.name
  auto_resolve_timeout    = var.pagerduty_service_non_critical.auto_resolve_timeout
  acknowledgement_timeout = var.pagerduty_service_non_critical.acknowledgement_timeout
  escalation_policy       = var.pagerduty_service_non_critical.escalation_policy
  alert_creation          = var.pagerduty_service_non_critical.alert_creation

  incident_urgency_rule {
    type    = var.pagerduty_service_non_critical.incident_urgency_rule.type
    urgency = var.pagerduty_service_non_critical.incident_urgency_rule.urgency
  }
}

resource "pagerduty_service_integration" "critical" {
  name    = var.pagerduty_service_integration_critical.name
  service = var.pagerduty_service_integration_critical.service
  vendor  = var.pagerduty_service_integration_critical.vendor
}

resource "pagerduty_service_integration" "non_critical" {
  name    = var.pagerduty_service_integration_non_critical.name
  service = var.pagerduty_service_integration_non_critical.service
  vendor  = var.pagerduty_service_integration_non_critical.vendor
}

resource "pagerduty_service_integration" "non_critical_events_API_v2" {
  name    = var.pagerduty_service_integration_non_critical_events_API_v2.name
  service = var.pagerduty_service_integration_non_critical_events_API_v2.service
  type    = var.pagerduty_service_integration_non_critical_events_API_v2.type
}
