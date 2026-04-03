{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  blinkCmpPkg = inputs.blink-cmp.packages.${system}.blink-cmp;
  treesitterPkg = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  treesitterContextPkg = pkgs.vimPlugins.nvim-treesitter-context;
in {
  home.shellAliases = {
    nv = "nvim";
  };

  home.sessionVariables = {
    VISUAL = lib.mkForce "nvim";
    EDITOR = lib.mkForce "nvim";
    ALTERNATE_EDITOR = "vim";

    BLINK_CMP_NIX_PATH = "${blinkCmpPkg}";
    NVIM_TREESITTER_NIX_PATH = "${treesitterPkg}";
    TREESITTER_CONTEXT_NIX_PATH = "${treesitterContextPkg}";

    JDTLS_BIN = lib.getExe pkgs.jdt-language-server;
    LOMBOK_JAR = "${pkgs.lombok}/share/java/lombok.jar";
  };

  programs.neovim = {
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${system}.default;
    package = pkgs.neovim-unwrapped;
    extraPackages = with pkgs; [
      imagemagick
      ghostscript
      # need latex for snacks.image
      texlive.combined.scheme-basic
      tree-sitter
      tectonic
      mermaid-cli
    ];
    plugins = [
      treesitterPkg
      treesitterContextPkg
    ];
  };

  home.packages =
    (with pkgs; [
      # needed for some mason packages
      go
      gopls
      go-tools
      delve
      nodejs_22
      lombok
      uv
      stylua
      prettier
      prettierd
      hurl
      ruff
    ])
    ++ [
      blinkCmpPkg
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      pkgs.pngpaste
    ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/dotfiles/nvim";
}
