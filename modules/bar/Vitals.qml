import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: Theme.spaceStat

    BarStat { icon: Theme.iconMemory; value: Stats.memUsage + "%"; widest: "99%" }
    BarStat { icon: Theme.iconTemp; value: Stats.temp + "°"; widest: "99°" }
    BarStat { icon: Theme.iconCpu; value: Stats.cpuUsage + "%"; widest: "99%"; valueAlignment: Text.AlignLeft }
}
