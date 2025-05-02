# nix-config

My Nix system configurations

To use the standalone neovim package on a system without nix installed, run:

```sh
# expects to be installed at home location
cd $HOME/nix-config
docker build -t nvim .

# run dedicated container running as daemon
# it also mounts nix-config to allow for easy
# changes to the neovim configuration without
# needing to rebuild.
# Make sure $HOME/nix-config is set up as expected.
docker run -d \
    --name project_dev_daemon \
    -v nvim_nix_store:/nix/store \
    -v $HOME/nix-config/:/tmp/build/ \
    -v $(pwd):/work \
    -w /work \
    nvim

# then exec into the nvim daemon
docker exec -it project_dev_daemon

# alias an exec command, calling some macOS
# system utils to get the current polarity and 
# set the corresponding neovim theme
alias work="docker exec -it project_dev_daemon /result/bin/nvim \
    -c \"set background=\$(defaults read -g AppleInterfaceStyle &>/dev/null && echo dark || echo light)\""

# optional, for ephemeral container in the current dir
alias dnv="docker run -it -v \$(pwd):/work -w /work nvim \
    -c \"set background=\$(defaults read -g AppleInterfaceStyle &>/dev/null && echo dark || echo light)\"
```
