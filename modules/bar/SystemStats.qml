import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: Theme.spaceStat

    StatItem { icon: Theme.iconMemory; value: SystemMonitor.memUsage + "%"; widest: "99%" }
    StatItem { icon: Theme.iconTemp; value: SystemMonitor.temp + "°"; widest: "99°"; visible: SystemMonitor.tempSensor !== "" }
    StatItem { icon: Theme.iconCpu; value: SystemMonitor.cpuUsage + "%"; widest: "99%"; valueAlignment: Text.AlignLeft }
}
