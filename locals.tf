locals {
  nr_entity_prefix = var.newrelic_resource_name_prefix != "" ? format("%s-", var.newrelic_resource_name_prefix) : ""
  nr_entity_suffix = var.newrelic_resource_name_suffix != "" ? format("-%s", var.newrelic_resource_name_suffix) : ""

  all_monitors = merge(var.simple_monitors, var.browser_monitors, var.script_monitors, var.step_monitors, var.broken_links_monitors, var.cert_check_monitors)

  all_monitor_resources = merge(newrelic_synthetics_monitor.simple, newrelic_synthetics_monitor.browser, newrelic_synthetics_script_monitor.script, newrelic_synthetics_step_monitor.step, newrelic_synthetics_broken_links_monitor.broken_links, newrelic_synthetics_cert_check_monitor.cert_check)

  # constructs the name string for each monitor in a single location to avoid repetition.
  prefix_suffix_map         = { for key, _ in local.all_monitors : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }
  apm_prefix_suffix_map     = { for key, _ in var.newrelic_apm_entities : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }
  browser_prefix_suffix_map = { for key, _ in var.newrelic_browser_entities : key => "${local.nr_entity_prefix}${key}${local.nr_entity_suffix}" }

  all_monitors_list = [
    var.simple_monitors, var.browser_monitors,
    var.script_monitors, var.step_monitors,
    var.broken_links_monitors, var.cert_check_monitors
  ]

  all_monitor_keys = flatten([for i in local.all_monitors_list : keys(i)])

  # checks for all distinct keys only
  all_distinct_monitor_keys = distinct(local.all_monitor_keys)
}
