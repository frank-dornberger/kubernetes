# resource "newrelic_application_setting" "hello_world" {
#   entity                      = "${data.newrelic_application.app.id}"
#   alias                       = "my_custom_app_name"
#   app_apdex_threshold         = 0.8
#   end_user_apdex_threshold    = 0.8
#   enable_real_user_monitoring = true
# }
# data "newrelic_key_transaction" "txn" {
#   name = "key_transaction"
# }
## Needs API exposure
# resource "newrelic_key_transaction_setting" "hello_world" {
#   entity                      = "${data.newrelic_key_transaction.txn.id}"
#   app_apdex_threshold         = 0.9
#   end_user_apdex_threshold    = 0.9
# }

