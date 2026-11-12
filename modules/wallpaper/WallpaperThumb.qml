import qs.config
import qs.components
import qs.services
import Quickshell.Widgets
import QtQuick

ClippingRectangle {
    id: root
    // Wallpaper thumbnail with caption, active badge and hover/press feedback.

    required property string path
    property bool current: false
    property real hoverScale: 1.03
    readonly property bool active: Object.values(Wallpaper.currentPaths).includes(path)

    signal hovered()
    signal tapped()

    radius: Theme.radius
    color: Theme.tagHover
    border.width: Theme.borderWidth
    border.color: current ? Theme.borderColor
        : active ? Theme.tagBorderActive
        : Theme.borderColorMuted

    scale: tap.pressed ? 0.97 : (current ? hoverScale : 1)
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Image {
        anchors.fill: parent
        source: Wallpaper.fileUrl(root.path)
        sourceSize: Qt.size(480, 270)
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: caption.implicitHeight + Theme.spaceMd
        opacity: root.current ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
        gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.75) }
        }

        StyledText {
            id: caption
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: Theme.spaceSm
                bottomMargin: Theme.spaceXs
            }
            text: root.path.split("/").pop()
            elide: Text.ElideMiddle
            font.pixelSize: Theme.fontSize - 3
        }
    }

    Rectangle {
        visible: root.active
        anchors {
            top: parent.top
            right: parent.right
            margins: Theme.spaceSm
        }
        width: 22
        height: 22
        radius: height / 2
        color: Theme.background
        border.width: Theme.borderWidth
        border.color: Theme.borderColor

        GlyphText {
            anchors.centerIn: parent
            text: Theme.iconCheck
            font.pixelSize: Theme.fontSize - 2
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered) root.hovered()
    }

    TapHandler {
        id: tap
        onTapped: root.tapped()
    }
}
