{
  pkgs,
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

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      imagemagick
      ghostscript
      # need latex for snacks.image
      texlive.combined.scheme-basic
      tree-sitter
      tectonic
      mermaid-cli
    ];
  };

  home.packages =
    (with pkgs; [
      # needed for some mason packages
      cargo
      go
      nodejs_22
      uv
    ])
    ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.pngpaste ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/dotfiles/nvim";
}
