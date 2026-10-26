import Quickshell
import QtQuick
import qs.config
import qs.components

Rectangle {
    id: root

    property string label
    property list<string> command

    property int holdDuration: 0
    property real holdProgress: 0

    implicitHeight: sessionText.implicitHeight + Theme.padding * 2

    radius: Theme.radius
    color: hover.hovered ? Theme.buttonColorHovered : "transparent"
    border.width: Theme.borderWidth
    border.color: Theme.borderColorMuted

    function cancelHold() {
        holdTimer.stop()
        holdAnimation.stop()
        holdProgress = 0
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * root.holdProgress
        radius: root.radius
        color: Theme.borderColor
    }

    BarText {
        id: sessionText
        anchors.centerIn: parent
        text: root.label
    }

    NumberAnimation {
        id: holdAnimation
        target: root
        property: "holdProgress"
        from: 0
        to: 1
        duration: holdDuration
    }

    Timer {
        id: holdTimer
        interval: root.holdDuration
        onTriggered: {
            root.holdProgress = 0
            Quickshell.execDetached(root.command)
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        gesturePolicy: TapHandler.WithinBounds
        onPressedChanged: {
            if (root.holdDuration === 0) return
            if (pressed) { holdTimer.start(); holdAnimation.start() }
            else root.cancelHold()
        }
        onTapped: if (root.holdDuration === 0) Quickshell.execDetached(root.command)
    }
}
