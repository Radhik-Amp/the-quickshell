pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

PanelWindow {
    id: root
    
    readonly property bool shown: Wallpaper.shown

    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: shown
    color: Qt.rgba(0, 0, 0, 0.65)

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    
    Item {
        anchors.fill: parent
        TapHandler {
            onTapped: Wallpaper.shown = false
        }
    }

    Rectangle {
        id: pickerPanel
        
        readonly property int rows: 4

        anchors.centerIn: parent
        width: Math.min(parent.width * 0.6, 1400)
        height: rows * grid.cellHeight + 2 * Theme.padding

        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.borderColor

        GridView {
            id: grid
            model: Wallpaper.entries
            anchors.fill: parent
            anchors.margins: Theme.padding 
            clip: true

            cellWidth: width / 3
            cellHeight: cellWidth * (root.screen.height / root.screen.width)

            delegate: Item {
                id: contentItem
                required property string modelData
                required property int index
                width: grid.cellWidth
                height: grid.cellHeight

                ClippingRectangle {
                    id: contentRect
                    anchors.fill: parent
                    anchors.margins: Theme.padding / 2
                    radius: Theme.radius
                    width: parent.width
                    height: parent.height

                    Image {
                        anchors.fill: parent
                        source: "file://" + contentItem.modelData
                        sourceSize: Qt.size(480, 270)
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.width: Theme.borderWidth
                        border.color: Object.values(Wallpaper.currentPaths).includes(contentItem.modelData) ? Theme.borderColor : Theme.borderColorMuted

                        HoverHandler {
                            id: gridHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: if (contentItem.modelData !== Wallpaper.currentPaths) Wallpaper.set(contentItem.modelData) 
                        }
                    }
                }


            }
        }
    }
}
