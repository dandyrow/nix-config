# NixOS configuration for guests running inside a virtual machine.
# Import this module in addition to the role module (desktop/server) for any
# host that runs as a VM. Do not import it for bare-metal hosts.
{ ... }: {
  # QEMU guest agent — enables the hypervisor to communicate with the guest
  # for clean shutdown, time synchronisation, and SPICE clipboard/file transfer.
  services.qemuGuest.enable = true;
}
