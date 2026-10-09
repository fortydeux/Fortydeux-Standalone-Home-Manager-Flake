{ config, lib, pkgs, ... }:

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
  # SteamOS's "Install [App]" placeholder in /usr/share/applications shadows
  # the installed Flatpak's org.app.name.desktop.
  xdg.systemDirs.data = lib.mkBefore [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  # On-demand rclone pCloud mount:
  # directory listings come from pCloud immediately, file contents download
  # only when opened, and the local VFS cache is capped so it can't fill the
  # disk. Requires a one-time `rclone config` to create a remote named
  # "pcloud" before this service will mount anything.
  systemd.user.services.rclone-pcloud = {
    Unit = {
      Description = "Mount pCloud via rclone (on-demand, VFS cache)";
    };
    Service = {
      Type = "simple";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/pCloud"
        "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/.cache/rclone"
      ];
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount pcloud: ${config.home.homeDirectory}/pCloud \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=20G \
          --vfs-cache-max-age=24h \
          --dir-cache-time=1h \
          --poll-interval=15s \
          --log-level=INFO \
          --log-file=${config.home.homeDirectory}/.cache/rclone/mount.log
      '';
      # "-" prefix: ignore failure — rclone's own SIGTERM handler usually
      # unmounts first, so this is just a safety net for a stuck mount.
      ExecStop = "-/usr/bin/fusermount3 -u ${config.home.homeDirectory}/pCloud";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
