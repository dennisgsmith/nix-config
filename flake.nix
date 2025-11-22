{
  description = "nixos / nix-darwin / home manager configurations";

inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

  nix-darwin.url = "github:nix-darwin/nix-darwin/master";
  nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  niri.url = "github:sodiboo/niri-flake";
  stylix.url = "github:danth/stylix";

  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  nur.url = "github:nix-community/NUR";

  # nix-homebrew with brew pinned to 4.6.11
  nix-homebrew = {
    url = "github:zhaofengli-wip/nix-homebrew";
    inputs.brew-src.url = "github:Homebrew/brew/4.6.11";
  };

  homebrew-bundle = {
    url = "github:homebrew/homebrew-bundle";
    flake = false;
  };
  homebrew-core = {
    url = "github:homebrew/homebrew-core";
    flake = false;
  };
  homebrew-cask = {
    url = "github:homebrew/homebrew-cask";
    flake = false;
  };
};

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    username = "dennissmith";
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system:
      import ./pkgs {
        inherit inputs;
        pkgs = nixpkgs.legacyPackages.${system};
      });

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    nixosModules = import ./modules/nixos;
    darwinModules = import ./modules/darwin;
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      personal-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/personal-vm/configuration.nix];
      };
      work-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/work-vm/configuration.nix];
      };
    };

    # Nix-darwin configuration entrypoint
    # Available through 'darwin-rebuild switch --flake .#your-hostname'
    darwinConfigurations = {
      personal-mbp = nix-darwin.lib.darwinSystem {
        specialArgs = {inherit inputs outputs;};
        system = "aarch64-darwin";
        modules = [./hosts/personal-mbp/configuration.nix];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "${username}@personal-mbp" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/personal-mbp/home.nix];
      };
      "${username}@personal-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/personal-vm/home.nix];
      };
      "${username}@work-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/work-vm/home.nix];
      };
    };
  };
}
