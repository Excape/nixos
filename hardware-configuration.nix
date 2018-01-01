{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" "acpi-call" ];
  boot.extraModulePackages = [ ];

  # setup LUKS
  boot.initrd.luks.devices = [
    { name = "luksroot";
      device = "/dev/disk/by-uuid/bc4f02fe-ff1e-4f50-a054-f1028b08b8f7";
      preLVM = true;
    }
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b66a3a6a-3466-4a20-8daf-58d4fa482a1c";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/b66a3a6a-3466-4a20-8daf-58d4fa482a1c";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F46C-EA6B";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/87e49d1c-50e8-45b6-a2f4-85b7cd4fb99b"; }
    ];

  nix.maxJobs = lib.mkDefault 4;

  # handled by tlp
  #  powerManagement.cpuFreqGovernor = "powersave";
}
