{
  pkgs,
  ...
}:
{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    mako
    libnotify
    hyprpaper
    rofi-wayland
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
