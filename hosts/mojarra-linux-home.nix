{ config, ... }:

{ # mojarra-linux-home.nix

  imports = [
    ../home-modules/home-commonConfig.nix
    ../home-modules/extra-tools.nix
  ];
  
  home.username = "fortydeux";
  home.homeDirectory = "/home/fortydeux";

}
