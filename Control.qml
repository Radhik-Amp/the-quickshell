import qs
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: shown || clipper.height > 0
    anchors.top: true
    margins.top: Theme.padding + Theme.barHeight
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 540
    readonly property int tether: Theme.padding
    readonly property int panelHeight: column.implicitHeight + Theme.padding * 2

    implicitHeight: tether + panelHeight
    color: "transparent"

    readonly property bool shown: ControlState.shown

    mask: Region { item: clipper }

    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    IpcHandler {
        target: "control"
        function toggle(): void { ControlState.shown = !ControlState.shown } 
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Item {
        id: clipper
        clip: true
        width: root.implicitWidth
        height: root.shown ? root.implicitHeight : 0
        focus: true
        Keys.onEscapePressed: ControlState.shown = false

        Rectangle {
            x: Math.round(parent.width / 2)
            width: Theme.borderWidth
            height: root.tether
            color: Theme.borderColor
        }

        Rectangle {
            y: root.tether
            implicitWidth: root.implicitWidth
            implicitHeight: root.panelHeight
            color: Theme.background
            radius: Theme.radius
            ColumnLayout {
                id: column
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.padding
                }

                ControlHeader {}

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Qt.rgba(1, 1, 1, 0.5)
                }


                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.padding

                    Rectangle {
                        Layout.preferredWidth: (root.implicitWidth - Theme.padding * 3) / 2 
                        implicitHeight: content.implicitHeight + Theme.padding * 2
                        color: "transparent"
                        radius: Theme.radius
                        border.color: Theme.borderColorMuted
                        border.width: Theme.borderWidth

                        ColumnLayout {
                            id: content
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: Theme.padding

                            }
                            BarText {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: Qt.formatDateTime(clock.date, "hh:mm:ss AP")
                                font.pixelSize: 26
                            }

                            BarText {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: Qt.formatDateTime(clock.date, "MMMM yyyy")
                                font.pixelSize: 18
                                color: Qt.rgba(1, 1, 1, 0.85)
                            }

                            ControlClock {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            uniformCellWidths: true

                            ControlToggle {
                                Layout.fillWidth: true
                                readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
                                readonly property var wifiNet: wifi?.networks.values.find(n => n.connected)
                                icon: Ethernet.connected ? "\u{F0200}" : wifiNet ? "\u{F05A9}" : "\u{F05AA}"
                                label: "network"
                                status: Ethernet.connected ? "wired"
                                      : wifiNet ? wifiNet.name
                                      : Networking.wifiEnabled ? "not connected" : "off" 
                                active: Networking.wifiEnabled
                                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            }

                            ControlToggle {
                                readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
                                readonly property int connected: adapter
                                                               ? adapter.devices.values.filter(d => d.connected).length
                                                               : 0
                                Layout.fillWidth: true
                                icon: "\u{F00AF}"
                                label: "bluetooth"
                                status: !adapter.enabled ? "off"
                                      : connected > 0 ? connected + " connected"
                                      : "on"
                                active: adapter?.enabled ?? false
                                onClicked: if (adapter) adapter.enabled = !adapter.enabled
                            }

                            ControlToggle {
                                property bool fake: false

                                Layout.fillWidth: true
                                icon: "\u{F0594}"
                                label: "dnd"
                                status: ControlState.dnd ? "on" : "off"
                                active: ControlState.dnd
                                onClicked: ControlState.dnd = !ControlState.dnd
                            }

                            ControlToggle {
                                property bool fake: false

                                Layout.fillWidth: true
                                icon: "\u{F0176}"
                                label: "caffiene"
                                status: fake ? "on" : "off"
                                active: fake
                                onClicked: fake = !fake
                            }

                        }


                        ControlBar {
                            label: "Audio"
                            value: Audio.volume
                            onMoved: v => Audio.setVolume(v)
                        }

                        ControlBar {
                            label: "Brightness"
                            value: Brightness.value
                            onMoved: v => Brightness.set(v)
                        }
                    }
                }
            }
        }
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.tether
            color: "transparent"
            border.color: Theme.borderColor
            border.width: Theme.borderWidth
            radius: Theme.radius
        }

        Behavior on height {
            NumberAnimation {
                duration: 650
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
            }
        }
    }
}
