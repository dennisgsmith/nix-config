{
  inputs,
  outputs,
  ...
}:
  let username = "dennissmith"; hostname = "lima-vm"; in
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
  ]
  ++ builtins.attrValues outputs.nixosModules;

  # FIXME: Add the rest of your current configuration

  networking.hostName = hostname;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${username} = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "pass";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKsgG1dXcJpHmB2nypeOfuF4XrVagJUZ9wtNhal22n1 dennisgsmith12@gmail.com"
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
