# Authored directly from known hardware (HP Spectre x360, Kaby Lake G).
#
# fileSystems is intentionally absent — disko generates it from disk-config.nix.
{ lib, ... }: {
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  # kvm-intel is a post-boot module (not needed in initrd).
  boot.kernelModules = [ "kvm-intel" ];
}
