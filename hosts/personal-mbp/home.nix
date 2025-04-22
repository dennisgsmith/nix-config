{
  outputs,
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
    # packages = with pkgs; [];
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
