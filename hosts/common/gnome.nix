{pkgs, ...}: {
  dconf = {
    settings = {
      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
        screensaver = ["<Alt><Super>l"];
      };
      # Custom keyboard shorcuts. Needs both to be told that the custom exists, and then below to be told what the custom is.
      # Tell it that the custom exists here, follow its example of "custom0", "custom1" etc.
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

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
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = true;
      };

      ### Configure general Gnome settings here
      "org/gnome/desktop/interface".enable-hot-corners = false;
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.space-bar
  ];
}
