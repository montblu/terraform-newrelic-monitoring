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
