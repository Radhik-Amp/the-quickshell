import qs.config
import qs.services
import qs.components
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

DropdownPanel {
    id: root

    name: "control"
    focusMode: WlrKeyboardFocus.Exclusive
    implicitWidth: 540

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
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
            Layout.fillHeight: true
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
                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDateTime(clock.date, "hh:mm:ss AP")
                    font.pixelSize: 32
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDateTime(clock.date, "MMMM yyyy")
                    font.pixelSize: 24
                    color: Qt.rgba(1, 1, 1, 0.85)
                }

                ControlClock {}
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
                    status: NotificationService.dnd ? "on" : "off"
                    active: NotificationService.dnd
                    onClicked: NotificationService.dnd = !NotificationService.dnd
                }

                ControlToggle {
                    Layout.fillWidth: true
                    icon: "\u{F0176}"
                    label: "caffeinated"
                    status: Idle.caffeine ? "on" : "off"
                    active: Idle.caffeine
                    onClicked: Idle.caffiene = !Idle.caffeine
                }

            }


            ControlSlider {
                label: "Audio"
                value: Audio.volume
                onMoved: v => Audio.setVolume(v)
            }

            ControlSlider {
                label: "Brightness"
                value: Brightness.value
                onMoved: v => Brightness.set(v)
            }

            ControlPowerProfiles {}
        }
    }

    Rectangle {
        visible: NotificationService.history.count !== 0
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.5)
    }

    ColumnLayout {
        id: notificationCol
        Layout.fillWidth: true
        spacing: Theme.padding

        Repeater {
            model: NotificationService.history

            Rectangle {
                id: notif
                required property int index
                required property int notifId
                required property string summary
                required property string body
                required property string appName
                required property int urgency
                required property string time

                visible: index < 3
                Layout.fillWidth: true
                implicitHeight: notifCol.implicitHeight + Theme.padding * 2
                radius: Theme.radius
                color: "transparent"
                border.width: Theme.borderWidth
                border.color: urgency === NotificationUrgency.Critical ? "#E05252" : Theme.borderColorMuted

                ColumnLayout {
                    id: notifCol
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            Layout.fillWidth: true
                            text: notif.summary
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: notif.time
                            font.pixelSize: Theme.fontSize - 2
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: notif.body
                        font.pixelSize: Theme.fontSize - 2
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }

        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.5)
    }

    ControlSessionActions {}
}
