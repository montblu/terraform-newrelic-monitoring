terraform {
  required_version = ">= 1.4"

  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3.52"
    }

    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = ">= 3.5"
    }
  }
}
