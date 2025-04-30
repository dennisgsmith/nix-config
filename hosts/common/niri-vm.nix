# TODO: split up the wm and vm config
# also, these should probably be in a different dir, like "profiles" or something
{
  pkgs,
  ...
}:
{
  boot.initrd.kernelModules = ["virtio_gpu" "virtio_pci" "virtio"];
  hardware.graphics.enable = true;
  environment = {
    sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XDG_SESSION_TYPE = "wayland";
      WLR_BACKENDS = "drm";
      WLR_RENDERER_ALLOW_SOFTWARE = "1"; # fallback if no GPU
    };
    systemPackages = with pkgs; [
      wayland-utils
    ];
  };
  services.xserver.enable = false;
  services.seatd.enable = true;
  security.pam.services.niri = {};
  services.udev.extraRules = ''
    KERNEL=="card0", GROUP="video", MODE="0660"
  '';
  services.spice-vdagentd.enable = true;
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
