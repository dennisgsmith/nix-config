{
  inputs,
  outputs,
  pkgs,
  ...
}:
  let username = "dennissmith"; hostname = "personal-mbp"; in
{
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
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
        mutableTaps = false;
      };
    }
    ../common/configuration.nix
    outputs.darwinModules.macosSettings
  ];

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  networking.hostName = hostname;

  security.pam.services.sudo_local.touchIdAuth = true;

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

  environment.systemPackages = with pkgs; [
    docker
    fswatch
    lima
    openssh
    sshfs
  ];

  homebrew = {
    enable = true;
    casks = [
      "discord"
      "obsidian"
      "slack"
      "spotify"
      "utm"
      "visual-studio-code"
      "vivaldi"
      "wezterm"
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

  system.defaults.dock.persistent-apps = [
      { app = "/System/Applications/Calendar.app"; }
      { app = "/System/Applications/App Store.app"; }
      { app = "/System/Applications/Messages.app"; }
      { app = "/System/Applications/Facetime.app"; }
      { app = "/Applications/Vivaldi.app"; }
      { app = "/Applications/Discord.app"; }
      { app = "/Applications/Logic Pro.app"; }
      { app = "/Applications/Spotify.app"; }
      { app = "/Applications/Obsidian.app"; }
      { app = "/Applications/UTM.app"; }
      { app = "/Applications/WezTerm.app"; }
      { app = "/System/Applications/Utilities/Activity Monitor.app"; }
      { app = "/System/Applications/System Settings.app"; }
  ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
