# nix-config

My Nix system configurations

To use the standalone neovim package in docker (on a system without nix installed), run:

```sh
# assumes $HOME/nix-config
cd $HOME/nix-config
docker build -t nvim .
```

this can be added to your rc file (assumes macOS):

```sh
get_system_theme() {
    if defaults read -g AppleInterfaceStyle &>/dev/null; then
        echo "set background=dark"
    else
        echo "set background=light"
    fi
}

build_neovim_image() {
    docker build -t neovim_image $HOME/nix-config
}

# temporary dev container
# usage: dnv [host project mount] [-- nvim args...]
dnv() {
    local usage="Usage: dnv [host project mount] [-- nvim args...]"

    # help flag?
    case "$1" in
      -h|--help)
        echo "$usage" >&2
        return 0
        ;;
    esac

    # pick a working directory: either $1 or cwd
    local workdir
    if [ $# -gt 0 ]; then
      workdir="$1"
      shift
    else
      workdir="$(pwd)"
    fi

    docker run --rm -it \
        -v "$workdir":/work \
        -w /work \
        neovim_image \
        -c "$(get_system_theme)" \
        "$@"
}

create_dev_container() {
    if [ $# -lt 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: create_dev_container <host project mount> <project name>" >&2
        return 1
    fi

    local workdir="$1"
    local name="$2"

    docker run -d \
        --name "$name" \
        -v neovim_nix_store:/nix/store \
        -v "$HOME/nix-config/":/tmp/build/ \
        -v "$workdir":/work \
        -w /work \
        neovim_image
}

work() {
    local usage="Usage: work <project name>"

    # help?
    case "$1" in
      -h|--help)
        echo "$usage" >&2
        return 0
        ;;
    esac

    # require exactly one non-empty arg
    if [ -z "$1" ]; then
        echo "$usage" >&2
        return 1
    fi

    docker exec -it "$1" /result/bin/nvim "-c $(get_system_theme)"
}
```
