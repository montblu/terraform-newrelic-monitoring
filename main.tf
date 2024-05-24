resource "newrelic_synthetics_monitor" "all" {
  for_each            = { for monitor in var.synthetic_monitors : monitor.name => monitor }
  name                = each.value.name
  type                = each.value.type
  period              = each.value.period
  status              = each.value.status
  locations_public    = each.value.locations_public
  uri                 = each.value.uri
  validation_string   = each.value.validation_string
  verify_ssl          = each.value.verify_ssl
  bypass_head_request = each.value.bypass_head_request
}

resource "newrelic_alert_policy" "this" {
  for_each = { for policy in var.newrelic_alert_policy : policy.name => policy }

  name                = each.value.name
  incident_preference = each.value.incident_preference
}

resource "newrelic_notification_destination" "this" {
  for_each = { for destination in var.newrelic_notification_destination : destination.name => destination }

  name = each.value.name
  type = each.value.type

  property {
    key   = each.value.property[0].key
    value = each.value.property[0].value
  }
  auth_token {
    prefix = each.value.auth_token[0].prefix
    token  = each.value.auth_token[0].token
  }
}

resource "newrelic_notification_channel" "this" {
  for_each       = { for channel in var.newrelic_notification_channel : channel.name => channel }
  name           = each.value.name
  type           = each.value.type
  destination_id = each.value.destination_id
  product        = each.value.product

  dynamic "property" {
    for_each = each.value.property
    content {
      key   = property.value.key
      value = property.value.value
    }
  }
}

resource "newrelic_workflow" "this" {
  for_each              = { for workflow in var.newrelic_workflow : workflow.name => workflow }
  name                  = each.value.name
  muting_rules_handling = each.value.muting_rules_handling
  issues_filter {
    name = each.value.issues_filter[0].name
    type = each.value.issues_filter[0].type
    # name and type are required but not really relevant:
    # https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow#type

    predicate {
      attribute = each.value.issues_filter[0].predicate[0].attribute
      operator  = each.value.issues_filter[0].predicate[0].operator
      values    = [each.value.issues_filter[0].predicate[0].values]
    }
  }
  destination {
    channel_id            = each.value.destination[0].channel_id
    notification_triggers = each.value.destination[0].notification_triggers
  }
}

resource "newrelic_nrql_alert_condition" "this" {
  for_each = { for alert_condition in var.newrelic_nrql_alert_condition : alert_condition.name => alert_condition }

  policy_id   = each.value.policy_id
  name        = each.value.name
  description = each.value.description
  enabled     = each.value.enabled

  nrql {
    query = each.value.nrql.query
  }
  critical {
    operator              = each.value.critical[0].operator
    threshold             = each.value.critical[0].threshold
    threshold_duration    = each.value.critical[0].threshold_duration
    threshold_occurrences = each.value.critical[0].threshold_occurrences
  }
  warning {
    operator              = each.value.warning[0].operator
    threshold             = each.value.warning[0].threshold
    threshold_duration    = each.value.warning[0].threshold_duration
    threshold_occurrences = each.value.warning[0].threshold_occurrences
  }
  expiration_duration            = each.value.expiration_duration
  open_violation_on_expiration   = each.value.open_violation_on_expiration
  close_violations_on_expiration = each.value.close_violations_on_expiration
  aggregation_window             = each.value.aggregation_window
}

resource "pagerduty_service" "this" {
  for_each                = { for pd_service in var.pagerduty_service : pd_service.name => pd_service }
  name                    = each.value.name
  auto_resolve_timeout    = each.value.auto_resolve_timeout
  acknowledgement_timeout = each.value.acknowledgement_timeout
  escalation_policy       = each.value.escalation_policy
  alert_creation          = each.value.alert_creation

  incident_urgency_rule {
    type    = each.value.incident_urgency_rule[0].type
    urgency = each.value.incident_urgency_rule[0].urgency
  }
}

resource "pagerduty_service_integration" "this" {
  for_each = { for pd_integration in var.pagerduty_service_integration : pd_integration.name => pd_integration }
  name     = var.pagerduty_service_integration[0].name
  service  = var.pagerduty_service_integration[0].service
  vendor   = var.pagerduty_service_integration[0].vendor
}
