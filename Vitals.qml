import QtQuick
import QtQuick.Layouts
RowLayout {
    spacing: Theme.vitalsSpacing

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconTemp }
        BarText { text: Stats.temp + "°" }
    }

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconCpu }
        BarText { text: Stats.cpuUsage + "%" }
    }

    RowLayout {
        spacing: Theme.iconToValueSpacing

        BarText { text: Theme.iconMemory }
        BarText { text: Stats.memUsage + "%" }
    }
}    
