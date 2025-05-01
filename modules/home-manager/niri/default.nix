{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
  ];

  nixpkgs.overlays = [inputs.niri.overlays];

  home.packages = with pkgs; [
    rofi-wayland
    wezterm
    chromium
  ];

  programs.niri = {
    enable = true;
    config = builtins.readFile ./config.kdl;
  };
}
