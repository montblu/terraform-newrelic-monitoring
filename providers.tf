terraform {
  required_version = ">= 1"

  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.27.7"
    }

    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "3.4.0"
    }
  }
}
