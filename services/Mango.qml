pragma Singleton

import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Output whose tags the bar shows: VOYAGER_MONITOR if set, otherwise the
    // first active monitor Mango reports. Empty until detection finishes.
    property string monitor: Env.monitor
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

    function start() {
        if (Env.monitor)
            tagProc.running = true
        else
            monitorProc.running = true
    }

    Component.onCompleted: start()

    Process {
        id: monitorProc
        command: ["mmsg", "get", "all-monitors"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const monitors = JSON.parse(text).monitors ?? []
                    const pick = monitors.find(m => m.active) ?? monitors[0]
                    if (pick) {
                        root.monitor = pick.name
                        tagProc.running = true
                        return
                    }
                    console.warn("mango: no monitors reported, retrying")
                } catch (e) {
                    console.warn("mango: couldn't read monitors:", e)
                }
                restartTimer.start()
            }
        }
    }

    Process {
        id: tagProc
        command: ["stdbuf", "-oL", "mmsg", "watch", "tags", root.monitor]

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
        onTriggered: root.start()
    }

    Timer {
        id: pendingTimeout
        interval: 1000
        onTriggered: root.pendingTag = -1
    }
}
