{ nixpkgs, self, ... }:
let
  system = "x86_64-linux";
  pkgs = (import nixpkgs { inherit system; });
  nixpkgs-patched' = (
    pkgs.applyPatches {
      name = "nixpkgs-patched-414391-428988";
      src = nixpkgs;
      patches = [
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/414391.patch";
          sha256 = "sha256-DPy3yViEIO/e/Skr0gnMFqeFq77uOdJPWiXCSeKVxdQ=";
        })
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/428988.patch";
          sha256 = "sha256-huuLo6rD6Owfv1PwBjSqPjhS3UcBU2YHox8rjylSxFA=";
        })
      ];
    }
  );
  nixpkgs-patched = (import "${nixpkgs-patched'}/flake.nix").outputs { inherit self; };
in
nixpkgs-patched
