{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
  };
  home.packages = with pkgs; [
    iosevka
  ];
  xdg.configFile."ghostty/config".source = ./config;
}
