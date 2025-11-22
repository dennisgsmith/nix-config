{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    extraConfig = builtins.readFile ./config;
  };
  home.packages = with pkgs; [
    iosevka
  ];
}
