{...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      # Commands that should be applied only for interactive shells.
      [[ $- == *i* ]] || return

      shopt -s histappend
      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
    '';
  };
}
