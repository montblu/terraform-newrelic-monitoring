# terraform-newrelic-monitoring
Terraform module to create communication between NewRelic and PagerDuty

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_newrelic"></a> [newrelic](#requirement\_newrelic) | 3.27.7 |
| <a name="requirement_pagerduty"></a> [pagerduty](#requirement\_pagerduty) | 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_newrelic"></a> [newrelic](#provider\_newrelic) | 3.27.7 |
| <a name="provider_pagerduty"></a> [pagerduty](#provider\_pagerduty) | 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [newrelic_alert_policy.critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/alert_policy) | resource |
| [newrelic_alert_policy.critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/alert_policy) | resource |
| [newrelic_alert_policy.non_critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/alert_policy) | resource |
| [newrelic_alert_policy.non_critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/alert_policy) | resource |
| [newrelic_alert_policy.synthetics](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/alert_policy) | resource |
| [newrelic_notification_channel.critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.non_critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.non_critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_channel) | resource |
| [newrelic_notification_channel.synthetics](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_channel) | resource |
| [newrelic_notification_destination.critical_apm](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_destination) | resource |
| [newrelic_notification_destination.non_critical_apm](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_destination) | resource |
| [newrelic_notification_destination.synthetics](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/notification_destination) | resource |
| [newrelic_nrql_alert_condition.critical_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.critical_health_synthetics](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.critical_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.non_critical_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.non_critical_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_nrql_alert_condition.noncritical_health_synthetics](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/nrql_alert_condition) | resource |
| [newrelic_synthetics_monitor.all](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/synthetics_monitor) | resource |
| [newrelic_workflow.critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/workflow) | resource |
| [newrelic_workflow.critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/workflow) | resource |
| [newrelic_workflow.non_critical_apm_error_rate](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/workflow) | resource |
| [newrelic_workflow.non_critical_apm_response_time](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/workflow) | resource |
| [newrelic_workflow.this](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/resources/workflow) | resource |
| [pagerduty_service.critical](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service) | resource |
| [pagerduty_service.non_critical](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service) | resource |
| [pagerduty_service.synthetics_newrelic](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service) | resource |
| [pagerduty_service_integration.critical](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service_integration) | resource |
| [pagerduty_service_integration.non_critical](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service_integration) | resource |
| [pagerduty_service_integration.non_critical_events_API_v2](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service_integration) | resource |
| [pagerduty_service_integration.synthetics_newrelic](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/resources/service_integration) | resource |
| [newrelic_entity.this](https://registry.terraform.io/providers/newrelic/newrelic/3.27.7/docs/data-sources/entity) | data source |
| [pagerduty_escalation_policy.ep](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/data-sources/escalation_policy) | data source |
| [pagerduty_vendor.vendor](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.4.0/docs/data-sources/vendor) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_monitor_name_uri"></a> [monitor\_name\_uri](#input\_monitor\_name\_uri) | n/a | <pre>map(object({<br>    name                              = string<br>    uri                               = string<br>    type                              = optional(string, "SIMPLE")<br>    period                            = optional(string, "EVERY_5_MINUTES")<br>    status                            = optional(string, "ENABLED")<br>    locations_public                  = optional(list(string), ["AWS_US_EAST_1", "AWS_EU_WEST_1", "AWS_EU_SOUTH_1"])<br>    validation_string                 = optional(string, "")<br>    verify_ssl                        = optional(bool, true)<br>    bypass_head_request               = optional(bool, false)<br>    custom_header                     = optional(list(map(string)))<br>    critical_synthetics_threshold     = optional(number, 3)<br>    non_critical_synthetics_threshold = optional(number, 1)<br>    critical_response_time            = optional(number, 0.7)<br>    non_critical_response_time        = optional(number, 0.5)<br>    critical_error_rate               = optional(number, 15)<br>    non_critical_error_rate           = optional(number, 7)<br>    create_non_critical_monitor       = optional(bool, false)<br>    create_critical_monitor           = optional(bool, false)<br>    create_non_critical_apm_resources = optional(bool, false)<br>    create_critical_apm_resources     = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_newrelic_entity_domain"></a> [newrelic\_entity\_domain](#input\_newrelic\_entity\_domain) | NewRelic domain | `string` | `"APM"` | no |
| <a name="input_newrelic_entity_type"></a> [newrelic\_entity\_type](#input\_newrelic\_entity\_type) | NewRelic type | `string` | `"APPLICATION"` | no |
| <a name="input_newrelic_resource_name_prefix"></a> [newrelic\_resource\_name\_prefix](#input\_newrelic\_resource\_name\_prefix) | n/a | `string` | `""` | no |
| <a name="input_newrelic_resource_name_suffix"></a> [newrelic\_resource\_name\_suffix](#input\_newrelic\_resource\_name\_suffix) | n/a | `string` | `""` | no |
| <a name="input_pagerduty_escalation_policy"></a> [pagerduty\_escalation\_policy](#input\_pagerduty\_escalation\_policy) | n/a | `string` | `"Default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
