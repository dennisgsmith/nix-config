{
  pkgs,
  outputs,
  lib,
  ...
}: let
  sysPackages = builtins.getAttr pkgs.system outputs.packages;
in {
  home.shellAliases = {
    nv = "nvim";
  };

  home.sessionVariables = {
    VISUAL = lib.mkForce "nvim";
    EDITOR = lib.mkForce "nvim";
    ALTERNATE_EDITOR = "vim";
  };

  # use standalone neovim from custom package
  home.packages = [sysPackages.neovim];
}
