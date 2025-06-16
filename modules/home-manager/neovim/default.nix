{
  pkgs,
  outputs,
  config,
  lib,
  ...
}: {
  home.shellAliases = {
    nv = "nvim";
  };

  home.sessionVariables = {
    VISUAL = lib.mkForce "nvim";
    EDITOR = lib.mkForce "nvim";
    ALTERNATE_EDITOR = "vim";
  };

  home.packages = with pkgs; [
    neovim
    # needed for some mason packages
    cargo
    go
    nodejs_22
    uv
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/dotfiles/nvim";
}
