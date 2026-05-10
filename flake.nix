{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    kickstart-nixvim.url = "path:/etc/nixos/kickstart.nixvim";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@attrs:
    {
      # Please replace my-nixos with your hostname
      nixosConfigurations.user = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        modules = [
          ./configuration.nix
          (
            { ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  mistral-vibe = nixpkgs-unstable.legacyPackages.${prev.system}.mistral-vibe;
                })
              ];
            }
          )
        ];
      };
    };
}
