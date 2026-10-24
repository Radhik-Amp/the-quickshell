pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var tags: []

    readonly property string layout: tags.find(t => t.is_active)?.layout ?? ""

    function viewTag(number) {
        Quickshell.execDetached(["mmsg","dispatch","view," + number + ",0"])
    }

    Process {
        id: tagProc
        command: ["stdbuf", "-oL", "mmsg", "watch", "tags", "DP-1"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                try {
                    root.tags = JSON.parse(line).tags ?? []
                } catch (e) {
                    console.warn("mango: couldn't read tag updates:", e)
                }
            }
        }

        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: tagProc.running = true
    }
}
