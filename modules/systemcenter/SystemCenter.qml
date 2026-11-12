import qs.config
import qs.components
import qs.services
import qs.modules.weathercenter
import QtQuick
import QtQuick.Layouts

DropdownPanel {
    id: root

    readonly property real gib: 1024 * 1024 * 1024

    name: "system"
    anchorX: Panels.positions.system ?? NaN
    implicitWidth: 460
    spacing: Theme.padding

    SystemGraph {
        Layout.fillWidth: true
        label: "CPU"
        value: SystemMonitor.cpuUsage + "%"
        detail: SystemMonitor.cpuThreads > 0 ? SystemMonitor.cpuThreads + " threads" : ""
        history: SystemMonitor.cpuHistory
    }

    SystemGraph {
        Layout.fillWidth: true
        label: "RAM"
        value: SystemMonitor.memUsage + "%"
        detail: ((SystemMonitor.memTotal - SystemMonitor.memAvailable) / 1048576).toFixed(1)
            + " / " + SystemMonitor.formatKb(SystemMonitor.memTotal)
        history: SystemMonitor.memHistory
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        uniformCellWidths: true
        rowSpacing: Theme.spaceSm
        columnSpacing: Theme.spaceSm

        WeatherDetail {
            Layout.fillWidth: true
            visible: SystemMonitor.tempSensor !== ""
            icon: Theme.iconTemp
            label: "CPU temp"
            value: SystemMonitor.temp + "°C"
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconLoad
            label: "Load"
            value: [SystemMonitor.load1, SystemMonitor.load5, SystemMonitor.load15].map(l => l.toFixed(2)).join(" ")
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconUptime
            label: "Uptime"
            value: SystemMonitor.formatUptime(SystemMonitor.uptime)
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconSwap
            label: "Swap"
            value: SystemMonitor.swapTotal > 0
                ? SystemMonitor.formatKb(SystemMonitor.swapUsed) + " / " + SystemMonitor.formatKb(SystemMonitor.swapTotal)
                : "Off"
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconDisk
            label: "Disk /"
            value: SystemMonitor.diskTotal > 0
                ? Math.round(SystemMonitor.diskUsed / root.gib) + " / " + Math.round(SystemMonitor.diskTotal / root.gib) + " GiB"
                : "…"
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconTasks
            label: "Tasks"
            value: SystemMonitor.tasks
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.5)
    }

    SystemProcesses {
        Layout.fillWidth: true
    }
}
