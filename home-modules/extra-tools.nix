{ config, pkgs, inputs, ... }:

{
  imports = [
  ];


  programs = {
  };
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    claude-code
    warp
  ];

}
