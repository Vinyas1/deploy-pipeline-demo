# References your existing NSG rather than creating a new one —
# you already have the VM, this just manages one rule on it as code.
data "azurerm_network_security_group" "vm_nsg" {
  name                = var.nsg_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_app" {
  name                        = "allow-app-http"
  priority                    = 320
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.app_port
  source_address_prefix       = var.allowed_source
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.vm_nsg.name
}
