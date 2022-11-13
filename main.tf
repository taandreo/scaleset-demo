locals {
  pub_key = file("~/.ssh/id_rsa.pub")
  instances = 1
  scale_set_name = "scaleset00"
  lb_name = "lb00"
}

resource "azurerm_resource_group" "rsg" {
  name     = "scalesetdemo-rsg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnt" {
  name                = "scalesetdemo-vnt"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "snt00"
  resource_group_name  = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.vnt.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                = local.scale_set_name
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  sku                 = var.vm_size
  instances           = local.instances
  admin_username      = "tairan"

  admin_ssh_key {
    username   = "tairan"
    public_key = local.pub_key
  }

  admin_password = var.admin_pass

  termination_notification {
    enabled = true
    timeout = "PT5M"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${local.scale_set_name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.back.id
      ]
    }
  }
  user_data = base64encode(<<-EOT
    #!/bin/bash
    curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" > /tmp/info.json
    curl "${azurerm_automation_webhook.hook_scaleout.uri}" \
      --header "Content-Type: application/json" \
      --request POST \
      --data "$(cat /tmp/info.json)"
    EOT
  )
}

resource "azurerm_monitor_autoscale_setting" "scale_setting" {
  name                = "AutoscaleSetting"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.scaleset.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 0
      maximum = 10
    }
  }
}
