import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body, 
                appName: n.appName,
                urency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            n.tracked = true
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.centerOpen = !root.centerOpen }
        function show(): void { root.centerOpen = true }
        function hide(): void { root.centerOpen = false }
    }

    PanelWindow {
        anchors { top: true; right: true }
        margins { top: Theme.padding + 5; right: Theme.padding + 5 }

        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: Theme.padding

            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
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
                        onTriggered: card.modelData.dismiss()
                    }
                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: Theme.padding + 5
                        spacing: Theme.padding + 5
                        Image {

                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            BarText {
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
                        id: mouse
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

        exclusionMode: ExclusionMode.Ignore
        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.background
            border.width: Theme.borderWidth

            ColumnLayout {
                id: centerCol
                anchors.fill: parent
                spacing: Theme.padding
                anchors.margins: Theme.padding + 5

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
                        visible: history.count > 0
                        color: "#E05252"
                        font.pixelSize: Theme.fontSize - 1
                        MouseArea {
                            anchors.fill: parent
                            onClicked: history.clear()
                        }
                    }
                }
            }
        }
    }
}
