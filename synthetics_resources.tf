resource "newrelic_synthetics_monitor" "all" {
  for_each            = var.monitor_name_uri
  name                = "${local.nr_entity_prefix}${each.key}"
  type                = var.monitor_type
  period              = var.monitor_period
  status              = var.monitor_status
  locations_public    = var.monitor_locations_public
  uri                 = each.value["uri"]
  validation_string   = var.monitor_validation_string
  verify_ssl          = var.monitor_verify_ssl
  bypass_head_request = var.monitor_bypass_head_request
}

resource "newrelic_alert_policy" "synthetics" {
  for_each            = var.monitor_name_uri
  name                = "${local.nr_entity_prefix}${each.key}-synthetics"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_destination" "synthetics" {
  for_each = var.monitor_name_uri

  name = "${pagerduty_service.synthetics_newrelic[each.key].name}-synthetics"
  type = "PAGERDUTY_SERVICE_INTEGRATION"

  property {
    key   = ""
    value = ""
  }
  auth_token {
    prefix = "service-integration-id"
    token  = pagerduty_service_integration.synthetics_newrelic[each.key].integration_key
  }
}

resource "newrelic_notification_channel" "synthetics" {
  for_each = var.monitor_name_uri

  name           = "${local.nr_entity_prefix}${each.key}"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.synthetics[each.key].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "Monitor endpoints ${newrelic_synthetics_monitor.all[each.key].name} failling in 1-3 locations"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.synthetics[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.synthetics_newrelic[each.key].integration_key
  }
}

resource "newrelic_workflow" "this" {
  for_each              = var.monitor_name_uri
  name                  = "Monitor-${local.nr_entity_prefix}${each.key}-health"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"
  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.synthetics[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.synthetics[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

resource "newrelic_nrql_alert_condition" "critical_health_synthetics" {
  for_each = var.create_critical_resources == true ? var.monitor_name_uri : {}

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.nr_entity_prefix}${each.key}-Critical-monitor-health"
  description = "critical-alert"
  enabled     = true

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.all[each.key].id}') FACET monitorName"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = 3
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = 300
}

resource "newrelic_nrql_alert_condition" "noncritical_health_synthetics" {
  for_each = var.monitor_name_uri

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.nr_entity_prefix}${each.key}-Non-Critical-monitor-health"
  description = "non-critical-alert"
  enabled     = true

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.all[each.key].id}') FACET monitorName"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = 1
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
  expiration_duration            = 600
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = 300
}


resource "pagerduty_service" "synthetics_newrelic" {
  for_each = var.monitor_name_uri

  name                    = "NewRelic-${local.nr_entity_prefix}synthetics-${each.key}"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = 600
  escalation_policy       = data.pagerduty_escalation_policy.ep.id
  alert_creation          = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "synthetics_newrelic" {
  for_each = var.monitor_name_uri

  name    = data.pagerduty_vendor.vendor["New Relic"].name
  service = pagerduty_service.synthetics_newrelic[each.key].id
  vendor  = data.pagerduty_vendor.vendor["New Relic"].id
}
