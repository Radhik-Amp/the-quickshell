pragma Singleton

import qs
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property bool connected: false
    Process {
        id: check
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.connected = text.split("\n").includes("ethernet:connected")
            }
        }
    }
    Process {
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser { onRead: recheck.restart() }
    }

    Timer {
        id: recheck
        interval: 300
        onTriggered: check.running = true
    }

    Component.onCompleted: check.running = true
}
