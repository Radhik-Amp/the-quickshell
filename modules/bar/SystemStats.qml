import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: Theme.spaceStat

    readonly property real centerX: {
        x; width; parent.x; parent.width;
        return mapToItem(null, width / 2, 0).x + Theme.padding
    }
    onCenterXChanged: Panels.setPosition("system", centerX)
    Component.onCompleted: Panels.setPosition("system", centerX)

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: Panels.toggle("system")
    }

    StatItem { icon: Theme.iconMemory; value: SystemMonitor.memUsage + "%"; widest: "99%" }
    StatItem { icon: Theme.iconTemp; value: SystemMonitor.temp + "°"; widest: "99°"; visible: SystemMonitor.tempSensor !== "" }
    StatItem { icon: Theme.iconCpu; value: SystemMonitor.cpuUsage + "%"; widest: "99%"; valueAlignment: Text.AlignLeft }
}
