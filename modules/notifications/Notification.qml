import qs.config
import qs.services
import qs.components
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool centerOpen: false

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.centerOpen = !root.centerOpen }
        function show(): void { root.centerOpen = true }
        function hide(): void { root.centerOpen = false }
        function toggleDnd(): void { ControlState.dnd = !ControlState.dnd }
    }

    PanelWindow {
        visible: !root.centerOpen
        anchors { top: true; right: true }
        margins { top: Theme.padding + 5; right: Theme.padding + 5 }

        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0

        ColumnLayout {
            id: column
            width: parent.width
            spacing: Theme.padding

            Repeater {
                model: Notifs.server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 20
                    radius: Theme.radius
                    color: Theme.background
                    border.width: Theme.borderWidth
                    border.color: modelData.urgency === NotificationUrgency.Critical
                        ? "#E05252" : Theme.borderColor

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: 5000
                        onTriggered: card.modelData.expire()
                    }

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: Theme.padding + 5
                        spacing: Theme.padding + 5

                        Image {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            Layout.alignment: Qt.AlignTop
                            sourceSize.width: 48
                            sourceSize.height: 48
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image
                                || (card.modelData.appIcon
                                    ? Quickshell.iconPath(card.modelData.appIcon, true)
                                    : "")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            BarText {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            BarText {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                font.pixelSize: Theme.fontSize - 2
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }

    PanelWindow {
        visible: root.centerOpen
        anchors { top: true; right: true }
        margins { top: Theme.padding + 5; right: Theme.padding + 5 }

        implicitWidth: 380
        implicitHeight: centerCol.implicitHeight + 24
        color: "transparent"

        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.background
            border.color: Theme.borderColor
            border.width: Theme.borderWidth

            ColumnLayout {
                id: centerCol
                anchors.fill: parent
                anchors.margins: Theme.padding + 5
                spacing: Theme.padding

                RowLayout {
                    Layout.fillWidth: true

                    BarText {
                        Layout.fillWidth: true
                        text: "Notifications"
                        font.pixelSize: Theme.fontSize + 2
                        font.bold: true
                    }

                    BarText {
                        text: "Clear all"
                        visible: Notifs.history.count > 0
                        color: "#E05252"
                        font.pixelSize: Theme.fontSize - 1
                        MouseArea {
                            anchors.fill: parent
                            onClicked:  { for (const n of Notifs.server.trackedNotifications.values.slice()) n.dismiss(); Notifs.history.clear() }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 500)
                    visible: Notifs.history.count > 0
                    clip: true
                    spacing: Theme.padding
                    model: Notifs.history

                    Rectangle {
                        id: entry
                        required property int index
                        required property int notifId
                        required property string summary
                        required property string body
                        required property string appName
                        required property int urgency
                        required property string time

                        width: ListView.view.width
                        implicitHeight: entryCol.implicitHeight + Theme.padding * 2
                        radius: Theme.radius
                        color: "transparent"
                        border.width: Theme.borderWidth
                        border.color: urgency === NotificationUrgency.Critical
                            ? "#E05252" : Theme.borderColorMuted

                        ColumnLayout {
                            id: entryCol
                            anchors.fill: parent
                            anchors.margins: Theme.padding
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.padding

                                BarText {
                                    Layout.fillWidth: true
                                    text: entry.summary
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                BarText {
                                    text: entry.time
                                    font.pixelSize: Theme.fontSize - 2
                                }


                                Rectangle {
                                    id: close
                                    implicitHeight: closeText.implicitHeight + 4
                                    implicitWidth: implicitHeight
                                    radius: Theme.radius
                                    color: "transparent"
                                    BarText {
                                        id: closeText
                                        anchors.centerIn: parent
                                        text: "\u{F0156}"
                                        font.pixelSize: Theme.fontSize - 2
                                        color: mouseClose.containsMouse ? "#E05252" : "white"
                                    }
                                    MouseArea {
                                        id: mouseClose
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { Notifs.dismissNotif(entry.notifId); Notifs.history.remove(entry.index) }
                                    }

                                }
                            }

                            BarText {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: entry.body
                                font.pixelSize: Theme.fontSize - 2
                                wrapMode: Text.WordWrap
                            }

                            BarText {
                                visible: entry.appName !== ""
                                text: entry.appName
                                font.pixelSize: Theme.fontSize - 4
                            }
                        }
                    }
                }

                BarText {
                    visible: Notifs.history.count === 0
                    text: "No notifications"
                    font.pixelSize: Theme.fontSize - 1
                }
            }
        }
    }
}
