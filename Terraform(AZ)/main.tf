module "RG" {
  source = "./Module/First_Resource_Group/"
  resource_name = "${var.resource_name}"
  location_name = "${var.location_name}"
}


module "Redhat" {
  source = "./Module/Redhat_vm/"
  redhat_resource_name = "${var.redhat_resource_name}"
  location_name = "${var.location_name}"
}

# module "Start_stop" {
#   source = "./Module/VM_AutoStrat_Stop"
#   redhat_resource_name = "${var.redhat_resource_name}"
#   location_name = "${var.location_name}"
# }