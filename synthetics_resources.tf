resource "newrelic_synthetics_monitor" "all" {
  for_each            = var.monitor_name_uri
  name                = "${local.nr_entity_prefix}${each.key}-synthetics"
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
    name = var.newrelic_workflow_synthetics_issues_filter[0].name
    type = var.newrelic_workflow_synthetics_issues_filter[0].type
    # name and type are required but not really relevant:
    # https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow#type

    predicate {
      attribute = var.newrelic_workflow_synthetics_issues_filter[0].predicate[0].attribute
      operator  = var.newrelic_workflow_synthetics_issues_filter[0].predicate[0].operator
      values    = [newrelic_alert_policy.synthetics[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.synthetics[each.key].id
    notification_triggers = var.newrelic_workflow_synthetics_destination[0].notification_triggers
  }
}

resource "newrelic_nrql_alert_condition" "critical_health_synthetics" {
  for_each = var.monitor_name_uri

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.nr_entity_prefix}${each.key}-Critical-monitor-health"
  description = var.newrelic_nrql_alert_condition_critical_synthetics_description
  enabled     = var.newrelic_nrql_alert_condition_critical_synthetics_enabled

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.all[each.key].id}') FACET monitorName"
  }
  critical {
    operator              = var.newrelic_nrql_alert_condition_critical_synthetics_critical[0].operator
    threshold             = var.newrelic_nrql_alert_condition_critical_synthetics_critical[0].threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_critical_synthetics_critical[0].threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_critical_synthetics_critical[0].threshold_occurrences
  }
  expiration_duration            = var.newrelic_nrql_alert_condition_synthetics_expiration_duration
  open_violation_on_expiration   = var.newrelic_nrql_alert_condition_synthetics_open_violation_on_expiration
  close_violations_on_expiration = var.newrelic_nrql_alert_condition_synthetics_close_violations_on_expiration
  aggregation_window             = var.newrelic_nrql_alert_condition_synthetics_aggregation_window
}

resource "newrelic_nrql_alert_condition" "noncritical_health_synthetics" {
  for_each = var.monitor_name_uri

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.nr_entity_prefix}${each.key}-Non-Critical-monitor-health"
  description = var.newrelic_nrql_alert_condition_noncritical_synthetics_description
  enabled     = var.newrelic_nrql_alert_condition_noncritical_synthetics_enabled

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.all[each.key].id}') FACET monitorName"
  }
  warning {
    operator              = var.newrelic_nrql_alert_condition_noncritical_synthetics_noncritical[0].operator
    threshold             = var.newrelic_nrql_alert_condition_noncritical_synthetics_noncritical[0].threshold
    threshold_duration    = var.newrelic_nrql_alert_condition_noncritical_synthetics_noncritical[0].threshold_duration
    threshold_occurrences = var.newrelic_nrql_alert_condition_noncritical_synthetics_noncritical[0].threshold_occurrences
  }
  expiration_duration            = var.newrelic_nrql_alert_condition_synthetics_expiration_duration
  open_violation_on_expiration   = var.newrelic_nrql_alert_condition_synthetics_open_violation_on_expiration
  close_violations_on_expiration = var.newrelic_nrql_alert_condition_synthetics_close_violations_on_expiration
  aggregation_window             = var.newrelic_nrql_alert_condition_synthetics_aggregation_window
}


resource "pagerduty_service" "synthetics_newrelic" {
  for_each = var.monitor_name_uri

  name                    = "NewRelic-${local.nr_entity_prefix}synthetics-${each.key}"
  auto_resolve_timeout    = var.pagerduty_service_synthetics_auto_resolve_timeout
  acknowledgement_timeout = var.pagerduty_service_synthetics_acknowledgement_timeout
  escalation_policy       = data.pagerduty_escalation_policy.slack.id
  alert_creation          = var.pagerduty_service_synthetics_alert_creation_type

  incident_urgency_rule {
    type    = var.pagerduty_service_synthetics_incident_urgency_rule[0].type
    urgency = var.pagerduty_service_synthetics_incident_urgency_rule[0].urgency
  }
}

resource "pagerduty_service_integration" "synthetics_newrelic" {
  for_each = var.monitor_name_uri

  name    = data.pagerduty_vendor.vendor["New Relic"].name
  service = pagerduty_service.synthetics_newrelic[each.key].id
  vendor  = data.pagerduty_vendor.vendor["New Relic"].id
}
