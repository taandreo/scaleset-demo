resource "azurerm_monitor_activity_log_alert" "main" {
  name                = "scale-alert"
  resource_group_name = azurerm_resource_group.rsg.name
  scopes              = [azurerm_linux_virtual_machine_scale_set.scaleset.id]
  description         = "This alert monitor the scale set ${azurerm_linux_virtual_machine_scale_set.scaleset.name}."

  criteria {
    operation_name = "Microsoft.Insights/AutoscaleSettings/ScaleupResult/Action"
    category       = "Autoscale"
    level          = "Informational" 
    status         = "succeeded"
  }

  action {
    action_group_id = azurerm_monitor_action_group.mail.id
  }
}

resource "azurerm_monitor_action_group" "mail" {
  name       = "scalling_action_group"
  short_name = "scalling"
  resource_group_name = azurerm_resource_group.rsg.name
  email_receiver {
    email_address = "taandreo@hotmail.com"
    name = "emailme"
  }
}