pragma Singleton

import qs.config
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
    property string tempSensor: Env.cpuTempSensor

    // First CPU sensor found, by driver: AMD, AMD (zenpower), Intel, ARM.
    // Prefers the package/die reading, else the driver's first input.
    // hwmonN numbers depend on driver load order, so we match on name.
    Process {
        id: detectSensor
        command: ["sh", "-c", `
            for name in k10temp zenpower coretemp cpu_thermal; do
                for d in /sys/class/hwmon/hwmon*; do
                    [ "$(cat "$d/name" 2>/dev/null)" = "$name" ] || continue
                    for l in "$d"/temp*_label; do
                        case "$(cat "$l" 2>/dev/null)" in
                            Tctl|Tdie|"Package id 0") echo "\${l%_label}_input"; exit ;;
                        esac
                    done
                    [ -r "$d/temp1_input" ] && echo "$d/temp1_input" && exit
                done
            done`]
        stdout: StdioCollector {
            onStreamFinished: {
                root.tempSensor = text.trim()
                if (root.tempSensor) tempProc.running = true
                else console.warn("systemmonitor: no CPU temperature sensor found, set VOYAGER_CPU_TEMP_SENSOR to pick one")
            }
        }
        Component.onCompleted: if (!root.tempSensor) running = true
    }

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
        command: ["cat", root.tempSensor]

        stdout: SplitParser {
            onRead: data => {
                var c = parseInt(data)
                root.temp = Math.round(c / 1000)   
            }
        }
        onExited: code => {
            if (code === 0) return
            console.warn("systemmonitor: couldn't read CPU temperature from", root.tempSensor)
            root.tempSensor = ""
        }
        Component.onCompleted: if (root.tempSensor) running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {cpuProc.running = true; memProc.running = true; if (root.tempSensor) tempProc.running = true}
    }
}
