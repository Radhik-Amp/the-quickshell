pragma ComponentBehavior: Bound

import qs
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    readonly property int year: clock.date.getFullYear()
    readonly property int month: clock.date.getMonth()
    readonly property int today: clock.date.getDate()
    readonly property int offset: new Date(year, month, 1).getDay()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    TextMetrics {
    id: digits
    text: "00"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    }

    GridLayout {
        columns: 7
        columnSpacing: 2
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater {
            model: ["[s]", "[m]", "[t]", "[w]", "[t]", "[f]", "[s]"]

            BarText {
                Layout.alignment: Qt.AlignHCenter
                required property var modelData
                text: modelData
                color: Qt.rgba(1, 1, 1, 0.65)
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
                implicitWidth: digits.width + 4
                implicitHeight: digits.height + 8
                color: hover.hovered && day > 0 ? Qt.rgba(0.28, 0.28, 0.28, 0.35) : "transparent"
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
