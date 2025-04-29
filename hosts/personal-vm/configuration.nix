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
    outputs.nixosModules.openssh
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = false;
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = username;
      };
    };
    desktopManager.gnome.enable = true;
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.spice-vdagentd.enable = true;

  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.zsh.enable = true;

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
  };

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
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
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
