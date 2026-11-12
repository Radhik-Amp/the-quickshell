pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    // Busiest processes by CPU, refreshed while the panel is open.

    readonly property int cpuWidth: {
        metrics.font
        return Math.ceil(metrics.boundingRect("100.0%").width)
    }
    readonly property int memWidth: {
        metrics.font
        return Math.ceil(metrics.boundingRect("99.9 GiB").width)
    }

    FontMetrics {
        id: metrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    spacing: Theme.spaceXs

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        StyledText {
            Layout.fillWidth: true
            text: "Top processes"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSize - 3
        }
        StyledText {
            Layout.preferredWidth: root.cpuWidth
            text: "CPU"
            horizontalAlignment: Text.AlignRight
            color: Theme.textMuted
            font.pixelSize: Theme.fontSize - 3
        }
        StyledText {
            Layout.preferredWidth: root.memWidth
            text: "MEM"
            horizontalAlignment: Text.AlignRight
            color: Theme.textMuted
            font.pixelSize: Theme.fontSize - 3
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: SystemMonitor.topProcesses.length === 0
        text: "Loading…"
        color: Theme.textMuted
    }

    Repeater {
        model: SystemMonitor.topProcesses

        RowLayout {
            id: proc
            required property var modelData

            Layout.fillWidth: true
            spacing: Theme.spaceSm

            StyledText {
                Layout.fillWidth: true
                text: proc.modelData.name
                elide: Text.ElideRight
            }
            StyledText {
                Layout.preferredWidth: root.cpuWidth
                text: proc.modelData.cpu.toFixed(1) + "%"
                horizontalAlignment: Text.AlignRight
            }
            StyledText {
                Layout.preferredWidth: root.memWidth
                text: SystemMonitor.formatKb(proc.modelData.mem)
                horizontalAlignment: Text.AlignRight
                color: Theme.textMuted
            }
        }
    }
}
