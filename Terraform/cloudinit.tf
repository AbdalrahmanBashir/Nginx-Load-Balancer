# Create a cloud-init seed ISO for each VM in var.vms.
resource "libvirt_cloudinit_disk" "seed" {
  for_each = var.vms

  name = "${each.key}-seed.iso"
  pool = var.pool_name

  meta_data = yamlencode({
    "instance-id"    = each.key
    "local-hostname" = each.key
  })

  # Configure the VM's initial hostname, account access, and SSH authentication.
  user_data = "#cloud-config\n${yamlencode({
    hostname         = each.key
    manage_etc_hosts = true
    disable_root     = true
    ssh_pwauth       = false
    users = [{
      name                = "labadmin"
      groups              = ["wheel"]
      shell               = "/bin/bash"
      sudo                = "ALL=(ALL) NOPASSWD:ALL"
      lock_passwd         = true
      ssh_authorized_keys = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
    }]
  })}"
}