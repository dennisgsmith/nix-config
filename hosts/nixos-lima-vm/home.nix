{
  outputs,
  username,
  ...
}: {
  imports = [
    ../common/home.nix
    ../common/docker.nix
    outputs.homeManagerModules.neovim-nixos-patch
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
    extraConfig = {
      safe = {
        directory = ["/etc/nixos"];
      };
    };
  };
}
