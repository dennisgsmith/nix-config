{ pkgs, ... }:
{
  home.shellAliases = {
    diff = "difft";
    ls = "lsd";
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
    vim
    unrar
    unzip
  ];
  home.sessionVariables = {
    VISUAL = "vim";
    EDITOR = "vim";
    HISTIGNORE = "pwd:ls:cd";
    HISTSIZE = 10000;
    HISTFILESIZE = 100000;
    PATH = "$HOME/.local/share/bin:$PATH";
  };
}
