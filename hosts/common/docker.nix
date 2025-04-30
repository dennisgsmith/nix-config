{
  pkgs,
  ...
}:
{
  # docker
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    docker-buildx
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    extraOptions = "--experimental";
  };
}
