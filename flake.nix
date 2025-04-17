{
  description = "Home Manager configuration of fortydeux";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        "fortydeux@blackfin-linux" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
              ./hosts/blackfin-linux-home.nix
            ];
        };
        "fortydeux@mojarra-linux" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
              ./hosts/mojarra-linux-home.nix
            ];
        };
        "fortydeux@mudskipper-linux" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
              ./hosts/mudskipper-linux-home.nix
            ];
        };
        "deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
              ./hosts/steamdeck-home.nix
            ];
        };
      };
    };
}
