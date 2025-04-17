{ config, ... }:

{ # mudskipper-linux-home.nix

  imports = [
    ../home-modules/home-commonConfig.nix
  ];
  home.username = "fortydeux";
  home.homeDirectory = "/home/fortydeux";
}
