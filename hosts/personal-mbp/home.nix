{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../common/home.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    packages = with pkgs; [ lima ]; # machine-specific packages
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
