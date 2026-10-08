{
  username,
  outputs,
  ...
}: {
  imports = [
    ../common/home.nix
    outputs.homeManagerModules.ghostty
    outputs.homeManagerModules.codex
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    packages = [
      outputs.packages.aarch64-darwin.monome-druid
    ];
  };

  programs.git = {
    enable = true;
    signing.format = null;
    settings.user = {
      name = "Dennis Smith";
      email = "dennisgsmith12@gmail.com";
    };
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    includes = [
      "~/.lima/*/ssh.config"
    ];

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      github = {
        host = "github.com";
        user = "dennisgsmith";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
