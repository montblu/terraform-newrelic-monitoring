locals {
  nr_entity_prefix = var.newrelic_resource_name_prefix != "" ? format("%s-", var.newrelic_resource_name_prefix) : ""
  nr_entity_suffix = var.newrelic_resource_name_suffix != "" ? format("-%s", var.newrelic_resource_name_suffix) : ""

  pagerduty_services = {
    "NewRelic"     = { critical = true, non_critical = true, vendor = "New Relic" },
    "Alertmanager" = { critical = true, non_critical = true, vendor = "Prometheus" },
    "OpenSearch"   = { non_critical = true, api = true }
  }

  pagerduty_vendors = [
    "New Relic",
    "Prometheus"
  ]
}

data "newrelic_entity" "this" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources || value.create_critical_apm_resources }

  name   = "${local.nr_entity_prefix}${each.key}${local.nr_entity_suffix}"
  domain = var.newrelic_entity_domain
  type   = var.newrelic_entity_type
}
data "pagerduty_vendor" "vendor" {
  for_each = toset(local.pagerduty_vendors)
  name     = each.key
}

data "pagerduty_escalation_policy" "ep" {
  name = var.pagerduty_escalation_policy
}

##########################

# Synthetics monitors

##########################

resource "newrelic_synthetics_monitor" "all" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name                = "${local.nr_entity_prefix}${each.key}"
  type                = each.value["type"]
  period              = each.value["period"]
  status              = each.value["status"]
  locations_public    = each.value["locations_public"]
  uri                 = each.value["uri"]
  validation_string   = each.value["validation_string"]
  verify_ssl          = each.value["verify_ssl"]
  bypass_head_request = each.value["bypass_head_request"]
  dynamic "custom_header" {
    for_each = each.value["custom_header"] != null ? each.value["custom_header"] : []
    content {
      name  = custom_header.value["name"]
      value = custom_header.value["value"]
    }
  }
}

resource "newrelic_alert_policy" "synthetics" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name                = "${local.nr_entity_prefix}${each.key}-synthetics"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_destination" "synthetics" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

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
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

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
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

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

##########################

# Critical Synthetics monitors

##########################

resource "newrelic_nrql_alert_condition" "critical_health_synthetics" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_monitor }

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

##########################

# Non-Critical Synthetics monitors

##########################

resource "newrelic_nrql_alert_condition" "noncritical_health_synthetics" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor }

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

##########################

# Pagerduty Synthetics resources

##########################

resource "pagerduty_service" "synthetics_newrelic" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

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
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name    = data.pagerduty_vendor.vendor["New Relic"].name
  service = pagerduty_service.synthetics_newrelic[each.key].id
  vendor  = data.pagerduty_vendor.vendor["New Relic"].id
}

##########################

# Critical APM Resources

##########################

resource "newrelic_alert_policy" "critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name                = "APM-${local.nr_entity_prefix}${each.key}-response-time-Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name                = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_destination" "critical_apm" {
  name = "${pagerduty_service.critical["NewRelic"].name}-APM"
  type = "PAGERDUTY_SERVICE_INTEGRATION"

  property {
    key   = ""
    value = ""
  }
  auth_token {
    prefix = "service-integration-id"
    token  = pagerduty_service_integration.critical["NewRelic"].integration_key
  }
}

resource "newrelic_notification_channel" "critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name           = "APM-${local.nr_entity_prefix}${each.key}-response-time-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.critical_response_time[each.key].critical[0].threshold} seconds"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.critical_apm_response_time[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.critical["NewRelic"].integration_key
  }
}

resource "newrelic_notification_channel" "critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name           = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.critical_error_rate[each.key].critical[0].threshold}%"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.critical_apm_error_rate[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.critical["NewRelic"].integration_key
  }
}

resource "newrelic_nrql_alert_condition" "critical_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  policy_id   = newrelic_alert_policy.critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where appName = '${data.newrelic_entity.this[each.key].name}'"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = each.value["critical_response_time"]
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "critical_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  policy_id   = newrelic_alert_policy.critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT sum(apm.service.error.count['count']) / count(apm.service.transaction.duration) AS 'All errors' FROM Metric WHERE (appName = '${data.newrelic_entity.this[each.key].name}')"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = each.value["critical_error_rate"]
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.this[each.key].name}-Critical-response-time"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.critical_apm_response_time[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.critical_apm_response_time[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

resource "newrelic_workflow" "critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.this[each.key].name}-Critical-error-rate"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.critical_apm_error_rate[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.critical_apm_error_rate[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

##########################

# Non-critical APM Resources

##########################


resource "newrelic_notification_destination" "non_critical_apm" {
  name = "${pagerduty_service.non_critical["NewRelic"].name}-APM"
  type = "PAGERDUTY_SERVICE_INTEGRATION"

  property {
    key   = ""
    value = ""
  }
  auth_token {
    prefix = "service-integration-id"
    token  = pagerduty_service_integration.non_critical["NewRelic"].integration_key
  }
}

resource "newrelic_alert_policy" "non_critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name                = "APM-${local.nr_entity_prefix}${each.key}-response-time-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "non_critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name                = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_channel" "non_critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name           = "APM-${local.nr_entity_prefix}${each.key}-response-time-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].warning[0].threshold} seconds"
  }

  property {
    key   = "policy_id"
    value = newrelic_alert_policy.non_critical_apm_response_time[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.non_critical["NewRelic"].integration_key
  }
}

resource "newrelic_notification_channel" "non_critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name           = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm.id
  product        = "IINT"
  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].warning[0].threshold}%"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.non_critical_apm_error_rate[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.non_critical["NewRelic"].integration_key
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  policy_id   = newrelic_alert_policy.non_critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Non_Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where appName = '${data.newrelic_entity.this[each.key].name}'"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = each.value["non_critical_response_time"]
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  policy_id   = newrelic_alert_policy.non_critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Non_Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT sum(apm.service.error.count['count']) / count(apm.service.transaction.duration) AS 'All errors' FROM Metric WHERE (appName = '${data.newrelic_entity.this[each.key].name}')"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = each.value["non_critical_error_rate"]
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "non_critical_apm_response_time" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.this[each.key].name}-Non_Critical-response-time"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.non_critical_apm_response_time[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.non_critical_apm_response_time[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

resource "newrelic_workflow" "non_critical_apm_error_rate" {
  for_each = { for key, value in var.monitor_name_uri : key => value if value.create_non_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.this[each.key].name}-Non_Critical-error-rate"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.non_critical_apm_error_rate[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.non_critical_apm_error_rate[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

##########################

# Pagerduty Resources

##########################


resource "pagerduty_service" "critical" {

  for_each = {
    for key, value in local.pagerduty_services : key => value
    if lookup(value, "critical", false)
  }

  name                    = "${local.nr_entity_prefix}${each.key}-Critical"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = 600
  escalation_policy       = data.pagerduty_escalation_policy.ep.id
  alert_creation          = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "critical" {

  for_each = {
    for key, value in local.pagerduty_services : key => value
    if lookup(value, "critical", false) && !lookup(value, "api", false)
  }

  name    = data.pagerduty_vendor.vendor[each.value.vendor].name
  service = pagerduty_service.critical[each.key].id
  vendor  = data.pagerduty_vendor.vendor[each.value.vendor].id
}

resource "pagerduty_service" "non_critical" {

  for_each = {
    for key, value in local.pagerduty_services : key => value
    if lookup(value, "non_critical", false)
  }

  name                    = "${local.nr_entity_prefix}${each.key}-Non_Critical"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = 600
  escalation_policy       = data.pagerduty_escalation_policy.ep.id
  alert_creation          = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "low"
  }
}

resource "pagerduty_service_integration" "non_critical" {

  for_each = {
    for key, value in local.pagerduty_services : key => value
    if lookup(value, "non_critical", false) && !lookup(value, "api", false)
  }

  name    = data.pagerduty_vendor.vendor[each.value.vendor].name
  service = pagerduty_service.non_critical[each.key].id
  vendor  = data.pagerduty_vendor.vendor[each.value.vendor].id
}

resource "pagerduty_service_integration" "non_critical_events_API_v2" {

  for_each = {
    for key, value in local.pagerduty_services : key => value
    if lookup(value, "non_critical", false) && lookup(value, "api", false)
  }

  name    = "Events API V2"
  service = pagerduty_service.non_critical[each.key].id
  type    = "events_api_v2_inbound_integration"
}
