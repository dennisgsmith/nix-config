### https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../common/home.nix
    ../common/gnome.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
