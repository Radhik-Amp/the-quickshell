import qs.services
import qs.components
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

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.showDate = !root.showDate
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: ControlState.shown = !ControlState.shown
    }
}
