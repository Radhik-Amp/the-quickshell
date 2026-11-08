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
        border.width: Theme.borderWidth
        border.color: Theme.borderColor

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
                        onClicked: Wallpaper.toggle()
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
