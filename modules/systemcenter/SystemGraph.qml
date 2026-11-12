pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    // Labelled usage graph: one bar per sample, newest on the right.

    required property string label
    required property string value
    property string detail: ""
    required property var history
    property int graphHeight: 40

    spacing: Theme.spaceXs

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        StyledText {
            Layout.fillWidth: true
            text: root.label
        }
        StyledText {
            visible: root.detail !== ""
            text: root.detail
            color: Theme.textMuted
            font.pixelSize: Theme.fontSize - 3
        }
        FixedWidthText {
            text: root.value
            widest: "100%"
            horizontalAlignment: Text.AlignRight
            font.bold: true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.graphHeight
        spacing: 2

        Repeater {
            model: SystemMonitor.historyLength

            Rectangle {
                id: slot
                required property int index
                // Pad on the left until history fills up
                readonly property int sample: index - (SystemMonitor.historyLength - root.history.length)

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.15)

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: slot.sample < 0 ? 0
                        : Math.max(1, Math.round(Math.min(100, root.history[slot.sample]) / 100 * parent.height))
                    radius: parent.radius
                    color: Theme.text
                }
            }
        }
    }
}
