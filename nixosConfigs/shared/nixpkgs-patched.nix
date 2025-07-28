{ nixpkgs, self, ... }:
let
  system = "x86_64-linux";
  pkgs = (import nixpkgs { inherit system; });
  nixpkgs-patched' = (
    pkgs.applyPatches {
      name = "nixpkgs-patched-414391-bcachefs_dedup";
      src = nixpkgs;
      patches = [
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/414391.patch";
          sha256 = "sha256-DPy3yViEIO/e/Skr0gnMFqeFq77uOdJPWiXCSeKVxdQ=";
        })
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/429126.patch";
          sha256 = "sha256-mO8Jda83Nt/4DoR1IQwc0RUe7mOHzo1ySwBsumrZBNo=";
        })
      ];
    }
  );
  nixpkgs-patched = (import "${nixpkgs-patched'}/flake.nix").outputs { inherit self; };
in
nixpkgs-patched
