{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;
  };
  home.packages = with pkgs; [
    nerd-fonts.iosevka
  ];
  xdg.configFile."ghostty/config".source = ./config;
}
