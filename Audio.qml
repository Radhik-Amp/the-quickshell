pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property int volume: Math.round(100 * (defaultSink?.audio?.volume ?? 0))
    readonly property bool muted: defaultSink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.defaultSink]
    }
    
    function toggleMute() {
        if (!defaultSink?.ready) return 
        defaultSink.audio.muted = !(defaultSink.audio.muted) 
    }

    function changeVolume(number) {
        if (!defaultSink?.ready) return 
        const v = defaultSink.audio.volume + (number / 100)
        defaultSink.audio.volume = Math.max(0, Math.min(1, v))
    }


}
