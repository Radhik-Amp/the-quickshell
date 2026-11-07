pragma Singleton

import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string layout: tags.find(t => t.is_active)?.layout ?? ""
    property var tags: []
    property int pendingTag: -1

    function viewTag(number) {
        pendingTag = number - 1
        pendingTimeout.restart()
        Quickshell.execDetached(["mmsg","dispatch","view," + number + ",0"])
    }

    onTagsChanged: {
        if (pendingTag >= 0 && tags[pendingTag]?.is_active) {
            pendingTag = -1
            pendingTimeout.stop()
        }
    }

    Process {
        id: tagProc
        command: ["stdbuf", "-oL", "mmsg", "watch", "tags", Env.monitor]
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

    Timer {
        id: pendingTimeout
        interval: 1000
        onTriggered: root.pendingTag = -1
    }
}
