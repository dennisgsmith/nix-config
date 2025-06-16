{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  programs.home-manager.enable = true;

  imports = with outputs.homeManagerModules; [
    bash
    cli-config
    direnv
    neovim
    wezterm
    zsh
  ];

  home = {
    sessionVariables = {
      NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    };

    packages = with pkgs; [
      bat
      btop
      coreutils
      cmake
      direnv
      gnumake
      neofetch
      pandoc
      postgresql
      sqlite
      tree
      websocat
      zip
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.11";
  };
}
