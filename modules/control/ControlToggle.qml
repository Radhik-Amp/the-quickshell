import qs.config
import qs.components
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon
    property string label
    property string status
    property bool active: false
    signal clicked()


    readonly property color fg: active ? Theme.background : Theme.borderColor
    readonly property color dim: active ? Qt.rgba(0, 0, 0, 0.55) : Qt.rgba(1, 1, 1, 0.45)

    implicitHeight: content.implicitHeight + 4
    width: statusLength.width 
    radius: Theme.radius
    border.width: Theme.borderWidth
    border.color: active || hover.hovered ? Theme.borderColor : Theme.borderColorMuted
    color: active
        ? (hover.hovered ? Qt.rgba(1, 1, 1, 0.85) : Theme.borderColor)
        : (hover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

    scale: tap.pressed ? 0.96 : 1

    TextMetrics {
        id: statusLength
        text: "connected"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
    Behavior on scale { NumberAnimation { duration: 80 } }
    

    HoverHandler { id: hover }
    TapHandler {
        id: tap
        onTapped: root.clicked()
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 8
        }
        spacing: 2

        BarText { text: root.icon; color: root.fg; font.pixelSize: Theme.fontSize + 4 }
        BarText { text: root.label; color: root.fg }
        BarText {
            Layout.fillWidth: true
            text: root.status
            color: root.dim
            font.pixelSize: Theme.fontSize - 1
            elide: Text.ElideRight
        }
    }
}   
