data "newrelic_application" "app" {
  name = "hello_world"
}

resource "newrelic_alert_policy" "apm" {
  name = "${var.app_name} - APM - Production (managed through Terraform)"
}

resource "newrelic_alert_condition" "error_percentage" {
  policy_id       = "${newrelic_alert_policy.apm.id}"
  name            = "${var.app_name} - Error Percentage"
  type            = "apm_app_metric"
  entities        = ["${data.newrelic_application.app.id}"]
  condition_scope = "application"
  metric          = "error_percentage"

  term {
    duration      = 120
    operator      = "above"
    priority      = "critical"
    threshold     = "25"
    time_function = "all"
  }
}

resource "newrelic_alert_policy" "browser" {
  name = "${var.app_name} - Browser - Production (managed through Terraform)"
}

resource "newrelic_alert_condition" "total_page_load" {
  policy_id   = "${newrelic_alert_policy.browser.id}"
  name        = "${var.app_name} - Total Page Load"
  type        = "browser_metric"
  entities    = ["${data.newrelic_application.app.id}"]
  metric      = "total_page_load"
  runbook_url = ""

  term {
    duration      = 120
    operator      = "above"
    priority      = "critical"
    threshold     = "15"
    time_function = "all"
  }
}

resource "newrelic_alert_channel" "email" {
  name = "My Email Channel"
  type = "email"

  configuration = {
    recipients              = "${var.email_address}"
    include_json_attachment = "0"
  }
}

resource "newrelic_alert_policy_channel" "application_email_alert" {
  policy_id  = "${newrelic_alert_policy.apm.id}"
  channel_id = "${newrelic_alert_channel.email.id}"
}

resource "newrelic_alert_policy_channel" "browser_email_alert" {
  policy_id  = "${newrelic_alert_policy.browser.id}"
  channel_id = "${newrelic_alert_channel.email.id}"
}
