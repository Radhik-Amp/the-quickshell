pragma ComponentBehavior: Bound

import qs.services
import QtQuick

Item {
    id: root
    readonly property int spacing: 3
    readonly property real barWidth: (width - spacing * (Cava.bars - 1)) / Cava.bars

    implicitHeight: 48

    Repeater {
        model: Cava.bars

        Rectangle {
            required property int index
            readonly property real level: Cava.values[index] ?? 0

            x: Math.round(index * (root.barWidth + root.spacing))
            anchors.bottom: parent.bottom
            width: Math.max(1, Math.round(root.barWidth))
            height: Math.max(2, level / 100 * root.height)
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.35 + level / 100 * 0.5)

            Behavior on height { NumberAnimation { duration: 60 } }
        }
    }
}
