import qs.config
import qs.services
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: Theme.vitalsSpacing

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconMemory }
        StableText { text: Stats.memUsage + "%"; widest: "100%"}
    }

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconTemp }
        StableText { text: Stats.temp + "°"; widest: "100°" }
    }

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconCpu }
        StableText { text: Stats.cpuUsage + "%"; widest: "99%"}
    }
}    
