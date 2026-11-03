pragma Singleton

import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int bars: 32
    readonly property var zeros: Array(bars).fill(0)
    property var values: zeros

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
