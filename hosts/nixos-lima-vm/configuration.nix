{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  username = "dennissmith";
  hostname = "nixos-lima-vm";
in {
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    inputs.nixos-lima.nixosModules.lima

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs outputs username;
      };
      home-manager.backupFileExtension = "hm.bak";
    }

    ../common/configuration.nix
    ../common/docker-client.nix
    ../common/docker-server.nix
    ../common/locale.nix
    outputs.nixosModules.openssh
  ];

  services.lima.enable = true;

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = hostname;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [
      "x-systemd.growfs"
      "x-initrd.mount"
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZCmGORbibeRZ322oOg+FNhUiBqqW4PEaYMRyLQ3yli dennisgsmith12@gmail.com"
    ];
  };

  system.stateVersion = "23.11";
}
