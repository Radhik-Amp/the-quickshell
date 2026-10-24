pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property int value: 0
    property int max: 100
    property int pending: -1

    function set(v) {
        root.value = v
        root.pending = v
        debounce.restart()
    }

    Process {
        command: ["ddcutil", "getvcp", "10", "--brief"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.split(" ")
                root.max = parseInt(f[4])
                root.value = parseInt(f[3])
            }
        }
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: {
            if (setProc.running) { restart(); return }
            setProc.command = ["ddcutil", "setvcp", "10", String(root.pending), "--noverify"]
            setProc.running = true
        }
    }

    Process { id: setProc }
}
