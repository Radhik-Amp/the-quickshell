import qs.components
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

WlSessionLock {
    id: lock

    locked: LockScreenState.locked

    Component.onCompleted: Wallpaper.refresh()

    onLockedChanged: {
        if (locked) Wallpaper.refresh()
        if (LockScreenState.locked !== locked) {
            LockScreenState.locked = locked
        }
    }

    WlSessionLockSurface {
        id: surface

        Rectangle {
            id: mainContainer
            anchors.fill: parent
            color: "#000000"

            property bool shown: false
            readonly property bool visibleState: shown && !LockScreenState.unlocking

            opacity: visibleState ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic

                }
            }

            Image {
                id: wallpaper
                anchors.fill: parent
                source: {
                    const path = Wallpaper.paths[surface.screen?.name]
                    return path ? "file://" + path : ""
                }
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: false
                cache: true

                sourceSize.width: surface.width
                sourceSize.height: surface.height

                visible: false
            }

            MultiEffect {
                id: blurredWallpaper
                anchors.fill: wallpaper
                source: wallpaper
                blurEnabled: true
                blur: 0.8
                blurMax: 32

                visible: wallpaper.status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.85
            }

            Item {
                id: card
                width: 320
                height: contentColumn.height
                anchors.centerIn: parent

                property real animOffsetX: 0
                transform: Translate { x: card.animOffsetX }
                scale: mainContainer.visibleState ? 1.0 : 0.92

                Behavior on scale {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                SequentialAnimation {
                    id: shakeAnime
                    loops: 1
                    NumberAnimation { target: card; property: "animOffsetX"; to: -12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: -8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "animOffsetX"; to: 0; duration: 50; easing.type: Easing.OutQuad }
                }

                Column {
                    id: contentColumn
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    BarText {
                        id: clockText
                        anchors.horizontalCenter: parent.horizontalCenter

                        property date currentTime: new Date()

                        text: Qt.formatTime(currentTime, "hh:mm")
                        font.pixelSize: 80

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.currentTime = new Date()
                        }
                    }

                    BarText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(clockText.currentTime, "dddd, MMMM d")
                        color: Qt.rgba(1, 1, 1, 0.75)
                    }

                    Item { height: 12; width: 1}

                    Rectangle {
                        id: fieldWrap
                        width: parent.width
                        height: 50
                        radius: 5
                        color: Qt.rgba(0, 0, 0, 0.5)
                        border.width: 1
                        border.color: LockScreenState.authFailed ? "#E05252" : "white"

                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            TextField {
                                id: pwField
                                Layout.fillWidth: true
                                echoMode: TextInput.Password
                                enabled: !LockScreenState.authenticating && !LockScreenState.unlocking
                                placeholderText: LockScreenState.authenticating ? "Verifying..." : "Enter Password"
                                placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                                color: "#ffffff"
                                background: null
                                font.pixelSize: 15
                                verticalAlignment: TextInput.AlignVCenter

                                onAccepted: {
                                    if (text.length > 0)
                                    LockScreenState.authenticate(text)
                                }
                            }

                            BusyIndicator {
                                visible: LockScreenState.authenticating
                                running: LockScreenState.authenticating
                                implicitWidth: 18
                                implicitHeight: 18
                            }
                        }
                    } 

                    BarText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Incorrect password"
                        color: "#E05252"
                        font.pixelSize: 13
                        opacity: LockScreenState.authFailed ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutSine } }
                    }
                }
            }

            Connections {
                target: LockScreenState
                function onAuthFailedChanged() {
                    if (LockScreenState.authFailed) {
                        shakeAnime.start()
                        pwField.text = ""
                        pwField.forceActiveFocus()
                    }
                }

                function onLockedChanged() {
                    if (!LockScreenState.locked) {
                        pwField.text = ""
                    } else {
                        pwField.forceActiveFocus()
                    }
                }
            }

            Component.onCompleted: {
                shown = true
                pwField.forceActiveFocus()
            }

        }
    }
}
