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

  # kvm-intel: post-boot virtualisation module.
  # rtsx_pci + rtsx_pci_sdmmc: Realtek PCIe SD card reader (RTS522A).
  boot.kernelModules = [ "kvm-intel" "rtsx_pci" "rtsx_pci_sdmmc" ];
}
