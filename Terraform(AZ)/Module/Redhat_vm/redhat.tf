resource "azurerm_resource_group" "redhat_RG" {
  name     = "${var.redhat_resource_name}"
  location = "${var.location_name}"
}

resource "azurerm_virtual_network" "redhat_VN" {
  name                = "${var.redhat_resource_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.redhat_RG.location
  resource_group_name = azurerm_resource_group.redhat_RG.name
}

resource "azurerm_subnet" "redhat_internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.redhat_RG.name
  virtual_network_name = azurerm_virtual_network.redhat_VN.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "redhat_public_ip" {
  name                = "${var.redhat_resource_name}-publicIP"
  resource_group_name = azurerm_resource_group.redhat_RG.name
  location            = azurerm_resource_group.redhat_RG.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "redhat_NI" {
  name                = "${var.redhat_resource_name}-nic"
  location            = azurerm_resource_group.redhat_RG.location
  resource_group_name = azurerm_resource_group.redhat_RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.redhat_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.redhat_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "redhat_machin" {
  name                = "Redhat-VM"
  resource_group_name = azurerm_resource_group.redhat_RG.name
  location            = azurerm_resource_group.redhat_RG.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.redhat_NI.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "128"

  }


  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_5"
    version   = "latest"
  }

  
}

resource "azurerm_monitor_action_group" "_alert_main" {
  name                = "Aztiongroup-Cpu-Utlization"
  resource_group_name = azurerm_resource_group.redhat_RG.name
  short_name          = "exampleact"

  webhook_receiver {
    name        = "callmyapi"
    service_uri = "http://example.com/alert"
  }
}

resource "azurerm_monitor_metric_alert" "alert_cpu_utlization" {
  name                  = "Alert_Cpu-Utlization"
  resource_group_name   = azurerm_resource_group.redhat_RG.name
  scopes                = [azurerm_resource_group.redhat_RG.id]
  description           = "description"
  target_resource_type  = "Microsoft.Compute/virtualMachines"
  target_resource_location = "${var.location_name}"
  window_size           = "PT15M" #lookback period#
  frequency             = "PT5M" #check every#
  severity              = 0

  
  criteria { 
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 85
    #skip_metric_validation = true
  }

  action {
    action_group_id = azurerm_monitor_action_group._alert_main.id
  }
}


resource "azurerm_managed_disk" "data_disk" {
  name                 = "Redhat-VM-disk1"
  location             = azurerm_resource_group.redhat_RG.location
  resource_group_name  = azurerm_resource_group.redhat_RG.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "128"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk-att" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.redhat_machin.id
  lun                = "0"
  caching            = "ReadWrite"
}