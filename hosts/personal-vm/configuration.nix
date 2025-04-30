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

  boot.initrd.kernelModules = ["virtio_gpu" "virtio_pci" "virtio"];

  hardware.graphics.enable = true;

  environment = {
    sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XDG_SESSION_TYPE = "wayland";
      WLR_BACKENDS = "drm";
      WLR_RENDERER_ALLOW_SOFTWARE = "1"; # fallback if no GPU
    };
    systemPackages = with pkgs; [
      docker
      docker-compose
      docker-buildx
      wayland-utils
    ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    extraOptions = "--experimental";
  };

  services.seatd.enable = true;
  security.pam.services.niri = {};

  services.udev.extraRules = ''
    KERNEL=="card0", GROUP="video", MODE="0660"
  '';

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

  services.xserver.enable = false;

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
