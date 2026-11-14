import qs.config
import qs.components
import QtQuick

Rectangle {
    id: root
    // Square icon button with hover highlight and a clicked() signal.
    property alias text: label.text
    property alias textColor: label.color
    property alias font: label.font
    readonly property alias hovered: hover.hovered
    signal clicked()

    implicitWidth: Theme.tagHeight
    implicitHeight: Theme.tagHeight
    radius: Theme.radius
    color: hover.hovered && enabled ? Theme.tagHover : "transparent"
    opacity: enabled ? 1 : 0.35

    StyledText {
        id: label
        anchors.centerIn: parent
    }

    HoverHandler {
        id: hover
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
    TapHandler {
        enabled: root.enabled
        onTapped: root.clicked()
    }
}
