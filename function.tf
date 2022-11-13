# resource "azurerm_storage_account" "func_sta" {
#   name                     = "${var.func_name}sta"
#   resource_group_name      = azurerm_resource_group.rsg.name
#   location                 = azurerm_resource_group.rsg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_service_plan" "plan" {
#   name                = "${var.func_name}-plan"
#   location            = azurerm_resource_group.rsg.location
#   resource_group_name = azurerm_resource_group.rsg.name
#   os_type = "Linux"
#   sku_name = "Y1"
# }

# resource "azurerm_linux_function_app" "pwsh" {
#   name                       = var.func_name
#   location                   = azurerm_resource_group.rsg.location
#   resource_group_name        = azurerm_resource_group.rsg.name
#   app_service_plan_id        = azurerm_service_plan.plan.id
#   storage_account_name       = azurerm_storage_account.func_sta.name
#   storage_account_access_key = azurerm_storage_account.func_sta.primary_access_key
#   os_type                    = "linux"

#   app_settings = {
#     # "FUNCTIONS_EXTENSION_VERSION" = "~4"
#     "FUNCTIONS_WORKER_RUNTIME"    = "powershell"
#   }
# }

# resource "azurerm_function_app_function" "name" {
#   name = "setNode"
#   function_app_id = azurerm_function_app.pwsh.id
#   config_json = file("./functions/setNode/function.json")
#   file {
#     name = "run.ps1"
#     content = file("./functions/setNode/run.ps1")
#   }
#   language = "powershell"
# }