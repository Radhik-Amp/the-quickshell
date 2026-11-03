import qs.services
import qs.components
import Quickshell
import QtQuick

StyledText {
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
        onTapped: ControlCenterState.shown = !ControlCenterState.shown
    }
}
