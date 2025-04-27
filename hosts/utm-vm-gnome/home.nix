### https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../common/home.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      screensaver = [ "<Alt><Super>l" ];
    };
    # Custom keyboard shorcuts. Needs both to be told that the custom exists, and then below to be told what the custom is.
    # Tell it that the custom exists here, follow its example of "custom0", "custom1" etc.
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
  };

  ### Configure general Gnome settings here
  dconf.settings."org/gnome/desktop/interface".enable-hot-corners = false;

  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.space-bar
    gnomeExtensions.disable-unredirect-fullscreen-windows # workaround
  ];

  ### Configure Gnome Extensions
  # Enable specific Gnome extensions
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      # `gnome-extensions list` for a list
      enabled-extensions = [
        "caffeine@patapon.info"
        "space-bar@luchrioh"
        "unredirect@vaina.lt"
      ];
    };
    "org/gnome/shell/extensions/caffeine" = {
      enable-fullscreen = false;
    };
  };

  programs.git = {
    enable = true;
    userName = "Dennis Smith";
    userEmail = "dennisgsmith12@gmail.com";
  };
}
