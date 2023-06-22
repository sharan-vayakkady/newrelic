resource "newrelic_nrql_alert_condition" "dag_failure" {

  policy_id                    = var.app_policy_id
  type                         = "static"
  name                         = "DAG Failure - ${each.value.name} (${var.env})"
  violation_time_limit_seconds = var.violation_time_limit_seconds

  fill_option        = "last_value"
  aggregation_timer  = 60
  aggregation_method = "event_timer"

  expiration_duration            = each.value.frequency_seconds * 2
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query = <<QUERY
    select count(*)
    from Metric
    where aws.amazonmwaa.DAG = '${each.value.name}'
      and aws.amazonmwaa.State is not null
      and aws.amazonmwaa.State not in ('success', 'up_for_retry')
      and aws.accountId = '${var.account_id}'
    QUERY
  }

  critical {
    operator              = "above"
    threshold             = var.threshold
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}
