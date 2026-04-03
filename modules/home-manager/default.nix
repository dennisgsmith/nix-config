{
  bash = import ./bash;
  "cli-config" = import ./cli-config;
  direnv = import ./direnv;
  neovim = import ./neovim;
  neovim-nixos-patch = import ./neovim/nixos-patch.nix;
  niri = import ./niri;
  wezterm = import ./wezterm;
  ghostty = import ./ghostty;
  zsh = import ./zsh;
}
