{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  home.sessionVariables = {
    NIX_PATH=lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
  };

  programs.home-manager.enable = true;

  imports = with outputs.homeManagerModules; [
    bash
    cli-config
    direnv
    neovim
    wezterm
    zsh
  ];

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
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
  home.stateVersion = "23.11";
}
