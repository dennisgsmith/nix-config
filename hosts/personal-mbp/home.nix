{
  pkgs,
  username,
  outputs,
  ...
}: {
  imports = [
    ../common/home.nix
    outputs.homeManagerModules.ghostty
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
  };

  programs.git = {
    enable = true;
    signing.format = null;
    settings.user = {
      name = "Dennis Smith";
      email = "dennisgsmith12@gmail.com";
    };
  };
}
