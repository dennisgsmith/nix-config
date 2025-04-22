{
  inputs,
  outputs,
  ...
}:
  let username = "dennissmith"; hostname = "utm-vm"; in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs outputs username;
      };
    }
    ../common/configuration.nix
    outputs.nixosModules.openssh
    outputs.nixosModules.hyprland
  ];

  networking.hostName = hostname;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${username} = {
      initialPassword = "pass";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKsgG1dXcJpHmB2nypeOfuF4XrVagJUZ9wtNhal22n1 dennisgsmith12@gmail.com"
      ];
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
