# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs,
  inputs
}: {
  monome-druid = pkgs.callPackage ./monome-druid.nix { };
  neovim = (pkgs.callPackage ./neovim.nix { inherit inputs; }).neovim;
}
