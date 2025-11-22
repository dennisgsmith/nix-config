{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../common/home.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    packages = with pkgs; [
      docker
      docker-compose
      docker-buildx
      docker-credential-helpers
    ];
    sessionVariables = {
      DOCKER_HOST = "unix:///Users/${username}/.config/colima/default/docker.sock";
    };
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
