resource "azurerm_automation_account" "aut_account" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_runbook" "scaleout" {
  name = "ScaleOut"
  automation_account_name = azurerm_automation_account.aut_account.name
  location = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  log_progress = true
  log_verbose = true
  runbook_type = "PowerShell"
  content = file("runbooks/ScaleOut.ps1")
}

resource "azurerm_automation_webhook" "hook_scaleout" {
  name                    = azurerm_automation_runbook.scaleout.name
  resource_group_name     = azurerm_resource_group.rsg.name
  automation_account_name = azurerm_automation_account.aut_account.name            
  enabled                 = true
  expiry_time             = "2030-12-31T00:00:00Z" 
  runbook_name            = azurerm_automation_runbook.scaleout.name
}

resource "azurerm_role_assignment" "name" {
  principal_id = azurerm_automation_account.aut_account.identity[0].principal_id
  role_definition_name = "Contributor"
  scope = azurerm_linux_virtual_machine_scale_set.scaleset.id
}
