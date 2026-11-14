pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

TetheredPanel {
    id: root

    readonly property int columns: 3
    readonly property int rows: 3
    readonly property real hoverScale: 1.03
    readonly property real contentWidth: panelWidth - Theme.padding * 2
    readonly property int bleed: Math.ceil(contentWidth / columns * (hoverScale - 1) / 2)

    name: "wallpaper"
    anchorX: Panels.positions.wallpaper ?? NaN
    focusMode: WlrKeyboardFocus.Exclusive
    panelWidth: 460
    spacing: Theme.padding

    onShownChanged: {
        if (!shown) {
            Wallpaper.previewShown = false
            return
        }
        Qt.callLater(() => {
            const i = Math.max(0, Wallpaper.entries.indexOf(Wallpaper.currentPaths[root.screen?.name]))
            grid.currentIndex = i
            grid.positionViewAtIndex(i, GridView.Contain)
            grid.forceActiveFocus()
        })
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        StyledText {
            text: "Wallpapers"
            font.bold: true
        }
        StyledText {
            Layout.fillWidth: true
            text: Wallpaper.entries.length
            color: Theme.textMuted
            font.pixelSize: Theme.fontSize - 3
        }
        IconButton {
            id: previewButton
            implicitWidth: 30
            implicitHeight: 30
            text: Theme.iconExpand
            font.pixelSize: 18
            color: Wallpaper.previewShown || previewButton.hovered ? Theme.tagHover : "transparent"
            onClicked: Wallpaper.togglePreview()
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: Wallpaper.entries.length === 0
        horizontalAlignment: Text.AlignHCenter
        text: "No wallpapers in " + Wallpaper.currentDirectory.replace(Quickshell.env("HOME"), "~")
        color: Theme.textMuted
        wrapMode: Text.Wrap
    }

    GridView {
        id: grid

        Layout.fillWidth: true
        Layout.leftMargin: -root.bleed
        Layout.rightMargin: -root.bleed
        Layout.topMargin: -root.bleed
        Layout.bottomMargin: -root.bleed
        Layout.preferredHeight: Math.min(root.rows, Math.ceil(count / root.columns)) * cellHeight + topMargin + bottomMargin
        visible: count > 0
        clip: true

        leftMargin: root.bleed
        rightMargin: root.bleed
        topMargin: root.bleed
        bottomMargin: root.bleed

        cellWidth: root.contentWidth / root.columns
        cellHeight: Math.floor(cellWidth * ((root.screen?.height ?? 9) / (root.screen?.width ?? 16)))

        model: Wallpaper.entries
        keyNavigationEnabled: true
        keyNavigationWraps: true
        Keys.onReturnPressed: Wallpaper.apply(Wallpaper.entries[currentIndex])
        Keys.onEnterPressed: Wallpaper.apply(Wallpaper.entries[currentIndex])

        delegate: Item {
            id: cell
            required property string modelData
            required property int index

            width: grid.cellWidth
            height: grid.cellHeight
            z: GridView.isCurrentItem ? 1 : 0

            WallpaperThumb {
                anchors.fill: parent
                anchors.margins: Theme.spaceXs
                path: cell.modelData
                current: cell.GridView.isCurrentItem
                hoverScale: root.hoverScale
                onHovered: grid.currentIndex = cell.index
                onTapped: {
                    grid.currentIndex = cell.index
                    Wallpaper.apply(cell.modelData)
                }
            }
        }
    }
}
