FROM nixos/nix:latest

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

COPY . /tmp/build
WORKDIR /tmp/build

RUN nix --option filter-syscalls false build .#neovim

ENTRYPOINT ["/tmp/build/result/bin/nvim"]
