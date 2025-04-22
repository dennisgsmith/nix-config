{ pkgs, ... }:
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
    VISUAL="nvim";
    EDITOR="nvim";
    ALTERNATE_EDITOR="vim";
  };
}
