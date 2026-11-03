pragma ComponentBehavior: Bound

import qs.config
import qs.services
import qs.components
import QtQuick

Flow {
    id: root
    spacing: Theme.spaceXs

    Repeater {
        model: MediaCenterState.players

        Rectangle {
            id: chip
            required property var modelData
            readonly property bool active: modelData === MediaCenterState.player

            implicitWidth: label.implicitWidth + Theme.spaceMd
            implicitHeight: Theme.tagHeight
            radius: Theme.radius
            border.width: 1
            border.color: active ? Theme.tagBorderActive : Theme.tagBorder
            color: active ? Theme.tagActive
                 : hover.hovered ? Theme.tagHover
                 : "transparent"

            StyledText {
                id: label
                anchors.centerIn: parent
                text: (chip.modelData.isPlaying ? "● " : "") + chip.modelData.identity.toLowerCase()
                font.pixelSize: 13
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler { onTapped: MediaCenterState.selectedPlayer = chip.modelData }
        }
    }
}
