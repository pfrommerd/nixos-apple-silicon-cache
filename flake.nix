{
  description = "Prebuilt nixos-apple-silicon kernel closure";

  inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

  outputs =
    { nixos-apple-silicon, ... }:
    {
      packages.aarch64-linux = rec {
        linux-asahi = nixos-apple-silicon.packages.aarch64-linux.linux-asahi;
        default = linux-asahi;
      };
    };
}
