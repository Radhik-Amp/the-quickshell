import Quickshell
import QtQuick
import qs.config
import qs.components

Rectangle {
    id: root

    property string label
    property list<string> command

    implicitHeight: sessionText.implicitHeight + Theme.padding * 2

    radius: Theme.radius
    color: mouse.containsMouse ? Theme.buttonColorHovered : "transparent"
    border.width: Theme.borderWidth
    border.color: Theme.borderColorMuted


    BarText {
        id: sessionText
        anchors.centerIn: parent
        text: root.label
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(root.command)
    }
}
