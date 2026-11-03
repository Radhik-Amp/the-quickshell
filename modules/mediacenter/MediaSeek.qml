pragma ComponentBehavior: Bound

import qs.config
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root
    property var player: null
    readonly property real length: player?.length ?? 0
    readonly property bool seekable: (player?.canSeek ?? false) && length > 0
    readonly property int segments: 30

    spacing: Theme.spaceSm

    function format(seconds) {
        if (!(seconds >= 0) || root.length <= 0)
            return "--:--"
        const s = Math.floor(seconds)
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`
    }

    StyledText {
        text: root.format(slider.value)
        font.pixelSize: 13
        color: Theme.textMuted
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        topPadding: 6
        bottomPadding: 6
        from: 0
        to: Math.max(root.length, 1)
        enabled: root.seekable

        Binding on value {
            when: !slider.pressed
            value: root.player?.position ?? 0
            restoreMode: Binding.RestoreNone
        }

        onPressedChanged: if (!pressed && root.seekable) root.player.position = value

        background: RowLayout {
            spacing: 2

            Repeater {
                model: root.segments
                Rectangle {
                    required property int index
                    readonly property bool filled: index < slider.visualPosition * root.segments

                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 2
                    color: filled ? Theme.text : Qt.rgba(1, 1, 1, 0.15)
                }
            }
        }
        handle: Item {}

        HoverHandler { cursorShape: root.seekable ? Qt.PointingHandCursor : Qt.ArrowCursor }
    }

    StyledText {
        text: root.format(root.length)
        font.pixelSize: 13
        color: Theme.textMuted
    }
}
