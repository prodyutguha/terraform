
resource "azurerm_resource_group" "rg" {
 name     = "automation-rg"
 location = "East US"
}

# resource "azurerm_automation_account" "automation" {
#  name                = "myAutomationAccount"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#  sku {
#    name = "Basic"
#  }
# }
# resource "azurerm_automation_runbook" "runbook" {
#  name                    = "StartVMRunbook"
#  location                = azurerm_resource_group.rg.location
#  resource_group_name     = azurerm_resource_group.rg.name
#  automation_account_name = azurerm_automation_account.automation.name
#  log_verbose             = "true"
#  log_progress            = "true"
#  runbook_type            = "PowerShellWorkflow"
#  content                 = <<CONTENT
#  workflow Start-AzureVM
#  {
#    param(
#        [string]$ResourceGroupName,
#        [string]$VMName
#    )
#    $connectionName = "AzureRunAsConnection"
#    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
#    Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
#                       -ApplicationId $servicePrincipalConnection.ApplicationId `
#                       -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
#    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
#  }
#  CONTENT
# }
resource "azurerm_automation_schedule" "start_vm_schedule" {
 name                    = "StartVMSchedule"
 resource_group_name     = azurerm_resource_group.rg.name
 automation_account_name = azurerm_automation_account.automation.name
 frequency               = "Day"
 interval                = 1
 timezone                = "UTC"
 start_time              = "2024-09-30T08:00:00Z"
}
resource "azurerm_automation_job_schedule" "start_vm_job_schedule" {
 job_schedule_id         = azurerm_automation_schedule.start_vm_schedule.id
 automation_account_name = azurerm_automation_account.automation.name
 resource_group_name     = azurerm_resource_group.rg.name
 runbook_name            = azurerm_automation_runbook.runbook.name
 parameters = {
   ResourceGroupName = "your-vm-resource-group"
   VMName            = "your-vm-name"
 }
}