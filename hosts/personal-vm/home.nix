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
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
