# Create one libvirt virtual machine for each entry in the VM map.
resource "libvirt_domain" "vm" {
  # Use each map key and value to configure an individual VM.
  for_each = var.vms

  # Set the VM's name, memory, CPU count, and disabled autostart behavior.
  name      = each.key
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpus
  autostart = false

  # Pass the host CPU features through to the virtual machine.
  cpu {
    mode = "host-passthrough"
  }

  # Attach this VM's cloud-init seed disk and enable the QEMU guest agent.
  cloudinit  = libvirt_cloudinit_disk.seed[each.key].id
  qemu_agent = true

  # Attach the root volume provisioned for this VM.
  disk {
    volume_id = libvirt_volume.root[each.key].id
  }

  # Connect the VM to the configured virtual network and wait for an address lease.
  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
  }

  # Configure a serial console on a pseudo-terminal.
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Enable a SPICE graphics display that listens on an automatically assigned port.
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}