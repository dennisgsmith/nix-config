{
  pkgs,
  lib,
  ...
}:
{
  home.shellAliases = {
    nv = "nvim";
  };
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
    ];
  };

  # xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-config/dotfiles/nvim/";

  home.sessionVariables = {
    VISUAL = lib.mkForce "nvim";
    EDITOR = lib.mkForce "nvim";
    ALTERNATE_EDITOR = "vim";
  };
}
