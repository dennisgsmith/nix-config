{
  lib,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./.;
          file = "p10k.zsh";
      }
    ];
    envExtra = ''
      EDITOR=vim
      ${lib.optionalString (lib.strings.hasSuffix "darwin" pkgs.system) "export PATH=/opt/homebrew/bin:$PATH"}
      autoload edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
    '';
  };
}
