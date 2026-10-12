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

  # Desktop Mode is a nested Plasma that Steam launches (steam.service ->
  # steamos-nested-desktop -> startplasma-wayland), so it inherits the user
  # manager's PATH, which /etc/systemd/user.conf pins to /usr/local/bin:/usr/bin
  # (environment.d PATH and plasma-workspace/env scripts don't take effect).
  # Without the Nix profile on that PATH the KDE menu can't launch Nix apps and
  # hides any whose .desktop file has TryExec (kitty, ghostty). set-environment
  # overrides the manager default; appended so Nix binaries never shadow the
  # system ones Steam relies on.
  systemd.user.services.nix-session-path = {
    Unit = {
      Description = "Add the Nix profile to the user manager's PATH";
      Before = [ "steam.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/usr/bin/systemctl --user set-environment PATH=/usr/local/bin:/usr/bin:${config.home.profileDirectory}/bin:/nix/var/nix/profiles/default/bin";
    };
    Install.WantedBy = [ "steam.service" ];
  };

  # KDE Connect (not shipped by SteamOS). services.kdeconnect would run it as a
  # systemd user service, but that lands on the Steam session's D-Bus, not the
  # nested Desktop Mode bus (dbus-run-session), so nothing in Plasma can reach
  # it. Autostart the daemon and the standalone tray indicator inside Plasma
  # instead. The Plasma tray plasmoid can't work: it's built against Nix Qt
  # (6.11) and SteamOS's plasmashell uses Qt 6.8 — disable it in System Tray
  # settings.
  home.packages = [ pkgs.kdePackages.kdeconnect-kde ];
  xdg.configFile."autostart/org.kde.kdeconnect.daemon.desktop".source =
    "${pkgs.kdePackages.kdeconnect-kde}/etc/xdg/autostart/org.kde.kdeconnect.daemon.desktop";
  # The upstream indicator entry has NotShowIn=KDE, so write our own.
  xdg.configFile."autostart/kdeconnect-indicator.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=KDE Connect Indicator
    Exec=${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator
    Icon=kdeconnect
  '';

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
