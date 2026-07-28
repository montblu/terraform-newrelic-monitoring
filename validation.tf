# Since all monitor maps are merged, all keys between different types of monitors need to be unique to avoid 
# overwriting values.
resource "terraform_data" "check_unique_monitor_keys" {
  lifecycle {
    precondition {
      condition     = length(local.all_monitor_keys) == length(local.all_distinct_monitor_keys)
      error_message = "Monitor keys need to be unique among all monitor objects."
    }
  }
}