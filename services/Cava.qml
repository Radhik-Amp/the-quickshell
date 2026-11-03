pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int bars: 32
    readonly property var zeros: Array(bars).fill(0)
    // Bar heights in 0..100, one per bar
    property var values: zeros

    // Only analyse audio while someone can see it
    readonly property bool active: MediaCenterState.shown && (MediaCenterState.player?.isPlaying ?? false)

    Process {
        command: ["cava", "-p", Quickshell.shellPath("config/cava.conf")]
        running: root.active
        stdout: SplitParser {
            onRead: line => {
                const v = line.split(";").filter(s => s.length > 0).map(Number)
                if (v.length === root.bars)
                    root.values = v
            }
        }
        onRunningChanged: if (!running) root.values = root.zeros
    }
}
