{
  description = "Prebuilt nixos-apple-silicon kernel closure";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
  inputs.nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { nixos-apple-silicon, ... }:
    {
      packages.aarch64-linux = rec {
        linux-asahi = nixos-apple-silicon.packages.aarch64-linux.linux-asahi;
        default = linux-asahi;
      };
    };
}
