{ config, ... }:

{ # steamframe-home.nix - Valve Steam Frame (SteamOS, aarch64-linux)

  imports = [
    ../home-modules/home-commonConfig.nix
    # ../home-modules/extra-tools.nix
  ];

  home.username = "steamos";
  home.homeDirectory = "/home/steamos";

  # Carried over from the stock ~/.bashrc, which Home Manager replaces
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.opencode/bin"
  ];
}
