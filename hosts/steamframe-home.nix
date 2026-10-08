{ config, lib, ... }:

{ # steamframe-home.nix - Valve Steam Frame (SteamOS, aarch64-linux)

  imports = [
    ../home-modules/home-commonConfig.nix
    ../home-modules/extra-tools.nix
  ];

  home.username = "steamos";
  home.homeDirectory = "/home/steamos";

  # Carried over from the stock ~/.bashrc, which Home Manager replaces
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.opencode/bin"
    # Installed by tailscale-dev/deck-tailscale's installer (patched for
    # arm64 + /var persistence); /etc/profile.d/tailscale.sh never runs
    # because Home Manager's .bash_profile/.profile don't source /etc/profile.
    "/var/lib/tailscale-bin"
    # The system-wide multi-user `nix` CLI (/nix/var/nix/profiles/default/bin)
    # otherwise only reaches PATH via /etc/profile.d/nix.sh, which only runs
    # for login shells — a plain new terminal (non-login) never gets `nix`.
    "/nix/var/nix/profiles/default/bin"
  ];

  # Flatpak exports must come before /usr/share (which genericLinux adds), or
  # SteamOS's "Install Firefox" placeholder in /usr/share/applications shadows
  # the installed Flatpak's org.mozilla.firefox.desktop.
  xdg.systemDirs.data = lib.mkBefore [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];
}
