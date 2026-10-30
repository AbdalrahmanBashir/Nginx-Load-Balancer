# Define a root disk volume for every VM in the configured VM map.
resource "libvirt_volume" "root" {
  # Create one volume instance for each VM entry.
  for_each = var.vms

  # Set the volume name from the VM key and qcow2 extension.
  name             = "${each.key}.qcow2"
  # Place the volume in the configured storage pool.
  pool             = var.pool_name
  # Specify the qcow2 disk image format.
  format           = "qcow2"
  # Use the configured base volume as the source image.
  base_volume_name = var.base_volume_name
  # Resolve the source image in the configured storage pool.
  base_volume_pool = var.pool_name
}