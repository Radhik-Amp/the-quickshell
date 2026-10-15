pragma ComponentBehavior: Bound

import qs
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    readonly property int year: clock.date.getFullYear()
    readonly property int month: clock.date.getMonth()
    readonly property int today: clock.date.getDate()
    readonly property int offset: new Date(year, month, 1).getDay()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    TextMetrics {
    id: digits
    text: "00"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    }

    BarText {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "hh:mm:ss AP")
    }

    BarText {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
    }

    GridLayout {
        columns: 7
        Layout.fillWidth: true

        Repeater {
            model: ["s", "m", "t", "w", "t", "f", "s"]

            BarText {
                Layout.alignment: Qt.AlignHCenter
                required property var modelData
                text: modelData
            }
        }

        Repeater {
            model: root.offset + root.daysInMonth

            Rectangle {
                required property int index
                readonly property int day: index - root.offset + 1
                readonly property bool isToday: day === root.today
                readonly property bool isPast: day > 0 && day < root.today

                Layout.fillWidth: true
                implicitWidth: digits.width + 8
                implicitHeight: digits.height + 8
                color: hover.hovered && day > 0 ? "#1c1c1c" : "transparent"
                radius: Theme.radius

                HoverHandler {
                    id: hover
                }

                BarText {
                    id: dayText
                    anchors.centerIn: parent
                    text: parent.day > 0 ? parent.day : ""
                    opacity: parent.isPast ? 0.35 : 1
                }

                Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.5
                height: Theme.borderWidth
                color: Theme.borderColor
                visible: parent.isToday
                }
            }
        }
        
    }
        
}
