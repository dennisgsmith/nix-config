{
  outputs,
  username,
  ...
}:
{
  imports = [
    ../common/home.nix
    outputs.homeManagerModules.wezterm
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    # packages = with pkgs; [];
  };
}
