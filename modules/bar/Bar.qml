import qs.config
import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    screen: Quickshell.screens.find(s => s.name === Mango.monitor) ?? null

    IdleInhibitor {
        window: root
        enabled: Idle.caffeine
    }

    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: Theme.padding
        left: Theme.padding
        right: Theme.padding
    }

    implicitHeight: Theme.barHeight
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.radius

        Item {
            id: outline
            anchors.fill: parent

            readonly property var segments: {
                const w = width
                const r = Theme.radius
                const gaps = Object.values(Panels.barGaps)
                    .map(g => [Math.max(r, Math.round(g[0] - Theme.padding)), Math.min(w - r, Math.round(g[1] - Theme.padding))])
                    .filter(g => g[1] > g[0])
                    .sort((a, b) => a[0] - b[0])
                const segs = []
                let x = 0
                for (const [a, b] of gaps) {
                    if (a > x) segs.push({ x: x, width: a - x, bottom: true })
                    const start = Math.max(a, x)
                    if (b > start) segs.push({ x: start, width: b - start, bottom: false })
                    x = Math.max(x, b)
                }
                if (w > x) segs.push({ x: x, width: w - x, bottom: true })
                return segs
            }

            Repeater {
                model: outline.segments

                Item {
                    id: slice
                    required property var modelData
                    x: modelData.x
                    width: modelData.width
                    height: outline.height - (modelData.bottom ? 0 : Theme.borderWidth)
                    clip: true

                    Rectangle {
                        x: -slice.x
                        width: outline.width
                        height: outline.height
                        color: "transparent"
                        radius: Theme.radius
                        border.width: Theme.borderWidth
                        border.color: Theme.borderColor
                    }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.barInset
            anchors.rightMargin: Theme.barInset
            spacing: Theme.spaceMd

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.horizontalStretchFactor: 1
                clip: true

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaceSm

                    IconButton {
                        text: "\u{F02F9}"
                        onClicked: Panels.toggle("wallpaper")

                        readonly property real centerX: {
                            x; width; parent.x; parent.width;
                            return mapToItem(null, width / 2, 0).x + Theme.padding
                        }
                        onCenterXChanged: Panels.setPosition("wallpaper", centerX)
                        Component.onCompleted: Panels.setPosition("wallpaper", centerX)
                    }

                    Tags {}

                    WeatherStat {}
                }
            }

            Clock {}

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.horizontalStretchFactor: 1
                clip: true

                RowLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spaceXs
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaceMd

                    Media {}

                    RowLayout {
                        spacing: Theme.spaceStat

                        Volume {}
                        SystemStats {}
                    }

                }
            }
        }
    }
}
