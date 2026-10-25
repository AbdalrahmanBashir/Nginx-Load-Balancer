# Nginx Load Balancer

### This is my starting point for understanding architecture and building infrastructuer. The goal here is to set up three internal service instances behind an Nginx load balancer that handles both traffic distribution and TLS termination.

### Since I do not want to spend budget on a real domain name or cloud resources right now, I am building everything locally using KVM virtual machines. I will be documenting the entire process along the way using Terraform to provision the VMs and Ansible to automate the configuration. To make the TLS offloading actually work in a local environment, I am also going to set up an internal Certificate Authority (CA).