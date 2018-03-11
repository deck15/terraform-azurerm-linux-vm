Azure Linux Virtual Machine Terraform Module
============================================

A simple module to easily create Linux VMs in Azure Cloud. Works with Public and Private Azure cloud.

Deploys 1+ Virtual Machines to your provided VNet
This Terraform module deploys Virtual Machines in Azure with the following characteristics:

* All VMs use managed disks (recommended).
* VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.subnet_id`.

Usage
-----

Simple example with a pre-configured vnet/subnet.

```hcl
resource "azurerm_resource_group" "rg" {
  name = "MyResourceGroup"
  location = "westus"

  tags = {
    environment = "test"
    costcenter  = "12345"
    appname     = "myapp"
  }
}

data "azurerm_subnet" "subnet" {
  name                  = "subnet1"
  virtual_network_name  = "vnet1"
  resource_group_name   = "vnetRG"
}

module "linux_vm" {
  source = "github.com/highwayoflife/terraform-azure-linux-vm"

  resource_group_name = "${azurerm_resource_group.rg.name}"
  node_count          = "3"
  subnet_id           = "${data.azurerm_subnet.subnet.id}"
  use_loadbalancer    = false
  vm_name             = "linuxvm"

  admin_username      = "linuxadmin"
  ssh_key_path        = "~/.ssh/linux_key.pub"
}
```

Argument Reference
------------------

The following arguments are supported:

* `resource_group_name`
  * (Required) The name of the resource group in which the resources will be created"
* `location`
  * (Optional) The location/region where the virtual machines will be created. Uses the location of the resource group by default.
* `subnet_id`
  * (Required) The subnet id of the virtual network where the virtual machines will reside.
* `tags`
  * (Optional) A map of the tags to use on the resources that are deployed with this module. Tags will be merged with those defined by the resource group.
* `os_disk_prefix`
  * (Optional) Os disk name prefix to use for managed disk attached to the virtual machine
* `vm_nic_name`
  * (Optional) Name of the Network interface for the VM
* `vm_name`
  * (Optional) Name of the virtual machine. default = "linuxcomputevm"
* `vm_size`
  * (Optional) Azure VM Size to use. See: [Cloud Services Sizes](https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs). default = "`Standard_B2s`"
* `availability_set_name`
  * (Optional) Name of the availability set. Default is derived from `{vm_name}-avset`.
* `admin_public_key`
  * Optionally supply the admin public key. If provided, will override variable: sshKey
* `ssh_key_path`
  * (Optional) Path to the public key to be used for ssh access to the VM. Default is ~/.ssh/id\_rsa.pub. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id\_rsa.pub. default = "`~/.ssh/id_rsa.pub`"
* `use_loadbalancer`
  * (Optional) When set to true, the Virtual Network Interfaces will be assigned to the backend\_address\_pool\_id. Default = true
* `backend_address_pool_id`
  * (Optional) List of Load Balancer Backend Address Pool IDs references to which this NIC belongs
* `node_count`
  * (Optional) The number of Nodes to create. default = 1
* `delete_os_disk_on_termination`
  * (Optional) Flag to enable deletion of the OS disk VHD blob or managed disk when the VM is deleted, defaults to true.
* `vm_os_id`
  * (Optional) The resource ID of the image that you want to deploy if you are using a custom image.
* `vm_os_publisher`
  * (Required, when not using image resource) Specifies the publisher of the image used to create the virtual machine. Changing this forces a new resource to be created.  default     = "Canonical"
* `vm_os_offer`
  * (Required, when not using image resource) Specifies the offer of the image used to create the virtual machine. Changing this forces a new resource to be created.  default     = "UbuntuServer"
* `vm_os_sku`
  * (Required, when not using image resource) Specifies the SKU of the image used to create the virtual machine. Changing this forces a new resource to be created. default     = "16.04-LTS"
* `vm_os_version`
  * (Optional) Specifies the version of the image used to create the virtual machine. Changing this forces a new resource to be created. default     = "latest"
* `managed_disk_type`
  * (Optional) Specifies the type of managed disk to create. Value you must be either Standard\_LRS or Premium\_LRS. Cannot be used when vhd\_uri is specified.  default = "Standard\_LRS"
* `hostname`
  * (Optional) Hostname to use for the virtual machine. Uses vmName if not provided.
* `admin_username`
  * (Optional) Specifies the name of the administrator account.  default = "linuxadmin"
* `custom_data`
  * (Optional) Specifies custom data to supply to the machine. On linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes.


Attribute Reference
-------------------

The following attributes are exported:


* `admin_username`
  * Admin username of the SSH User for each node created.
* `node_private_ips`
  * private ip addresses of the vm nics.
* `node_names`
  * List of the names of each virtual machine.
* `vm_ids`
  * Virtual machine ids created.
* `availability_set_id`
  * Id of the availability set where the vms are provisioned.
* `availability_set_name`
  * Name of the availability set where the vms are provisioned.

Notes
-------

The backend\_address\_pool\_id requires the load balancer to be created before the linux\_vm can be created.

Contributors
------------

* [David Lewis](https://github.com/highwayoflife)

License
-------

[MIT](LICENSE)

