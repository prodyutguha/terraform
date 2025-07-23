resource "azurerm_resource_group" "Patching_RG" {
  name     = "Patch_Windows"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "maintenance_configuration" {
  for_each                 = { for Patch_Group_ID, properties in var.Patch_Group_ID : Patch_Group_ID => properties }
  name                     = each.key
  resource_group_name      = azurerm_resource_group.Patching_RG.name
  location                 = "West Europe"
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = var.start_date_time
    #expiration_date_time  = var.expiration_date_time
    duration    = "02:00"
    time_zone   = "India Standard Time"
    recur_every = each.value.recur_every
  }

  install_patches {
    windows {
      classifications_to_include = var.classifications_to_include
      kb_numbers_to_exclude      = var.kb_number_to_exclude
      kb_numbers_to_include      = var.kb_number_to_include
    }
    reboot = "IfRequired"
  }
  #tags = var.tags
}


# resource "azurerm_maintenance_assignment_dynamic_scope" "maintenance_assignment_dynamic" {
#   for_each                         = { for Patch_Group_ID, properties in var.Patch_Group_ID : Patch_Group_ID => properties }
#   name                             = "scope-${each.key}"
#   maintenance_configuration_id     = azurerm_maintenance_configuration.maintenance_configuration[each.key].id

#   filter {
#     #locations              = ["East US"]
#     os_types                = ["Windows"]
#     #resource_groups        = ["azurerm_resource_group.RG.name"]
#     resource_types          = ["Microsoft.Compute/virtualMachines"]
#     tag_filter              = "Any"
#     tags {
#       tag       = "Patch Group ID"
#       values    = [each.key]
#     }
#   }
# }
