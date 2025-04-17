{ config, pkgs, ... }:

{ # steamdeck-home.nix

  imports = [
    ../home-modules/home-commonConfig.nix
  ];
  
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  services = {
    caffeine.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    caffeine-ng # Keep computer awake
    libsForQt5.plasma-applet-caffeine-plus # Applet for caffeine
    warp-terminal # Rust-based AI-enabled terminal
  ];
}
