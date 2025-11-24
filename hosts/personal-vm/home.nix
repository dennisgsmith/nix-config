{
  outputs,
  username,
  ...
}: {
  imports = [
    ../common/home.nix
    outputs.homeManagerModules.niri
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Dennis Smith";
      email = "dennisgsmith12@gmail.com";
    };
  };
}
