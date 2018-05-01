variable "resource_group_name" {
  description = "(Required) The name of the resource group in which the resources will be created"
}

variable "location" {
  description = "(Optional) The location/region where the virtual machines will be created. Uses the location of the resource group by default."
  default     = ""
}

variable "subnet_id" {
  description = "(Required) The subnet id of the virtual network where the virtual machines will reside."
}

variable "tags" {
  type        = "map"
  description = "(Optional) A map of the tags to use on the resources that are deployed with this module. Tags will be merged with those defined by the resource group."

  default = {
    source = "Terraform"
  }
}

variable "os_disk_prefix" {
  description = "Optional os disk name prefix to use for managed disk attached to the virtual machine"
  default     = ""
}

variable "vm_nic_name" {
  description = "(Optional) Name of the Network interface for the VM"
  default     = ""
}

variable "vm_name" {
  description = "Name of the virtual machine."
  default     = "linuxcomputevm"
}

variable "availability_set_name" {
  description = "(Optional) Name of the availability set. Default is derived from vm_name"
  default     = ""
}

variable "vm_size" {
  description = "Azure VM Size to use. See: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "(Optional) Specifies the size of the os disk in gigabytes. Default 32 GB"
  default     = "32"
}

variable "admin_public_key" {
  description = "Optionally supply the admin public key. If provided, will override variable: sshKey"
  default     = ""
}

variable "ssh_key_path" {
  description = "Path to the public key to be used for ssh access to the VM. Default is ~/.ssh/id_rsa.pub. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "use_loadbalancer" {
  description = "When set to true, the Virtual Network Interfaces will be assigned to the backend_address_pool_id. Default = true"
  default     = true
}

variable "backend_address_pool_id" {
  description = "(Optional) List of Load Balancer Backend Address Pool IDs references to which this NIC belongs"
  default     = ""
}

variable "node_count" {
  description = "The number of Nodes to create"
  default     = 1
}

variable "delete_os_disk_on_termination" {
  description = "(Optional) Flag to enable deletion of the OS disk VHD blob or managed disk when the VM is deleted, defaults to true."
  default     = true
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image."
  default     = ""
}

variable "vm_os_publisher" {
  description = "(Required, when not using image resource) Specifies the publisher of the image used to create the virtual machine. Changing this forces a new resource to be created."
  default     = "Canonical"
}

variable "vm_os_offer" {
  description = "(Required, when not using image resource) Specifies the offer of the image used to create the virtual machine. Changing this forces a new resource to be created."
  default     = "UbuntuServer"
}

variable "vm_os_sku" {
  description = "(Required, when not using image resource) Specifies the SKU of the image used to create the virtual machine. Changing this forces a new resource to be created."
  default     = "16.04-LTS"
}

variable "vm_os_version" {
  description = "(Optional) Specifies the version of the image used to create the virtual machine. Changing this forces a new resource to be created."
  default     = "latest"
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Value you must be either Standard_LRS or Premium_LRS. Cannot be used when vhd_uri is specified."
  default     = "Standard_LRS"
}

variable "hostname" {
  description = "Hostname to use for the virtual machine. Uses vmName if not provided."
  default     = ""
}

variable "admin_username" {
  description = "Specifies the name of the administrator account."
  default     = "linuxadmin"
}

variable "custom_data" {
  description = "(Optional) Specifies custom data to supply to the machine. On linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes."
  default     = ""
}

variable "data_disk" {
  description = "Create Virtual Machine with attached managed data disk. Default false"
  default     = "false"
}

variable "managed_disk_prefix" {
  description = "Specifies the name of the managed disk. Changing this forces a new resource to be created."
  default     = "md"
}

variable "managed_disk_storage_account_type" {
  description = "(Optional) The type of storage to use for the managed disk. Allowable values are Standard_LRS or Premium_LRS. Default = Standard_LRS."
  default     = "Standard_LRS"
}

variable "managed_disk_create_option" {
  description = "(Optional) The method to use when creating the managed disk. Values are Import, Empty, Copy, and FromImage. Default = Empty."
  default     = "Empty"
}

variable "managed_disk_size_gb" {
  description = "(Optional) Specifies the size of the os disk in gigabytes. Default 100 GB"
  default     = "100"
}

variable "boot_diagnostics_storage_uri" {
  default     = ""
  description = "Blob endpoint for the storage account to hold the virtual machine's diagnostic files. This must be the root of a storage account, and not a storage container."
}
