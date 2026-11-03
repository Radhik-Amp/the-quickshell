pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
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

        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: pickerPanel.forceActiveFocus()
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.padding

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: false
                Layout.maximumWidth: contentColumn.width
                spacing: 4

                BarText { text: "\u{F024B}" }

                Rectangle {
                    id: fieldWrap
                    Layout.fillWidth: true
                    implicitWidth: pathField.implicitWidth + Theme.padding
                    Layout.preferredHeight: 30
                    radius: Theme.radius
                    color: pathField.activeFocus ? Theme.background : "transparent"
                    border.width: pathField.activeFocus ? Theme.borderWidth : 0
                    border.color: Theme.borderColorMuted

                    TextField {
                        id: pathField
                        anchors.centerIn: parent
                        anchors.leftMargin: Theme.padding / 2
                        anchors.rightMargin: Theme.padding / 2

                        readonly property string displayPath: Wallpaper.currentDirectory.replace(Quickshell.env("HOME"), "~")

                        text: displayPath
                        placeholderText: "Enter path..."
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        background: null
                        padding: 0
                        verticalAlignment: TextInput.AlignVCenter

                        onAccepted: {
                            if (text.length > 0) Wallpaper.setDirectory(text)
                            pickerPanel.forceActiveFocus()
                        }
                        onTextEdited: Wallpaper.directoryError = ""
                        onActiveFocusChanged: if (!activeFocus) text = Qt.binding(() => displayPath)
                    }
                }
            }

            BarText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: text !== ""
                text: Wallpaper.directoryError
                color: "red"
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
                    z: gridHover.hovered ? 1 : 0

                    ClippingRectangle {
                        id: contentRect
                        anchors.fill: parent
                        anchors.margins: Theme.padding / 2
                        radius: Theme.radius
                        color: "transparent"
                        border.width: Theme.borderWidth
                        border.color: Object.values(Wallpaper.currentPaths).includes(contentItem.modelData) ? Theme.borderColor : Theme.borderColorMuted

                        scale: gridTap.pressed ? 0.97 : (gridHover.hovered ? 1.03 : 1)
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

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
                            id: gridTap
                            onTapped: if (!Object.values(Wallpaper.currentPaths).includes(contentItem.modelData)) Wallpaper.set(contentItem.modelData) 
                        }
                    }
                }
            }
        }
    }
}
