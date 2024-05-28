resource "newrelic_alert_policy" "critical_apm_response_time" {
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

  name                = "APM-${local.nr_entity_prefix}${each.key}-response-time-Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "critical_apm_error_rate" {
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

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
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

  name           = "APM-${local.nr_entity_prefix}${each.key}-response-time-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.critical_response_time[each.key].critical.threshold} seconds"
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
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

  name           = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.critical_error_rate[each.key].critical.threshold}%"
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
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

  policy_id   = newrelic_alert_policy.critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where appName = '${data.newrelic_entity.this[each.key].name}'"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = 0.7
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "critical_error_rate" {
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

  policy_id   = newrelic_alert_policy.critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT sum(apm.service.error.count['count']) / count(apm.service.transaction.duration) AS 'All errors' FROM Metric WHERE (appName = '${data.newrelic_entity.this[each.key].name}')"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = 15
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "critical_apm_response_time" {
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

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
  for_each = var.create_apm_resources == true && var.create_critical_resources == true ? var.monitor_name_uri : {}

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
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

  name                = "APM-${local.nr_entity_prefix}${each.key}-response-time-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "non_critical_apm_error_rate" {
  for_each            = var.create_apm_resources == true ? var.monitor_name_uri : {}
  name                = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_channel" "non_critical_apm_response_time" {
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

  name           = "APM-${local.nr_entity_prefix}${each.key}-response-time-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].warning.threshold} seconds"
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
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

  name           = "APM-${local.nr_entity_prefix}${each.key}-error-rate-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm.id
  product        = "IINT"
  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.this[each.key].name} ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].warning.threshold}%"
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
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

  policy_id   = newrelic_alert_policy.non_critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Non_Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where appName = '${data.newrelic_entity.this[each.key].name}'"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = 0.5
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_error_rate" {
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

  policy_id   = newrelic_alert_policy.non_critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.this[each.key].name}-Non_Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT sum(apm.service.error.count['count']) / count(apm.service.transaction.duration) AS 'All errors' FROM Metric WHERE (appName = '${data.newrelic_entity.this[each.key].name}')"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = 7
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "non_critical_apm_response_time" {
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

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
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

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
