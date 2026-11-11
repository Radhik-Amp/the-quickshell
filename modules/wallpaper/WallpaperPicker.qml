pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

PanelWindow {
    id: root

    readonly property bool shown: Wallpaper.shown

    property real progress: shown ? 1 : 0
    Behavior on progress {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    function fileUrl(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/")
    }

    function apply(path) {
        if (path && !Object.values(Wallpaper.currentPaths).includes(path)) Wallpaper.set(path)
    }

    onShownChanged: if (shown) Qt.callLater(() => {
        const i = Math.max(0, Wallpaper.entries.indexOf(Wallpaper.currentPaths[root.screen?.name]))
        grid.currentIndex = i
        grid.positionViewAtIndex(i, GridView.Contain)
        grid.forceActiveFocus()
    })

    // Window-wide, so Escape closes no matter which child (grid cell, path
    // field) holds focus. The panel's Keys.onEscapePressed is the fallback.
    Shortcut {
        sequence: "Escape"
        enabled: root.shown
        onActivated: Wallpaper.shown = false
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: shown || progress > 0
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Blurred copy of a wallpaper; two of these double-buffer the backdrop.
    component BlurLayer: Item {
        // Kept as the string we built: Image.source normalizes it (e.g. %20 → space).
        property string url
        readonly property bool ready: image.status === Image.Ready

        anchors.fill: parent

        Image {
            id: image
            anchors.fill: parent
            source: parent.url
            sourceSize: Qt.size(Math.round(width / 4), Math.round(height / 4))
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: image
            source: image
            blurEnabled: true
            blur: 0.8
            blurMax: 32
            visible: parent.ready
        }
    }

    Item {
        id: backdrop
        anchors.fill: parent
        opacity: root.progress

        // New wallpapers load into the back layer and fade in on top only once
        // ready, so the old blur stays up meanwhile instead of exposing windows.
        readonly property string target: {
            const path = Wallpaper.currentPaths[root.screen?.name]
            return path ? root.fileUrl(path) : ""
        }
        property BlurLayer front: layerA
        readonly property BlurLayer back: front === layerA ? layerB : layerA

        function load() {
            if (front.url === target) return
            back.url = target
            if (back.ready) promote()
        }
        function promote() {
            front = back
            fadeIn.restart()
        }

        onTargetChanged: load()
        Component.onCompleted: layerA.url = target

        BlurLayer {
            id: layerA
            z: backdrop.front === layerA ? 1 : 0
            onReadyChanged: if (ready && backdrop.back === layerA && url === backdrop.target) backdrop.promote()
        }
        BlurLayer {
            id: layerB
            z: backdrop.front === layerB ? 1 : 0
            onReadyChanged: if (ready && backdrop.back === layerB && url === backdrop.target) backdrop.promote()
        }

        NumberAnimation {
            id: fadeIn
            target: backdrop.front
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }

        Rectangle {
            z: 2
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)
        }

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
        Keys.onEscapePressed: Wallpaper.shown = false

        opacity: root.progress
        scale: root.shown ? 1 : 0.92
        Behavior on scale {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: grid.forceActiveFocus()
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.padding

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                StyledText {
                    text: "Wallpapers"
                    font.bold: true
                }
                StyledText {
                    text: Wallpaper.entries.length
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSize - 3
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spaceSm
                    Layout.preferredHeight: 30
                    radius: Theme.radius
                    color: pathField.activeFocus ? Theme.background : "transparent"
                    border.width: Theme.borderWidth
                    border.color: pathField.activeFocus ? Theme.borderColor : Theme.borderColorMuted

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spaceSm
                        anchors.rightMargin: Theme.spaceSm
                        spacing: Theme.spaceSm

                        GlyphText {
                            text: Theme.iconFolder
                            color: Theme.textMuted
                        }

                        TextField {
                            id: pathField
                            Layout.fillWidth: true

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
                                grid.forceActiveFocus()
                            }
                            onTextEdited: Wallpaper.directoryError = ""
                            onActiveFocusChanged: if (!activeFocus) text = Qt.binding(() => displayPath)
                        }
                    }
                }

                IconButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    text: Theme.iconRefresh
                    font.pixelSize: 18
                    onClicked: Wallpaper.refresh()
                }
            }

            StyledText {
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

                // bleed is experimental right now - to fix the clipping of panel margins on hover
                readonly property real hoverScale: 1.03
                readonly property int bleed: Math.ceil(contentColumn.width / 3 * (hoverScale - 1) / 2)

                model: Wallpaper.entries
                Layout.fillWidth: true
                Layout.leftMargin: -bleed
                Layout.rightMargin: -bleed
                Layout.topMargin: -bleed
                Layout.bottomMargin: -bleed
                Layout.preferredHeight: Math.min(pickerPanel.rows, Math.ceil(count / 3)) * cellHeight + topMargin + bottomMargin
                clip: true

                leftMargin: bleed
                rightMargin: bleed
                topMargin: bleed
                bottomMargin: bleed

                cellWidth: (width - leftMargin - rightMargin) / 3
                cellHeight: Math.floor(cellWidth * (root.screen.height / root.screen.width))

                focus: true
                keyNavigationEnabled: true
                keyNavigationWraps: true
                Keys.onReturnPressed: root.apply(Wallpaper.entries[currentIndex])
                Keys.onEnterPressed: root.apply(Wallpaper.entries[currentIndex])

                delegate: Item {
                    id: cell
                    required property string modelData
                    required property int index

                    readonly property bool active: Object.values(Wallpaper.currentPaths).includes(modelData)
                    readonly property bool current: GridView.isCurrentItem

                    width: grid.cellWidth
                    height: grid.cellHeight
                    z: current ? 1 : 0

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.padding / 2
                        radius: Theme.radius
                        color: Theme.tagHover
                        border.width: Theme.borderWidth
                        border.color: cell.current ? Theme.borderColor
                            : cell.active ? Theme.tagBorderActive
                            : Theme.borderColorMuted

                        scale: tap.pressed ? 0.97 : (cell.current ? grid.hoverScale : 1)
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

                        Image {
                            id: thumb
                            anchors.fill: parent
                            source: root.fileUrl(cell.modelData)
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
                            opacity: cell.current ? 1 : 0
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
                                text: cell.modelData.split("/").pop()
                                elide: Text.ElideMiddle
                                font.pixelSize: Theme.fontSize - 3
                            }
                        }

                        Rectangle {
                            visible: cell.active
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
                            onHoveredChanged: if (hovered) grid.currentIndex = cell.index
                        }

                        TapHandler {
                            id: tap
                            onTapped: {
                                grid.currentIndex = cell.index
                                root.apply(cell.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
