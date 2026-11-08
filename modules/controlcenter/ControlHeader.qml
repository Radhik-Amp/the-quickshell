import qs.components
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    readonly property string user: Quickshell.env("USER") ?? ""
    property real uptimeSeconds: 0

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400)
        const hours = Math.floor(seconds % 86400 / 3600)
        const minutes = Math.floor(seconds % 3600 / 60)
        if (days > 0) return `\u{F051B} ${days}d ${hours}h`
        if (hours > 0) return `\u{F051B} ${hours}h ${minutes}m`
        return `\u{F051B} ${minutes}m`
    }

    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]

        stdout: StdioCollector {
            onStreamFinished: {
                const seconds = parseFloat(text)
                if (!isNaN(seconds))
                    root.uptimeSeconds = seconds
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProc.running = true
    }

    StyledText {
        text: root.user
    }

    Item {
        Layout.fillWidth: true
    }

    StyledText {
        visible: root.uptimeSeconds > 0
        text: root.formatUptime(root.uptimeSeconds)
    }
}
