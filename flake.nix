{
  description = "nixos / nix-darwin / home manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.brew-src.url = "github:Homebrew/brew/5.1.1";
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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    blink-cmp = {
      url = "github:saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    username = "dennissmith";

    mkPkgs = platform:
      import nixpkgs {
        localSystem = {system = platform;};
        config.allowUnfree = true;
      };
  in {
    packages = forAllSystems (
      platform:
        import ./pkgs {
          inherit inputs;
          pkgs = mkPkgs platform;
        }
    );

    formatter = forAllSystems (platform: nixpkgs.legacyPackages.${platform}.alejandra);

    overlays = import ./overlays {inherit inputs;};

    nixosModules = import ./modules/nixos;
    darwinModules = import ./modules/darwin;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      nixos-lima-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/nixos-lima-vm/configuration.nix];
      };

      utm-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/utm-vm/configuration.nix];
      };
    };

    darwinConfigurations = {
      personal-mbp = nix-darwin.lib.darwinSystem {
        specialArgs = {inherit inputs outputs;};
        system = "aarch64-darwin";
        modules = [./hosts/personal-mbp/configuration.nix];
      };
    };

    homeConfigurations = {
      "${username}@personal-mbp" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {hostPlatform = "aarch64-darwin";};
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/personal-mbp/home.nix];
      };

      "${username}@nixos-lima-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {hostPlatform = "aarch64-linux";};
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/nixos-lima-vm/home.nix];
      };

      "${username}@utm-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {hostPlatform = "aarch64-linux";};
        extraSpecialArgs = {inherit inputs outputs username;};
        modules = [./hosts/utm-vm/home.nix];
      };
    };
  };
}
