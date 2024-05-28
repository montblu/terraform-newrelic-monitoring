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
  for_each = var.create_apm_resources == true ? var.monitor_name_uri : {}

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
