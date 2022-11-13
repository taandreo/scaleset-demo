resource "azurerm_lb" "lb" {
  name                = local.lb_name
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pub_ip.id
  }
}

resource "azurerm_public_ip" "pub_ip" {
  name                = "${local.lb_name}-pip"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "back" {
  name = "backend00"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_rule" "ssh" {
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  name = "ssh"
  backend_port    = 22
  protocol        = "Tcp" 
  frontend_port   = 22
  loadbalancer_id = azurerm_lb.lb.id
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.back.id
  ]
}