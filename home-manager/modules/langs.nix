{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # JavaScript / TypeScript
    fnm
    nodejs

    # Python
    uv

    # Rust
    rustup

    # Ferramentas de build
    gcc
    gnumake
    pkg-config
  ];
}
