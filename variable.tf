variable "resource_name" {
  type = string
  default = "terraform-az"
}

variable "location_name" {
  type = string
  default = "East US"
}


variable "redhat_resource_name" {
  type = string
  default = "terraform-redhat-az"
}


variable "vm_name" {
  type = string
  default = "myVM"
}

variable "resource_group" {
  type = string
  default = "myResourceGroup"
}

variable "vm_size" {
  type = string
  default = "Standard_B1s"
}

variable "location" {
  type = string
  default = "East US"
}

variable "admin_username" {
  type = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
  default = "P@$$w0rd1234!"
}