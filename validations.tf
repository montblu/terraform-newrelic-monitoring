locals {
  all_monitors_list = [
    var.simple_monitors, var.browser_monitors,
    var.script_monitors, var.step_monitors,
    var.broken_links_monitors, var.cert_check_monitors
  ]

  all_monitor_keys = flatten([for i in local.all_monitors_list : keys(i)])

  # checks for all distinct keys only
  all_distinct_monitor_keys = distinct(local.all_monitor_keys)
}

# Since all monitor maps are merged, all keys between different types of monitors need to be unique to avoid 
# overwriting values.
resource "null_resource" "check_unique_monitor_keys" {
  lifecycle {
    precondition {
      condition     = length(local.all_monitor_keys) == length(local.all_distinct_monitor_keys)
      error_message = "Monitor keys need to be unique among all monitor objects."
    }
  }
}
