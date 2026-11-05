{
  nix = {
    settings = {
      substituters = [
        "https://cache.tuwunel.chat"
        "https://tuwunel.cachix.org"
      ];
      trusted-public-keys = [
        "cache.tuwunel.chat-1:ZafUaXiRMozDa9N2SWim6EdzH0EEjWjwfvlTxXvcjLA="
        "tuwunel.cachix.org-1:VRecUeDcaPxtYDA6bnMF3snPM7VYX8K605z4uuG2nWc="
      ];
    };
  };
}
