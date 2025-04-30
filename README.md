# nix-config

My Nix system configurations

To use the standalone neovim package on a system without nix installed, run:

```sh
docker build -t nvim .
docker run -it -v $(pwd):/work -w /work nvim
```
