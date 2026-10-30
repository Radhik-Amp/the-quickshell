pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    
    readonly property bool shown: Wallpaper.shown

    exclusionMode: ExclusionMode.Ignore
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
        height: contentColumn.implicitHeight + 2 * Theme.padding

        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.borderColor
        focus: true
        Keys.onEscapePressed: Wallpaper.shown = false

        TapHandler { gesturePolicy: TapHandler.ReleaseWithinBounds }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.padding
            BarText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                text: "\u{F024B} " + Wallpaper.currentDirectory.replace(Quickshell.env("HOME"), "~")
            }

            Rectangle {
                implicitHeight: 1
                Layout.fillWidth: true
                color: Theme.borderColorMuted
            }

            GridView {
                id: grid
                model: Wallpaper.entries
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(pickerPanel.rows, Math.ceil(count / 3)) * cellHeight
                clip: true

                cellWidth: width / 3
                cellHeight: Math.floor(cellWidth * (root.screen.height / root.screen.width))

                delegate: Item {
                    id: contentItem
                    required property string modelData
                    width: grid.cellWidth
                    height: grid.cellHeight

                    ClippingRectangle {
                        id: contentRect
                        anchors.fill: parent
                        anchors.margins: Theme.padding
                        radius: Theme.radius
                        color: "transparent"
                        border.width: Theme.borderWidth
                        border.color: Object.values(Wallpaper.currentPaths).includes(contentItem.modelData) ? Theme.borderColor : Theme.borderColorMuted

                        Image {
                            anchors.fill: parent
                            source: "file://" + contentItem.modelData
                            sourceSize: Qt.size(480, 270)
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                        }

                        HoverHandler {
                            id: gridHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: if (!Object.values(Wallpaper.currentPaths).includes(contentItem.modelData)) Wallpaper.set(contentItem.modelData) 
                        }
                    }
                }
            }
        }
    }
}
