{
  outputs,
  username,
  ...
}: {
  imports = [
    ../common/home.nix
    outputs.homeManagerModules.neovim-nixos-patch
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    sessionVariables = {
      TERM = "xterm-256color";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      safe = {
        directory = ["/etc/nixos"];
      };
      user = {
        name = "Dennis Smith";
        email = "dennisgsmith12@gmail.com";
      };
    };
  };
}
