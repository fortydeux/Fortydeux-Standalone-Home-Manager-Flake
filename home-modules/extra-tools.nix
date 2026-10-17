{ config, pkgs, inputs, ... }:

{
  imports = [
    # inputs.yazelix.homeManagerModules.default
  ];


  # programs = {
    # yazelix.enable = true;
  # };
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    claude-code
    warp
    herdr
    # opencode
    rclone
  ];

}
