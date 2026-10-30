# Name of the libvirt storage pool used for the Rocky Linux base image and VM disks.
variable "pool_name" {
  description = "Existing libvirt pool for the Rocky Linux image and VM disks."
  type        = string
  default     = "pool-1"
}

# Base qcow2 image name used as the template for creating cloned VMs.
variable "base_volume_name" {
  description = "Rocky Linux goled image with ks."
  type        = string
  default     = "rocky10-terraform-base.qcow2"
}

# Libvirt network that provides DHCP and connectivity for the virtual machines.
variable "network_name" {
  description = "Name of an existing active libvirt network with dhcp enabled."
  type        = string
  default     = "default"
}

# Path to the public SSH key that will be added to each VM for labadmin access.
variable "ssh_public_key_path" {
  description = "Public SSH key to install into each clone's labadmin account."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

# Definition of the VMs to create, keyed by hostname and specifying memory and CPU counts.
variable "vms" {
  description = "VM specifications; each map key is its VM hostname."
  type = map(object({
    memory_mb = number
    vcpus     = number
  }))
  default = {
    # VM 1 configuration.
    rocky-tf-01 = { memory_mb = 2048, vcpus = 2 }
    # VM 2 configuration.
    rocky-tf-02 = { memory_mb = 2048, vcpus = 2 }
    # VM 3 configuration.
    rocky-tf-03 = { memory_mb = 2048, vcpus = 2 }
    # VM 4 configuration.
    rocky-tf-04 = { memory_mb = 2048, vcpus = 2 }
  }
}