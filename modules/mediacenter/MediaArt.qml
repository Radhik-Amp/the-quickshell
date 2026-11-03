import qs.config
import qs.components
import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string source: ""
    readonly property bool loaded: art.status === Image.Ready

    implicitWidth: 110
    implicitHeight: 110

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.tagHover
        visible: !root.loaded

        StyledText {
            anchors.centerIn: parent
            text: Theme.iconMusic
            font.pixelSize: 40
            color: Theme.textMuted
        }
    }

    Image {
        id: art
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        visible: false
    }

    MultiEffect {
        anchors.fill: art
        source: art
        visible: root.loaded
        maskEnabled: true
        maskSource: artMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        id: artMask
        anchors.fill: parent
        radius: Theme.radius
        visible: false
        layer.enabled: true
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: "transparent"
        border.width: Theme.borderWidth
        border.color: Theme.borderColorMuted
    }
}
