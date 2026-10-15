import qs
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: shown || clipper.height > 0
    anchors.top: true
    margins.top: Theme.padding + Theme.barHeight
    exclusionMode: ExclusionMode.Ignore
//    exclusiveZone: 0

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


                    ColumnLayout {
                        BarText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: Qt.formatDateTime(clock.date, "hh:mm:ss AP")
                            fontSizeMode: Text.HorizontalFit
                        }

                        BarText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
                            fontSizeMode: Text.HorizontalFit
                        }

                        ControlClock {
                            Layout.preferredWidth: 190
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
                                property bool fake: true
                                label: "wifi"
                                status: fake ? "connected" : "off"
                                active: fake
                                onClicked: fake = !fake
                            }

                            ControlToggle {
                                Layout.fillWidth: true
                                property bool fake: false
                                label: "bluetooth"
                                status: fake ? "on" : "off"
                                active: fake
                                onClicked: fake = !fake
                            }
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
                duration: 750
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
            }
        }
    }
}
