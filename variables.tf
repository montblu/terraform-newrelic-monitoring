variable "pagerduty_escalation_policy" {
  type    = string
  default = "Default"
}

variable "newrelic_resource_name_prefix" {
  type    = string
  default = ""
}

variable "newrelic_resource_name_suffix" {
  type    = string
  default = ""
}

variable "simple_monitors" {
  type = map(object({
    name                                          = string
    uri                                           = string
    type                                          = optional(string, "SIMPLE")
    period                                        = optional(string, "EVERY_5_MINUTES")
    status                                        = optional(string, "ENABLED")
    locations_public                              = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    validation_string                             = optional(string, "")
    verify_ssl                                    = optional(bool, true)
    bypass_head_request                           = optional(bool, false)
    custom_header                                 = optional(list(map(string)))
    critical_synthetics_operator                  = optional(string, "above_or_equals")
    critical_synthetics_threshold                 = optional(number, 3)
    critical_synthetics_threshold_duration        = optional(number, 300)
    critical_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_synthetics_expiration_duration       = optional(number, 300)
    critical_synthetics_aggregation_window        = optional(number, 300)
    non_critical_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_synthetics_threshold             = optional(number, 1)
    non_critical_synthetics_threshold_duration    = optional(number, 900)
    non_critical_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_synthetics_expiration_duration   = optional(number, 600)
    non_critical_synthetics_aggregation_window    = optional(number, 300)
    critical_response_time                        = optional(number, 0.7)
    non_critical_response_time                    = optional(number, 0.5)
    critical_error_rate                           = optional(number, 15)
    non_critical_error_rate                       = optional(number, 7)
    create_non_critical_monitor                   = optional(bool, false)
    create_critical_monitor                       = optional(bool, false)
    create_non_critical_apm_resources             = optional(bool, false)
    create_critical_apm_resources                 = optional(bool, false)
  }))
  default = {}
}

variable "browser_monitors" {
  type = map(object({
    name                                                   = string
    uri                                                    = string
    type                                                   = optional(string, "BROWSER")
    period                                                 = optional(string, "EVERY_5_MINUTES")
    status                                                 = optional(string, "ENABLED")
    locations_public                                       = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    validation_string                                      = optional(string, "")
    verify_ssl                                             = optional(bool, true)
    custom_header                                          = optional(list(map(string)))
    runtime_type                                           = optional(string, "CHROME_BROWSER")
    runtime_type_version                                   = optional(string, "100")
    script_language                                        = optional(string, "JAVASCRIPT")
    devices                                                = optional(list(string), ["DESKTOP", "MOBILE_LANDSCAPE", "MOBILE_PORTRAIT", "TABLET_LANDSCAPE", "TABLET_PORTRAIT"])
    browsers                                               = optional(list(string), ["CHROME", "FIREFOX"])
    critical_duration_synthetics_operator                  = optional(string, "above_or_equals")
    critical_duration_synthetics_threshold                 = optional(number, 4)
    critical_duration_synthetics_threshold_duration        = optional(number, 300)
    critical_duration_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_duration_synthetics_expiration_duration       = optional(number, 300)
    critical_duration_synthetics_aggregation_window        = optional(number, 300)
    non_critical_duration_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_duration_synthetics_threshold             = optional(number, 2)
    non_critical_duration_synthetics_threshold_duration    = optional(number, 900)
    non_critical_duration_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_duration_synthetics_expiration_duration   = optional(number, 600)
    non_critical_duration_synthetics_aggregation_window    = optional(number, 300)
    create_non_critical_monitor                            = optional(bool, false)
    create_critical_monitor                                = optional(bool, false)
    create_critical_browser_alert                          = optional(bool, false)
    create_non_critical_browser_alert                      = optional(bool, false)
    critical_browser_pageload                              = optional(number, 7)
    non_critical_browser_pageload                          = optional(number, 3.5)
  }))
  default = {}
}

variable "script_monitors" {
  type = map(object({
    name                                                   = string
    type                                                   = optional(string, "SCRIPT_API") # SCRIPT_API or SCRIPT_BROWSER
    status                                                 = optional(string, "ENABLED")
    locations_public                                       = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    period                                                 = optional(string, "EVERY_5_MINUTES")
    script                                                 = string
    runtime_type                                           = optional(string, "NODE_API")
    runtime_type_version                                   = optional(string, "16.10")
    script_language                                        = optional(string, "JAVASCRIPT")
    critical_synthetics_operator                           = optional(string, "above_or_equals")
    critical_synthetics_threshold                          = optional(number, 3)
    critical_synthetics_threshold_duration                 = optional(number, 300)
    critical_synthetics_threshold_occurrences              = optional(string, "at_least_once")
    critical_synthetics_expiration_duration                = optional(number, 300)
    critical_synthetics_aggregation_window                 = optional(number, 300)
    critical_duration_synthetics_operator                  = optional(string, "above_or_equals")
    critical_duration_synthetics_threshold                 = optional(number, 4)
    critical_duration_synthetics_threshold_duration        = optional(number, 300)
    critical_duration_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_duration_synthetics_expiration_duration       = optional(number, 300)
    critical_duration_synthetics_aggregation_window        = optional(number, 300)
    non_critical_synthetics_operator                       = optional(string, "above_or_equals")
    non_critical_synthetics_threshold                      = optional(number, 1)
    non_critical_synthetics_threshold_duration             = optional(number, 900)
    non_critical_synthetics_threshold_occurrences          = optional(string, "at_least_once")
    non_critical_synthetics_expiration_duration            = optional(number, 600)
    non_critical_synthetics_aggregation_window             = optional(number, 300)
    non_critical_duration_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_duration_synthetics_threshold             = optional(number, 2)
    non_critical_duration_synthetics_threshold_duration    = optional(number, 900)
    non_critical_duration_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_duration_synthetics_expiration_duration   = optional(number, 600)
    non_critical_duration_synthetics_aggregation_window    = optional(number, 300)
    create_non_critical_monitor                            = optional(bool, false)
    create_critical_monitor                                = optional(bool, false)
    # SCRIPT_BROWSER only additional values
    enable_screenshot_on_failure_and_script = optional(bool, false)
    browsers                                = optional(list(string), ["CHROME", "FIREFOX"])
    devices                                 = optional(list(string), ["DESKTOP", "MOBILE_LANDSCAPE", "MOBILE_PORTRAIT", "TABLET_LANDSCAPE", "TABLET_PORTRAIT"])
  }))
  default = {}
}

variable "step_monitors" {
  type = map(object({
    name                                    = string
    type                                    = optional(string, "STEP")
    enable_screenshot_on_failure_and_script = optional(bool, false)
    locations_public                        = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    period                                  = optional(string, "EVERY_5_MINUTES")
    status                                  = optional(string, "ENABLED")
    runtime_type                            = optional(string, "CHROME_BROWSER")
    runtime_type_version                    = optional(string, "100")
    devices                                 = optional(list(string), ["DESKTOP", "MOBILE_LANDSCAPE", "MOBILE_PORTRAIT", "TABLET_LANDSCAPE", "TABLET_PORTRAIT"])
    browsers                                = optional(list(string), ["CHROME", "FIREFOX"])
    steps = list(object({
      ordinal = number
      type    = string
      values  = list(string)
    }))
    critical_synthetics_operator                           = optional(string, "above_or_equals")
    critical_synthetics_threshold                          = optional(number, 3)
    critical_synthetics_threshold_duration                 = optional(number, 300)
    critical_synthetics_threshold_occurrences              = optional(string, "at_least_once")
    critical_synthetics_expiration_duration                = optional(number, 300)
    critical_synthetics_aggregation_window                 = optional(number, 300)
    critical_duration_synthetics_operator                  = optional(string, "above_or_equals")
    critical_duration_synthetics_threshold                 = optional(number, 4)
    critical_duration_synthetics_threshold_duration        = optional(number, 300)
    critical_duration_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_duration_synthetics_expiration_duration       = optional(number, 300)
    critical_duration_synthetics_aggregation_window        = optional(number, 300)
    non_critical_synthetics_operator                       = optional(string, "above_or_equals")
    non_critical_synthetics_threshold                      = optional(number, 1)
    non_critical_synthetics_threshold_duration             = optional(number, 900)
    non_critical_synthetics_threshold_occurrences          = optional(string, "at_least_once")
    non_critical_synthetics_expiration_duration            = optional(number, 600)
    non_critical_synthetics_aggregation_window             = optional(number, 300)
    non_critical_duration_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_duration_synthetics_threshold             = optional(number, 2)
    non_critical_duration_synthetics_threshold_duration    = optional(number, 900)
    non_critical_duration_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_duration_synthetics_expiration_duration   = optional(number, 600)
    non_critical_duration_synthetics_aggregation_window    = optional(number, 300)
    create_non_critical_monitor                            = optional(bool, false)
    create_critical_monitor                                = optional(bool, false)
  }))
  default = {}
}

variable "broken_links_monitors" {
  type = map(object({
    name                                                   = string
    type                                                   = optional(string, "BROKEN_LINKS")
    uri                                                    = string
    locations_public                                       = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])
    period                                                 = optional(string, "EVERY_5_MINUTES")
    status                                                 = optional(string, "ENABLED")
    runtime_type                                           = optional(string, "NODE_API")
    runtime_type_version                                   = optional(string, "16.10")
    critical_synthetics_operator                           = optional(string, "above_or_equals")
    critical_synthetics_threshold                          = optional(number, 3)
    critical_synthetics_threshold_duration                 = optional(number, 300)
    critical_synthetics_threshold_occurrences              = optional(string, "at_least_once")
    critical_synthetics_expiration_duration                = optional(number, 300)
    critical_synthetics_aggregation_window                 = optional(number, 300)
    critical_duration_synthetics_operator                  = optional(string, "above_or_equals")
    critical_duration_synthetics_threshold                 = optional(number, 4)
    critical_duration_synthetics_threshold_duration        = optional(number, 300)
    critical_duration_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_duration_synthetics_expiration_duration       = optional(number, 300)
    critical_duration_synthetics_aggregation_window        = optional(number, 300)
    non_critical_synthetics_operator                       = optional(string, "above_or_equals")
    non_critical_synthetics_threshold                      = optional(number, 1)
    non_critical_synthetics_threshold_duration             = optional(number, 900)
    non_critical_synthetics_threshold_occurrences          = optional(string, "at_least_once")
    non_critical_synthetics_expiration_duration            = optional(number, 600)
    non_critical_synthetics_aggregation_window             = optional(number, 300)
    non_critical_duration_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_duration_synthetics_threshold             = optional(number, 2)
    non_critical_duration_synthetics_threshold_duration    = optional(number, 900)
    non_critical_duration_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_duration_synthetics_expiration_duration   = optional(number, 600)
    non_critical_duration_synthetics_aggregation_window    = optional(number, 300)
    create_non_critical_monitor                            = optional(bool, false)
    create_critical_monitor                                = optional(bool, false)
  }))
  default = {}
}

variable "cert_check_monitors" {
  type = map(object({
    name                                          = string
    type                                          = optional(string, "CERT_CHECK")
    domain                                        = string
    locations_public                              = optional(list(string), ["US_EAST_1", "EU_WEST_1", "EU_SOUTH_1"])
    certificate_expiration                        = optional(string, "10")
    period                                        = optional(string, "EVERY_DAY")
    status                                        = optional(string, "ENABLED")
    runtime_type                                  = optional(string, "NODE_API")
    runtime_type_version                          = optional(string, "16.10")
    critical_synthetics_operator                  = optional(string, "above_or_equals")
    critical_synthetics_threshold                 = optional(number, 3)
    critical_synthetics_threshold_duration        = optional(number, 300)
    critical_synthetics_threshold_occurrences     = optional(string, "at_least_once")
    critical_synthetics_expiration_duration       = optional(number, 300)
    critical_synthetics_aggregation_window        = optional(number, 300)
    non_critical_synthetics_operator              = optional(string, "above_or_equals")
    non_critical_synthetics_threshold             = optional(number, 1)
    non_critical_synthetics_threshold_duration    = optional(number, 900)
    non_critical_synthetics_threshold_occurrences = optional(string, "at_least_once")
    non_critical_synthetics_expiration_duration   = optional(number, 600)
    non_critical_synthetics_aggregation_window    = optional(number, 300)
    create_non_critical_monitor                   = optional(bool, false)
    create_critical_monitor                       = optional(bool, false)
  }))
  default = {}
}
