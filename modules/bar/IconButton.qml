import qs.config
import qs.components
import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    signal clicked()

    implicitWidth: Theme.tagHeight
    implicitHeight: Theme.tagHeight
    radius: Theme.radius
    color: hover.hovered ? Theme.tagHover : "transparent"

    StyledText {
        id: label
        anchors.centerIn: parent
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler { onTapped: root.clicked() }
}
