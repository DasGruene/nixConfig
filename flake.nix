{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    kickstart-nixvim.url = "path:/etc/nixos/kickstart.nixvim";
  };

  outputs =
    { self, nixpkgs, ... }@attrs:
    {
      # Please replace my-nixos with your hostname
      nixosConfigurations.user = nixpkgs.lib.nixosSystem {
        specialArgs = attrs;
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./configuration.nix
        ];
      };
    };
}
