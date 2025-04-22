{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../common/home.nix
  ];

  hm.wezterm.enable = true;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    # packages = with pkgs; [];
  };
}
