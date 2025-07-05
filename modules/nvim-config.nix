{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "vladexa-nvim-config";
  src = builtins.fetchGit "https://github.com/VlaDexa/nvim-config.git";
  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';
}

# vim: ts=2 sw=2 et
