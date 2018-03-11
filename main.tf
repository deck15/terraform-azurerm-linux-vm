# Azure Linux VM module
data "azurerm_resource_group" "main" {
  name = "${var.resource_group_name}"
}

locals {
  location = "${var.location != "" ? var.location : data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  tags = "${merge(
    data.azurerm_resource_group.main.tags,
    var.tags
  )}"

  disk_sha1 = "${sha1("${var.resource_group_name}${var.vm_name}")}"
  disk_name = "${var.os_disk_prefix}${local.disk_sha1}"

  nic_name = "${var.vm_nic_name != "" ? var.vm_nic_name : "${var.vm_name}-nic"}"
  key_data = "${var.admin_public_key != "" ? var.admin_public_key : file("${var.ssh_key_path}")}"

  backend_address_pool = "${var.backend_address_pool_id != "" ? 1 : 0}"
  availability_set_name = "${var.availability_set_name != "" ? var.availability_set_name : "${var.vm_name}-avset"}"
}

resource "azurerm_availability_set" "vm" {
  name                         = "${local.availability_set_name}"
  location                     = "${local.location}"
  resource_group_name          = "${local.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = "${local.tags}"
}

resource "azurerm_network_interface" "niclb" {
  name      = "${local.nic_name}-${count.index}"
  count     = "${var.use_loadbalancer ? var.node_count : 0}"
  location  = "${local.location}"
  resource_group_name = "${local.resource_group_name}"

  ip_configuration {
    name                      = "${local.nic_name}-${count.index}-ip"
    subnet_id                 = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${var.backend_address_pool_id}"]
  }

  tags = "${local.tags}"
}

resource "azurerm_network_interface" "nic" {
  name      = "${local.nic_name}-${count.index}"
  count     = "${var.use_loadbalancer ? 0 : var.node_count}"
  location  = "${local.location}"
  resource_group_name = "${local.resource_group_name}"

  ip_configuration {
    name                      = "${local.nic_name}-${count.index}-ip"
    subnet_id                 = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = "${local.tags}"
}

resource "azurerm_virtual_machine" "vm" {
  count                 = "${var.node_count}"
  name                  = "${var.vm_name}-${count.index}"
  location              = "${local.location}"
  resource_group_name   = "${local.resource_group_name}"
  network_interface_ids = ["${local.backend_address_pool ? element(concat(azurerm_network_interface.niclb.*.id, list("")), count.index) : element(concat(azurerm_network_interface.nic.*.id, list("")), count.index)}"]

  vm_size               = "${var.vm_size}"
  availability_set_id   = "${azurerm_availability_set.vm.id}"

  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? var.vm_os_publisher : ""}"
    offer     = "${var.vm_os_id == "" ? var.vm_os_offer : ""}"
    sku       = "${var.vm_os_id == "" ? var.vm_os_sku : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${format("%.15s", lower("${local.disk_name}"))}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.managed_disk_type}"
  }

  os_profile {
    computer_name   = "${var.hostname != "" ? var.hostname : var.vm_name}-${count.index}"
    admin_username  = "${var.admin_username}"
    custom_data     = "${var.custom_data}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${local.key_data}"
    }
  }

  tags = "${local.tags}"
}

