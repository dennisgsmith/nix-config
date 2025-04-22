{ pkgs, ... }:
{
  home.shellAliases = {
    diff = "difft";
    ls =  "lsd";
    search = "rg -p --glob '!node_modules/*'  $@";
  };
  home.packages = with pkgs; [
    difftastic
    lsd
    htop
    hunspell
    iftop
    iosevka
    jq
    ripgrep
    tree
    unrar
    unzip
  ];
  home.sessionVariables = {
    PATH = "$HOME/.local/share/bin:$PATH";
    HISTIGNORE = "pwd:ls:cd";
    HISTSIZE = 10000;
  };
}
