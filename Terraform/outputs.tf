# Output the IP addresses discovered for each virtual machine.
# This exposes the DHCP lease addresses assigned to each VM's primary network interface.
output "vm_ips" {
  # Human-readable description of what this output contains.
  description = "Discovered addresses from libvirt DHCP leases (one list per VM)."
  # Build a map keyed by VM name, where each value is the list of IP addresses.
  value = {
    for name, domain in libvirt_domain.vm :
    name => domain.network_interface[0].addresses
  }
}

# Output the list of VM names in sorted order.
output "vm_names" {
  # Sort the VM names alphabetically before returning them.
  value = sort(keys(libvirt_domain.vm))
}