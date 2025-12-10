{pkgs, ...}: {
  programs.lsd = {
    enable = true;
    settings.color.when = "never";
  };

  home.shellAliases = {
    diff = "difft";
    search = "rg -p --glob '!node_modules/*'  $@";
  };

  home.packages = with pkgs; [
    devenv
    difftastic
    fzf
    htop
    hunspell
    iftop
    jq
    ripgrep
    tree
    unrar
    unzip
    vim
  ];

  home.sessionVariables = {
    VISUAL = "vim";
    EDITOR = "vim";
    HISTIGNORE = "pwd:ls:cd";
    HISTSIZE = 10000;
    HISTFILESIZE = 100000;
    PATH = "$HOME/.local/share/bin:$PATH";
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#888888";
  };
}
