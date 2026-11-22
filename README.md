# notif-sound

A small GNOME Shell extension (`notif-sound@einsa`) that plays a fallback sound through GNOME's system notification sound channel when an app sends a desktop notification with no sound hint.

Useful for apps (such as Electron apps or background tools) whose notifications arrive silently or get routed strangely.

## How it works

The extension wraps `MessageTray.Notification.prototype.playSound` using GNOME Shell's `InjectionManager`:

1. Checks `this.source?.policy?.enableSound` so muted apps and Do Not Disturb are still respected.
2. If the notification already specifies a `sound-name` or `sound-file`, it runs the original `playSound` method untouched so you do not hear a double chime.
3. Otherwise, it calls `global.display.get_sound_player().play_from_theme(...)` with `message-new-instant`, which plays through the desktop notification/event channel instead of a media stream.
4. Enforces a `350 ms` cooldown (`COOLDOWN_USEC = 350_000`) between fallback sounds so rapid bursts of notifications do not spam audio.
5. Restores the original method cleanly when the extension is disabled.

## Installation

Install and enable the extension using the included script:

```bash
cd /home/einsa/Linux/notif-sound
./install.sh --enable
```

If you are on Wayland and GNOME Shell has not picked up the new extension yet, log out and log back in once, then run:

```bash
gnome-extensions enable notif-sound@einsa
```

Other installer options:

- `./install.sh` — copy files to `~/.local/share/gnome-shell/extensions/notif-sound@einsa` without enabling
- `./install.sh --dev` — symlink this directory instead of copying (handy when editing)
- `./install.sh --uninstall` — disable and remove the installed extension

## Supported

- GNOME Shell `51` (`shell-version` in `metadata.json`; works on Wayland and X11)
- Any freedesktop sound theme that provides `message-new-instant` (works out of the box with the default GNOME sound theme)
- PipeWire or PulseAudio setups using standard desktop notification/system sound volume controls
