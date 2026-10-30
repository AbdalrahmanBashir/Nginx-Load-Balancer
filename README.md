# Nginx Load Balancer

### This is my starting point for understanding architecture and building infrastructuer. The goal here is to set up three internal service instances behind an Nginx load balancer that handles both traffic distribution and TLS termination.

### Since I do not want to spend budget on a real domain name or cloud resources right now, I am building everything locally using KVM virtual machines. I will be documenting the entire process along the way using Terraform to provision the VMs and Ansible to automate the configuration. To make the TLS offloading actually work in a local environment, I am also going to set up an internal Certificate Authority (CA).

## Terraform project

### 10-29-2026: I set up the Terraform project to provision the local KVM virtual machines. During deployment, I ran into three issues:

1. **QEMU permission denied on the base image**

	Terraform could not create the VMs because the confined QEMU process could not read the image in `/mnt/data/vm/` (which is mounted to a separate NVMe drive on the host for performance), despite standard file permissions being correct. For this local lab, I edited `/etc/libvirt/qemu.conf` and set `security_driver = "none"` to bypass that confinement.

2. **VM boot hang and Terraform timeout**

	The VMs froze at `Probing EDD (edd=off to disable)... ok` after GRUB and then timed out. The generic QEMU CPU model lacked instruction sets needed by the Rocky Linux 10 kernel. I added a `cpu` block to the `libvirt_domain` Terraform resource and set `mode = "host-passthrough"`, allowing the VMs to boot.

3. **Terraform output showed only IPv6 addresses**

	The VMs had IPv4 addresses (`192.168.122.x`), but `terraform output` showed only local IPv6 addresses (`fe80::`). `wait_for_lease` detected IPv6 before the IPv4 DHCP handshake completed. I ran `terraform apply -refresh-only` to refresh Terraform's state from libvirt and pick up the IPv4 addresses