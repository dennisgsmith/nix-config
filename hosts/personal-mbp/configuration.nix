{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  username = "dennissmith";
  hostname = "personal-mbp";
in {
  imports = [
    # home-manager
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs outputs username;
      };
      home-manager.backupFileExtension = "hm.bak";
    }
    # nix-homebrew
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = username;
        taps = {
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
        mutableTaps = false;
        package = inputs.nix-homebrew.inputs.brew-src // {
          name = "brew-4.6.11";
          version = "4.6.11";
        };
      };
    }
    ../common/configuration.nix
    outputs.darwinModules.macosSettings
  ];

  programs.zsh.enable = true;

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  networking.hostName = hostname;

  security.pam.services.sudo_local.touchIdAuth = true;

  ids.gids.nixbld = 350;

  # remote linux builder vm for docker
  nix.settings.extra-trusted-users = [
    username
    "@admin"
  ];

  nix.linux-builder = {
    enable = true;
    config.virtualisation = {
      darwin-builder = {
        diskSize = 40 * 1024;
        memorySize = 8 * 1024;
      };
      cores = 6;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      fswatch
      openssh
      sshfs
    ];
  };

  homebrew = {
    enable = true;
    brews = [
      "colima"
    ];
    casks = [
      "discord"
      "obsidian"
      "slack"
      "spotify"
      "utm"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "Logic Pro" = 634148309;
    };
  };

  system.primaryUser = "dennissmith";
  system.defaults.dock.persistent-apps = [
    {app = "/System/Applications/Calendar.app";}
    {app = "/System/Applications/App Store.app";}
    {app = "/System/Applications/Messages.app";}
    {app = "/System/Applications/Facetime.app";}
    {app = "/Applications/Safari.app";}
    {app = "/Applications/Discord.app";}
    {app = "/Applications/Logic Pro.app";}
    {app = "/Applications/Spotify.app";}
    {app = "/Applications/Obsidian.app";}
    {app = "${pkgs.ghostty-bin}/Applications/Ghostty.app";}
    {app = "/System/Applications/Utilities/Activity Monitor.app";}
    {app = "/System/Applications/System Settings.app";}
  ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
