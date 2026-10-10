import Quickshell
import QtQuick

BarText {
    id: root
    property bool showDate: false

    text: showDate
        ? Qt.formatDateTime(clock.date, "ddd, MMM d")
        : Qt.formatDateTime(clock.date, "h:mm AP")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.showDate = !root.showDate
    }
}
