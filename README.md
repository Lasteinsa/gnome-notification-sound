# gnome-notif-sound

GNOME Shell extension (`notif-sound@einsa`) that forces a fallback chime through GNOME's **Notifications** sound channel when an app sends a desktop notification with no sound hint.

Many apps (Electron/Chromium apps, `notify-send`, GTK apps) either send silent notifications or play their own chime on the **Media** channel—so muting Media silences notifications. This extension makes GNOME play `message-new-instant` on the Notifications channel instead.

## How it works

Wraps `MessageTray.Notification.prototype.playSound`:
- Respects Do Not Disturb and per-app notification sound settings (`policy.enableSound`).
- Skips fallback if the notification already sets a D-Bus `sound-name` or `sound-file` hint.
- Plays `message-new-instant` via `global.display.get_sound_player()` with a `350 ms` cooldown.

Note: This does not mute an app's own internal sound; if Media is unmuted, turn off in-app notification SFX to avoid double chimes.

## Install

```bash
./install.sh --enable
```

On Wayland, log out and back in once if GNOME Shell hasn't picked up the extension yet, then run `gnome-extensions enable notif-sound@einsa`.

Other flags: `./install.sh` (copy only), `./install.sh --dev` (symlink), `./install.sh --uninstall` (remove).

## Supported

- GNOME Shell `51` (Wayland)
- Sound theme with `message-new-instant` (default GNOME theme works)
- PipeWire or PulseAudio
