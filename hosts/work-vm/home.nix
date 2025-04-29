{username, ...}: {
  imports = [
    ../common/home.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "smith_dennis@bah.com";
  };
}
