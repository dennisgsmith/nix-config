# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  monome-druid = pkgs.callPackage ./monome-druid.nix { };
}
