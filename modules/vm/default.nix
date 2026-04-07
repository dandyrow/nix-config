# NixOS configuration for guests running inside a virtual machine.
# Import this module in addition to the role module (desktop/server) for any
# host that runs as a VM. Do not import it for bare-metal hosts.
{ ... }: {
  services.qemuGuest.enable = true;
}
