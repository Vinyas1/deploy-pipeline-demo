output "rule_name" {
  value = azurerm_network_security_rule.allow_app.name
}

output "opened_port" {
  value = var.app_port
}
