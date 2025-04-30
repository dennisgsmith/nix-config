{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
  ];

  nixpkgs.overlays = [inputs.niri.overlays];

  home.packages = with pkgs; [
    rofi-wayland
    wezterm
    chromium
  ];

  programs.niri = {
    enable = true;
    settings = {
      outputs."eDP-1".scale = 0.5;
      input.touchpad.natural-scroll = true;
      input.mouse.natural-scroll = true;
      binds = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";
      in {
        # First Key Row
        "Alt+Space".action = spawn "rofi" "-show" "drun";
        "Alt+W".action = spawn "wezterm";
        "Alt+E".action = spawn "chromium";
        "Alt+R".action = close-window;

        # Quit Niri
        "Alt+Shift+Q".action = quit;

        # # Lock Session
        # "Super+L".action = spawn "${pkgs.systemd}/bin/loginctl" "lock-session";

        # Screenshotting
        "Print".action = screenshot;

        # Workspackes
        "Alt+0".action = focus-workspace 0;
        "Alt+1".action = focus-workspace 1;
        "Alt+2".action = focus-workspace 2;
        "Alt+3".action = focus-workspace 3;
        "Alt+4".action = focus-workspace 4;
        "Alt+5".action = focus-workspace 5;
        "Alt+6".action = focus-workspace 6;
        "Alt+7".action = focus-workspace 7;
        "Alt+8".action = focus-workspace 8;
        "Alt+9".action = focus-workspace 9;

        # Special Keys
        "XF86AudioRaiseVolume".action = sh "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        "XF86AudioLowerVolume".action = sh "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
        "XF86AudioMute".action = sh "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      };
    };
  };
}
