// SPDX-License-Identifier: GPL-2.0-or-later

import GLib from 'gi://GLib';

import { Extension, InjectionManager } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as MessageTray from 'resource:///org/gnome/shell/ui/messageTray.js';

const FALLBACK_SOUND_THEME_NAME = 'message-new-instant';
const COOLDOWN_USEC = 350_000;

export default class NotifSoundExtension extends Extension {
    enable() {
        this._injectionManager = new InjectionManager();
        this._lastPlayedUsec = 0;

        const ext = this;
        this._injectionManager.overrideMethod(
            MessageTray.Notification.prototype,
            'playSound',
            original => {
                return function () {
                    if (!this.source?.policy?.enableSound)
                        return;

                    // Preserve app-provided sound-name or sound-file hints without double ringing.
                    if (this.sound?._soundName || this.sound?._soundFile) {
                        original.call(this);
                        return;
                    }

                    const nowUsec = GLib.get_monotonic_time();
                    if ((nowUsec - ext._lastPlayedUsec) < COOLDOWN_USEC)
                        return;

                    ext._lastPlayedUsec = nowUsec;
                    global.display.get_sound_player().play_from_theme(
                        FALLBACK_SOUND_THEME_NAME,
                        this.title || 'Notification sound',
                        null
                    );
                };
            }
        );
    }

    disable() {
        this._injectionManager?.clear();
        this._injectionManager = null;
        this._lastPlayedUsec = 0;
    }
}
