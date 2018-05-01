output "admin_username" {
  value = "${var.admin_username}"
}
output "node_private_ips" {
  description = "private ip addresses of the vm nics"
  value = "${split(",", local.backend_address_pool ? join(",", azurerm_network_interface.niclb.*.private_ip_address) : join(",", azurerm_network_interface.nic.*.private_ip_address))}"
}

output "node_names" {
  value = "${split(",", var.data_disk == "true" ? join(",", azurerm_virtual_machine.vmdd.*.name) : join(",", azurerm_virtual_machine.vm.*.name))}"
}

output "vm_ids" {
  description = "Virtual machine ids created."
  value       = "${split(",", var.data_disk == "true" ? join(",", azurerm_virtual_machine.vmdd.*.id) : join(",", azurerm_virtual_machine.vm.*.id))}"
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = "${azurerm_availability_set.vm.id}"
}

output "availability_set_name" {
  description = "Name of the availability set where the vms are provisioned."
  value       = "${azurerm_availability_set.vm.name}"
}
