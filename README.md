Azure Linux Virtual Machine Terraform Module
============================================

Deploys 1+ Virtual Machines to your provided VNet
This Terraform module deploys Virtual Machines in Azure with the following characteristics:

* All VMs use managed disks
* VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.subnet_id`.

Usage
-----

```hcl
resource "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
  location = "westus"

  tags = {
    environment = "test"
    costcenter  = "12345"
    ppm         = "N/A"
    fgid        = "1234"
    appname     = "myapp"
  }
}

data "azurerm_subnet" "subnet" {
  name                  = "${var.subnet_name}"
  virtual_network_name  = "${var.vnet_name}"
  resource_group_name   = "${var.vnet_resource_group_name}"
}

module "loadbalancer" {
  source  = "git::ssh://git@github.com/deck15/terraform-azurerm-loadbalancer"
  type    = "private"
  prefix  = "MyTerraformLB"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  subnet_id                     = "${data.azurerm_subnet.subnet.id}"
  private_ip_address_allocation = "Static"
  private_ip_address            = "10.18.160.50"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    https = ["443", "Tcp", "443"]
  }
}

module "linux_vm" {
  source  = "git::ssh://git@github.com/deck15/terraform-azurerm-linux-vm"

  resource_group_name = "${azurerm_resource_group.rg.name}"
  node_count          = "${var.node_count}"
  subnet_id           = "${data.azurerm_subnet.subnet.id}"
  vm_name             = "${var.vm_name}"
  backend_address_pool_id = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"

  admin_username      = "${var.admin_username}"
  ssh_key_path        = "${var.ssh_key_path}"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| resource\_group\_name | (Required) The name of the resource group in which the resources will be created | string | n/a | yes |
| subnet\_id | (Required) The subnet id of the virtual network where the virtual machines will reside. | string | n/a | yes |
| admin\_public\_key | Optionally supply the admin public key. If provided, will override variable: sshKey | string | `""` | no |
| admin\_username | Specifies the name of the administrator account. | string | `"linuxadmin"` | no |
| availability\_set\_name | (Optional) Name of the availability set. Default is derived from vm_name | string | `""` | no |
| backend\_address\_pool\_id | (Optional) List of Load Balancer Backend Address Pool IDs references to which this NIC belongs | string | `""` | no |
| boot\_diagnostics\_storage\_uri | Blob endpoint for the storage account to hold the virtual machine's diagnostic files. This must be the root of a storage account, and not a storage container. | string | `""` | no |
| custom\_data | (Optional) Specifies custom data to supply to the machine. On linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes. | string | `""` | no |
| data\_disk | Create Virtual Machine with attached managed data disk. Default false | string | `"false"` | no |
| delete\_os\_disk\_on\_termination | (Optional) Flag to enable deletion of the OS disk VHD blob or managed disk when the VM is deleted, defaults to true. | string | `"true"` | no |
| hostname | Hostname to use for the virtual machine. Uses vmName if not provided. | string | `""` | no |
| location | (Optional) The location/region where the virtual machines will be created. Uses the location of the resource group by default. | string | `""` | no |
| managed\_disk\_create\_option | (Optional) The method to use when creating the managed disk. Values are Import, Empty, Copy, and FromImage. Default = Empty. | string | `"Empty"` | no |
| managed\_disk\_prefix | Specifies the name of the managed disk. Changing this forces a new resource to be created. | string | `"md"` | no |
| managed\_disk\_size\_gb | (Optional) Specifies the size of the os disk in gigabytes. Default 100 GB | string | `"100"` | no |
| managed\_disk\_storage\_account\_type | (Optional) The type of storage to use for the managed disk. Allowable values are Standard_LRS or Premium_LRS. Default = Standard_LRS. | string | `"Standard_LRS"` | no |
| managed\_disk\_type | Specifies the type of managed disk to create. Value you must be either Standard_LRS or Premium_LRS. Cannot be used when vhd_uri is specified. | string | `"Standard_LRS"` | no |
| node\_count | The number of Nodes to create | string | `"1"` | no |
| os\_disk\_prefix | Optional os disk name prefix to use for managed disk attached to the virtual machine | string | `""` | no |
| os\_disk\_size\_gb | (Optional) Specifies the size of the os disk in gigabytes. Default 32 GB | string | `"32"` | no |
| ssh\_key\_path | Path to the public key to be used for ssh access to the VM. Default is ~/.ssh/id_rsa.pub. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub | string | `"~/.ssh/id_rsa.pub"` | no |
| tags | (Optional) A map of the tags to use on the resources that are deployed with this module. Tags will be merged with those defined by the resource group. | map | `{ "source": "Terraform" }` | no |
| use\_loadbalancer | When set to true, the Virtual Network Interfaces will be assigned to the backend_address_pool_id. Default = true | string | `"true"` | no |
| vm\_name | Name of the virtual machine. | string | `"linuxcomputevm"` | no |
| vm\_nic\_name | (Optional) Name of the Network interface for the VM | string | `""` | no |
| vm\_os\_id | The resource ID of the image that you want to deploy if you are using a custom image. | string | `""` | no |
| vm\_os\_offer | (Required, when not using image resource) Specifies the offer of the image used to create the virtual machine. Changing this forces a new resource to be created. | string | `"UbuntuServer"` | no |
| vm\_os\_publisher | (Required, when not using image resource) Specifies the publisher of the image used to create the virtual machine. Changing this forces a new resource to be created. | string | `"Canonical"` | no |
| vm\_os\_sku | (Required, when not using image resource) Specifies the SKU of the image used to create the virtual machine. Changing this forces a new resource to be created. | string | `"16.04-LTS"` | no |
| vm\_os\_version | (Optional) Specifies the version of the image used to create the virtual machine. Changing this forces a new resource to be created. | string | `"latest"` | no |
| vm\_size | Azure VM Size to use. See: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs | string | `"Standard_B2s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin\_username |  |
| availability\_set\_id | id of the availability set where the vms are provisioned. |
| availability\_set\_name | Name of the availability set where the vms are provisioned. |
| node\_names |  |
| node\_private\_ips | private ip addresses of the vm nics |
| vm\_ids | Virtual machine ids created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Notes
-----

The backend\_address\_pool\_id requires the load balancer to be created before the linux\_vm can be created.

Contributors
------------

* [David Lewis](https://github.com/highwayoflife)

License
-------

[MIT](LICENSE)

