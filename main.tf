locals {
  nr_entity_prefix = var.newrelic_resource_name_prefix != "" ? format("%s-", var.newrelic_resource_name_prefix) : ""
  nr_entity_suffix = var.newrelic_resource_name_suffix != "" ? format("-%s", var.newrelic_resource_name_suffix) : ""

  all_monitors = merge(var.simple_monitors, var.browser_monitors, var.script_monitors, var.step_monitors, var.broken_links_monitors, var.cert_check_monitors)

  all_monitor_resources = merge(newrelic_synthetics_monitor.simple, newrelic_synthetics_monitor.browser, newrelic_synthetics_script_monitor.script, newrelic_synthetics_step_monitor.step, newrelic_synthetics_broken_links_monitor.broken_links, newrelic_synthetics_cert_check_monitor.cert_check)

  # constructs the name string for each monitor in a single location to avoid repetition.
  prefix_suffix_map         = { for key, _ in local.all_monitors : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }
  apm_prefix_suffix_map     = { for key, _ in var.newrelic_apm_entities : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }
  browser_prefix_suffix_map = { for key, _ in var.newrelic_apm_entities : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }
}

data "newrelic_entity" "apm_entities" {
  for_each = var.newrelic_apm_entities

  name   = local.apm_prefix_suffix_map[each.key]
  domain = "APM"
  type   = "APPLICATION"
}

data "newrelic_entity" "browser_entities" {
  for_each = var.newrelic_browser_entities

  name   = local.browser_prefix_suffix_map[each.key]
  domain = "BROWSER"
  type   = "APPLICATION"
}

data "pagerduty_vendor" "vendor" {
  for_each = toset(var.pagerduty_vendors)
  name     = each.key
}

data "pagerduty_escalation_policy" "ep" {
  name = var.pagerduty_escalation_policy
}

##########################

# Synthetics monitors

##########################

# Ping Monitor
resource "newrelic_synthetics_monitor" "simple" {
  for_each = var.simple_monitors

  name                = local.prefix_suffix_map[each.key]
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

# Browser Monitor
resource "newrelic_synthetics_monitor" "browser" {
  for_each = var.browser_monitors

  name                 = "Browser-${local.prefix_suffix_map[each.key]}"
  type                 = each.value["type"]
  period               = each.value["period"]
  status               = each.value["status"]
  locations_public     = each.value["locations_public"]
  uri                  = each.value["uri"]
  validation_string    = each.value["validation_string"]
  runtime_type         = each.value["runtime_type"]
  runtime_type_version = each.value["runtime_type_version"]
  script_language      = each.value["script_language"]
  devices              = each.value["devices"]
  browsers             = each.value["browsers"]
  dynamic "custom_header" {
    for_each = each.value["custom_header"] != null ? each.value["custom_header"] : []
    content {
      name  = custom_header.value["name"]
      value = custom_header.value["value"]
    }
  }
}

# Script Monitor
resource "newrelic_synthetics_script_monitor" "script" {
  for_each = var.script_monitors

  name                                    = local.prefix_suffix_map[each.key]
  type                                    = each.value["type"]
  period                                  = each.value["period"]
  status                                  = each.value["status"]
  locations_public                        = each.value["locations_public"]
  runtime_type                            = lookup(each.value, "type") == "SCRIPT_API" ? each.value["runtime_type"] : "CHROME_BROWSER"
  runtime_type_version                    = lookup(each.value, "type") == "SCRIPT_API" ? each.value["runtime_type_version"] : "100"
  script_language                         = each.value["script_language"]
  script                                  = each.value["script"]
  enable_screenshot_on_failure_and_script = lookup(each.value, "type") == "SCRIPT_BROWSER" ? each.value["enable_screenshot_on_failure_and_script"] : null
  devices                                 = lookup(each.value, "type") == "SCRIPT_BROWSER" ? each.value["devices"] : null
  browsers                                = lookup(each.value, "type") == "SCRIPT_BROWSER" ? each.value["browsers"] : null
}

# Step Monitors
resource "newrelic_synthetics_step_monitor" "step" {
  for_each = var.step_monitors

  name                                    = local.prefix_suffix_map[each.key]
  enable_screenshot_on_failure_and_script = each.value["enable_screenshot_on_failure_and_script"]
  locations_public                        = each.value["locations_public"]
  period                                  = each.value["period"]
  status                                  = each.value["status"]
  runtime_type                            = each.value["runtime_type"]
  runtime_type_version                    = each.value["runtime_type_version"]
  devices                                 = each.value["devices"]
  browsers                                = each.value["browsers"]
  dynamic "steps" {
    for_each = each.value["steps"]
    content {
      ordinal = steps.value["ordinal"]
      type    = steps.value["type"]
      values  = steps.value["values"]
    }
  }
}

# Broken links monitors
resource "newrelic_synthetics_broken_links_monitor" "broken_links" {
  for_each = var.broken_links_monitors

  name                 = local.prefix_suffix_map[each.key]
  uri                  = each.value["uri"]
  locations_public     = each.value["locations_public"]
  period               = each.value["period"]
  status               = each.value["status"]
  runtime_type         = each.value["runtime_type"]
  runtime_type_version = each.value["runtime_type_version"]
}

# Certificate check monitors
resource "newrelic_synthetics_cert_check_monitor" "cert_check" {
  for_each = var.cert_check_monitors

  name                   = local.prefix_suffix_map[each.key]
  domain                 = each.value["domain"]
  locations_public       = each.value["locations_public"]
  certificate_expiration = each.value["certificate_expiration"]
  period                 = each.value["period"]
  status                 = each.value["status"]
  runtime_type           = each.value["runtime_type"]
  runtime_type_version   = each.value["runtime_type_version"]
}

##########
resource "newrelic_alert_policy" "synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name                = "${local.prefix_suffix_map[each.key]}-synthetics"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_destination" "synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name = pagerduty_service.synthetics_newrelic[each.key].name
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
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name           = local.prefix_suffix_map[each.key]
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.synthetics[each.key].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "Monitor endpoints ${local.prefix_suffix_map[each.key]} failling in 1-3 locations"
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
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name                  = "Monitor-${local.prefix_suffix_map[each.key]}-health"
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


# Critical health alert condition
resource "newrelic_nrql_alert_condition" "critical_health_synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_critical_monitor }

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.prefix_suffix_map[each.key]}-Critical-monitor-health"
  description = "critical-alert"
  enabled     = true

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck where entityGuid IN ('${local.all_monitor_resources[each.key].id}') FACET monitorName"
  }
  critical {
    operator              = each.value["critical_synthetics_operator"]
    threshold             = each.value["critical_synthetics_threshold"]
    threshold_duration    = each.value["critical_synthetics_threshold_duration"]
    threshold_occurrences = each.value["critical_synthetics_threshold_occurrences"]
  }
  expiration_duration            = each.value["critical_synthetics_expiration_duration"]
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = each.value["critical_synthetics_aggregation_window"]
}

# Critical duration alert condition
resource "newrelic_nrql_alert_condition" "critical_duration_synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_critical_duration_monitor }

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.prefix_suffix_map[each.key]}-Critical-monitor-duration"
  description = "critical-alert"
  enabled     = true

  nrql {
    query = "SELECT percentile(duration, 50) / 1000 FROM SyntheticCheck WHERE entityGuid IN ('${local.all_monitor_resources[each.key].id}') FACET monitorName"
  }
  critical {
    operator              = each.value["critical_duration_synthetics_operator"]
    threshold             = each.value["critical_duration_synthetics_threshold"]
    threshold_duration    = each.value["critical_duration_synthetics_threshold_duration"]
    threshold_occurrences = each.value["critical_duration_synthetics_threshold_occurrences"]
  }
  expiration_duration            = each.value["critical_duration_synthetics_expiration_duration"]
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = each.value["critical_duration_synthetics_aggregation_window"]
}

##########################

# Non-Critical Synthetics monitors

##########################

# Non critical health alert condition
resource "newrelic_nrql_alert_condition" "noncritical_health_synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor }

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.prefix_suffix_map[each.key]}-Non-Critical-monitor-health"
  description = "non-critical-alert"
  enabled     = true

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${local.all_monitor_resources[each.key].id}') FACET monitorName"
  }
  warning {
    operator              = each.value["non_critical_synthetics_operator"]
    threshold             = each.value["non_critical_synthetics_threshold"]
    threshold_duration    = each.value["non_critical_synthetics_threshold_duration"]
    threshold_occurrences = each.value["non_critical_synthetics_threshold_occurrences"]
  }
  expiration_duration            = each.value["non_critical_synthetics_expiration_duration"]
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = each.value["non_critical_synthetics_aggregation_window"]
}

# Non critical duration alert
resource "newrelic_nrql_alert_condition" "non_critical_duration_synthetics" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_duration_monitor }

  policy_id   = newrelic_alert_policy.synthetics[each.key].id
  name        = "${local.prefix_suffix_map[each.key]}-Non-Critical-monitor-duration"
  description = "non-critical-alert"
  enabled     = true

  nrql {
    query = "SELECT percentile(duration, 50) / 1000 FROM SyntheticCheck WHERE entityGuid IN ('${local.all_monitor_resources[each.key].id}') FACET monitorName"

  }
  warning {
    operator              = each.value["non_critical_duration_synthetics_operator"]
    threshold             = each.value["non_critical_duration_synthetics_threshold"]
    threshold_duration    = each.value["non_critical_duration_synthetics_threshold_duration"]
    threshold_occurrences = each.value["non_critical_duration_synthetics_threshold_occurrences"]
  }
  expiration_duration            = each.value["non_critical_duration_synthetics_expiration_duration"]
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  aggregation_window             = each.value["non_critical_duration_synthetics_aggregation_window"]
}

##########################

# Pagerduty Synthetics resources

##########################

resource "pagerduty_service" "synthetics_newrelic" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name                    = "NewRelic-synthetics-${local.prefix_suffix_map[each.key]}"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = 600
  escalation_policy       = data.pagerduty_escalation_policy.ep.id
  alert_creation          = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = lookup(each.value, "create_critical_monitor", false) ? "high" : "low"
  }
}

resource "pagerduty_service_integration" "synthetics_newrelic" {
  for_each = { for key, value in local.all_monitors : key => value if value.create_non_critical_monitor || value.create_critical_monitor }

  name    = data.pagerduty_vendor.vendor["New Relic"].name
  service = pagerduty_service.synthetics_newrelic[each.key].id
  vendor  = data.pagerduty_vendor.vendor["New Relic"].id
}

##########################

# Critical APM Resources

##########################

resource "newrelic_alert_policy" "critical_apm_response_time" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name                = "APM-${local.apm_prefix_suffix_map[each.key]}-response-time-Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "critical_apm_error_rate" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name                = "APM-${local.apm_prefix_suffix_map[each.key]}-error-rate-Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_destination" "critical_apm" {
  # we create only one
  count = length({ for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }) > 0 ? 1 : 0

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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name           = "APM-${local.apm_prefix_suffix_map[each.key]}-response-time-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.apm_entities[each.key].name} ${newrelic_nrql_alert_condition.critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.critical_response_time[each.key].critical[0].threshold} seconds"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name           = "APM-${local.apm_prefix_suffix_map[each.key]}-error-rate-Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_apm[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.apm_entities[each.key].name} ${newrelic_nrql_alert_condition.critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.critical_error_rate[each.key].critical[0].threshold}%"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  policy_id   = newrelic_alert_policy.critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.apm_entities[each.key].name}-Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where entityGuid IN ('${data.newrelic_entity.apm_entities[each.key].guid}') FACET appName"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = each.value["critical_response_time"]
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "critical_error_rate" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  policy_id   = newrelic_alert_policy.critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.apm_entities[each.key].name}-Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT (sum(apm.service.error.count['count']) / count(apm.service.transaction.duration)) * 100 AS 'All errors' FROM Metric WHERE entityGuid IN ('${data.newrelic_entity.apm_entities[each.key].guid}') FACET appName"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = each.value["critical_error_rate"]
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "critical_apm_response_time" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.apm_entities[each.key].name}-Critical-response-time"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.apm_entities[each.key].name}-Critical-error-rate"
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
  count = length({ for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }) > 0 ? 1 : 0

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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name                = "APM-${local.apm_prefix_suffix_map[each.key]}-response-time-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_alert_policy" "non_critical_apm_error_rate" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name                = "APM-${local.apm_prefix_suffix_map[each.key]}-error-rate-Non_Critical"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_channel" "non_critical_apm_response_time" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name           = "APM-${local.apm_prefix_suffix_map[each.key]}-response-time-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.apm_entities[each.key].name} ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_response_time[each.key].warning[0].threshold} seconds"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name           = "APM-${local.apm_prefix_suffix_map[each.key]}-error-rate-Non_Critical"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_apm[0].id
  product        = "IINT"
  property {
    key   = "summary"
    value = "APM Service ${data.newrelic_entity.apm_entities[each.key].name} ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_error_rate[each.key].warning[0].threshold}%"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  policy_id   = newrelic_alert_policy.non_critical_apm_response_time[each.key].id
  name        = "${data.newrelic_entity.apm_entities[each.key].name}-Non_Critical-response-time"
  description = "response-time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM Transaction where entityGuid IN ('${data.newrelic_entity.apm_entities[each.key].guid}') FACET appName"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = each.value["non_critical_response_time"]
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_error_rate" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  policy_id   = newrelic_alert_policy.non_critical_apm_error_rate[each.key].id
  name        = "${data.newrelic_entity.apm_entities[each.key].name}-Non_Critical-error-rate"
  description = "error-rate"
  enabled     = true

  nrql {
    query = "SELECT (sum(apm.service.error.count['count']) / count(apm.service.transaction.duration)) * 100 AS 'All errors' FROM Metric WHERE entityGuid IN ('${data.newrelic_entity.apm_entities[each.key].guid}') FACET appName"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = each.value["non_critical_error_rate"]
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "non_critical_apm_response_time" {
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.apm_entities[each.key].name}-Non_Critical-response-time"
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
  for_each = { for key, value in var.newrelic_apm_entities : key => value if value.create_non_critical_apm_resources }

  name                  = "APM-${data.newrelic_entity.apm_entities[each.key].name}-Non_Critical-error-rate"
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

# Non Critical Browser Alerts

##########################

resource "newrelic_notification_destination" "non_critical_browser" {
  count = length({ for key, value in var.newrelic_browser_entities : key => value if value.create_non_critical_browser_alert }) > 0 ? 1 : 0

  name = "${pagerduty_service.non_critical["NewRelic"].name}-Browser"
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

resource "newrelic_alert_policy" "non_critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_non_critical_browser_alert }

  name                = "Browser-${local.browser_prefix_suffix_map[each.key]}-Non-Critical-Pageload"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_channel" "non_critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_non_critical_browser_alert }

  name           = "Browser-${local.browser_prefix_suffix_map[each.key]}-Non-Critical-Pageload"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.non_critical_browser[0].id
  product        = "IINT"
  property {
    key   = "summary"
    value = "Browser Service ${data.newrelic_entity.browser_entities[each.key].name} ${newrelic_nrql_alert_condition.non_critical_browser_pageload[each.key].description} > ${newrelic_nrql_alert_condition.non_critical_browser_pageload[each.key].warning[0].threshold}seconds"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.non_critical_browser_pageload[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.non_critical["NewRelic"].integration_key
  }
}

resource "newrelic_nrql_alert_condition" "non_critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_non_critical_browser_alert }

  policy_id   = newrelic_alert_policy.non_critical_browser_pageload[each.key].id
  name        = data.newrelic_entity.browser_entities[each.key].name
  description = "average pageload time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM PageView WHERE entityGuid IN ('${data.newrelic_entity.browser_entities[each.key].guid}') FACET appName"
  }
  warning {
    operator              = "above_or_equals"
    threshold             = each.value["non_critical_browser_pageload"]
    threshold_duration    = 900
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "non_critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_non_critical_browser_alert }

  name                  = "${data.newrelic_entity.browser_entities[each.key].name}-Non-Critical-Browser-Pageload"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.non_critical_browser_pageload[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.non_critical_browser_pageload[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

##########################

# Critical Browser Alerts

##########################

resource "newrelic_notification_destination" "critical_browser" {
  count = length({ for key, value in var.newrelic_browser_entities : key => value if value.create_critical_browser_alert }) > 0 ? 1 : 0

  name = "${pagerduty_service.critical["NewRelic"].name}-Browser"
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

resource "newrelic_alert_policy" "critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_critical_browser_alert }

  name                = "Browser-${local.browser_prefix_suffix_map[each.key]}-Critical-Pageload"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_notification_channel" "critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_critical_browser_alert }

  name           = "Browser-${local.browser_prefix_suffix_map[each.key]}-Critical-Pageload"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.critical_browser[0].id
  product        = "IINT"
  property {
    key   = "summary"
    value = "Browser Service ${data.newrelic_entity.browser_entities[each.key].name} ${newrelic_nrql_alert_condition.critical_browser_pageload[each.key].description} > ${newrelic_nrql_alert_condition.critical_browser_pageload[each.key].critical[0].threshold}seconds"
  }
  property {
    key   = "policy_id"
    value = newrelic_alert_policy.critical_browser_pageload[each.key].id
  }
  property {
    key   = "service_key"
    value = pagerduty_service_integration.critical["NewRelic"].integration_key
  }
}

resource "newrelic_nrql_alert_condition" "critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_critical_browser_alert }

  policy_id   = newrelic_alert_policy.critical_browser_pageload[each.key].id
  name        = "${data.newrelic_entity.browser_entities[each.key].name}-Critical-Browser-Pageload"
  description = "average pageload time"
  enabled     = true

  nrql {
    query = "SELECT average(duration) FROM PageView WHERE entityGuid IN ('${data.newrelic_entity.browser_entities[each.key].guid}') FACET appName"
  }
  critical {
    operator              = "above_or_equals"
    threshold             = each.value["critical_browser_pageload"]
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_workflow" "critical_browser_pageload" {
  for_each = { for key, value in var.newrelic_browser_entities : key => value if value.create_critical_browser_alert }

  name                  = "${data.newrelic_entity.browser_entities[each.key].name}-Critical-Browser-Pageload"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "workflow-filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.critical_browser_pageload[each.key].id]
    }
  }
  destination {
    channel_id            = newrelic_notification_channel.critical_browser_pageload[each.key].id
    notification_triggers = ["ACTIVATED", "CLOSED"]
  }
}

##########################

# Pagerduty Resources

##########################


resource "pagerduty_service" "critical" {

  for_each = {
    for key, value in var.pagerduty_services : key => value
    if lookup(value, "critical", false)
  }

  name                    = "${local.nr_entity_prefix}${each.key}${local.nr_entity_suffix}-Critical"
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
    for key, value in var.pagerduty_services : key => value
    if lookup(value, "critical", false) && !lookup(value, "api", false)
  }

  name    = data.pagerduty_vendor.vendor[each.value.vendor].name
  service = pagerduty_service.critical[each.key].id
  vendor  = data.pagerduty_vendor.vendor[each.value.vendor].id
}

resource "pagerduty_service" "non_critical" {

  for_each = {
    for key, value in var.pagerduty_services : key => value
    if lookup(value, "non_critical", false)
  }

  name                    = "${local.nr_entity_prefix}${each.key}${local.nr_entity_suffix}-Non_Critical"
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
    for key, value in var.pagerduty_services : key => value
    if lookup(value, "non_critical", false) && !lookup(value, "api", false)
  }

  name    = data.pagerduty_vendor.vendor[each.value.vendor].name
  service = pagerduty_service.non_critical[each.key].id
  vendor  = data.pagerduty_vendor.vendor[each.value.vendor].id
}

resource "pagerduty_service_integration" "non_critical_events_API_v2" {

  for_each = {
    for key, value in var.pagerduty_services : key => value
    if lookup(value, "non_critical", false) && lookup(value, "api", false)
  }

  name    = "Events API V2"
  service = pagerduty_service.non_critical[each.key].id
  type    = "events_api_v2_inbound_integration"
}
