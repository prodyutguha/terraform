# Resource Group
resource "azurerm_resource_group" "Patching_RG" {
  name     = "Patching_Windows"
  location = "West Europe"
}

# Maintenance Configurations per Patch Group
resource "azurerm_maintenance_configuration" "maintenance_configuration" {
  for_each                 = var.Patch_Group_ID
  name                     = each.key
  resource_group_name      = azurerm_resource_group.Patching_RG.name
  location                 = "West Europe"
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = each.value.start_date_time
    duration        = "02:00"
    time_zone       = "India Standard Time"
    recur_every     = each.value.recur_every
  }

  install_patches {
    windows {
      classifications_to_include = var.classifications_to_include
      kb_numbers_to_exclude      = var.kb_number_to_exclude
      kb_numbers_to_include      = var.kb_numbers_to_include
    }
    reboot = "IfRequired"
  }
}

# Data source: check if dynamic scope already exists
data "azurerm_maintenance_assignment_dynamic_scope" "existing" {
  for_each = var.Patch_Group_ID
  name     = "scope-${each.key}"
}

# Conditional creation of dynamic scope
resource "azurerm_maintenance_assignment_dynamic_scope" "maintenance_assignment_dynamic" {
  for_each = {
    for k, v in var.Patch_Group_ID :
    k => v
    if try(data.azurerm_maintenance_assignment_dynamic_scope.existing[k].id, null) == null
  }

  name                         = "scope-${each.key}"
  maintenance_configuration_id = azurerm_maintenance_configuration.maintenance_configuration[each.key].id

  filter {
    os_types       = ["Windows"]
    resource_types = ["Microsoft.Compute/virtualMachines"]
    tag_filter     = "Any"
    tags {
      tag    = "Patch Group ID"
      values = [each.key]
    }
  }
}