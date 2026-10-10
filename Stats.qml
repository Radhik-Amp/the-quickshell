pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property int memTotal: 0
    property int memAvailable: 0
    property int memUsage: 0
    property int temp: 0

    Process {
        id: cpuProc
        command: ["head", "-n1", "/proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)))
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: memProc
        command: ["head", "-n3", "/proc/meminfo"]

        stdout: StdioCollector {
            onStreamFinished: {
                const memInfo = text.split("\n")
                const memTotalLine = memInfo.find(i => i.startsWith("MemTotal:"))
                const memTotalSplit = memTotalLine.split(/\s+/)
                const memAvailableLine = memInfo.find(m => m.startsWith("MemAvailable:"))
                const memAvailableSplit = memAvailableLine.split(/\s+/)

                root.memTotal = parseInt(memTotalSplit[1])
                root.memAvailable = parseInt(memAvailableSplit[1])
                root.memUsage = Math.round(100 * ((root.memTotal - root.memAvailable) / root.memTotal))
            }
        } 
        Component.onCompleted: running = true
    }

    Process{
        id: tempProc
        command: ["cat", "/sys/class/hwmon/hwmon3/temp1_input"]

        stdout: SplitParser {
            onRead: data => {
                var c = parseInt(data)
                root.temp = Math.round(c / 1000)   
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {cpuProc.running = true; memProc.running = true; tempProc.running = true}
    }
}
