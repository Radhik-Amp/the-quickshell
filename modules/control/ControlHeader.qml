import qs
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    readonly property string filled: "●"
    readonly property string unfilled: "○"
    property bool beep: true
    readonly property string dot: beep ? filled : unfilled

    BarText {
        text: "ctrl"
    }
    Item {
        Layout.fillWidth: true
    }
    BarText {
        text: root.dot + " all systems nominal"
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.beep = !root.beep
    }
}
