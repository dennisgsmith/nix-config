{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  username = "dennissmith";
  hostname = "personal-vm";
in {
  imports = [
    ./hardware-configuration.nix
    # inputs.stylix.nixosModules.stylix
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
    ../common/niri-vm.nix
    ../common/docker.nix
    ../common/locale.nix
    outputs.nixosModules.openssh
  ];

  # stylix = {
  #   enable = true;
  #   autoEnable = false;
  #   # image = "";
  #   polarity = "dark";
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
  # };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  programs.zsh.enable = true;

  users.users = {
    ${username} = {
      initialPassword = "pass";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZCmGORbibeRZ322oOg+FNhUiBqqW4PEaYMRyLQ3yli dennisgsmith12@gmail.com"
      ];
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "docker"
        "networkmanager"
        "video"
        "input"
        "seat"
      ];
    };
  };

  system.stateVersion = "23.11";
}
