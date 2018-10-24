# resource "newrelic_synthetics_monitor" "ping_example" {
#   name                   = "${var.app_name} Ping Monitor"
#   type                   = "simple"
#   frequency              = 1 #1, 5, 10, 15, 30, 60, 360, 720, or 1440
#   uri                    = "http://my-page.com"
#   locations              = ["AWS_US_WEST_1", "AWS_EU_CENTRAL_1"]
#   status                 = "enabled" #enabled, disabled, muted
#   slaThreshold           = 1
#   validationString       = "hello"
#   verifySSL              = false
#   bypassHEADRequest      = true
#   treatRedirectAsFailure = false
#   policy_id              = "${newrelic_alert_policy.browser.id}"
# }
# resource "newrelic_synthetics_monitor" "simple_browser_example" {
#   name                   = "${var.app_name} Simple Browser Monitor"
#   type                   = "browser"
#   frequency              = 60 #1, 5, 10, 15, 30, 60, 360, 720, or 1440
#   uri                    = "http://my-page.com"
#   locations              = ["AWS_US_WEST_1", "AWS_EU_CENTRAL_1"]
#   status                 = "enabled" #enabled, disabled, muted
#   slaThreshold           = 2
#   validationString       = "hello"
#   verifySSL              = false
#   policy_id              = "${newrelic_alert_policy.browser.id}"
# }
# resource "newrelic_synthetics_monitor" "scripted_browser_example" {
#   name                   = "${var.app_name} Scripted Browser Monitor"
#   type                   = "scripted_browser"
#   frequency              = 60 #1, 5, 10, 15, 30, 60, 360, 720, or 1440
#   locations              = ["AWS_US_WEST_1", "AWS_EU_CENTRAL_1"]
#   status                 = "enabled" #enabled, disabled, muted
#   slaThreshold           = 5
#   script                 = "${file(scripted_browser.js)}"
#   policy_id              = "${newrelic_alert_policy.browser.id}"
# }

