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

    // Panel extras
    readonly property bool panelOpen: Panels.active === "system"
    readonly property int historyLength: 60
    property var cpuHistory: []
    property var memHistory: []
    property int cpuThreads: 0
    property int swapTotal: 0
    property int swapUsed: 0
    property real load1: 0
    property real load5: 0
    property real load15: 0
    property int tasks: 0
    property real uptime: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property var topProcesses: []

    function pushHistory(history, value) {
        const next = history.concat(value)
        return next.length > historyLength ? next.slice(next.length - historyLength) : next
    }

    function formatKb(kb) {
        return kb >= 1048576 ? (kb / 1048576).toFixed(1) + " GiB" : Math.round(kb / 1024) + " MiB"
    }

    function formatUptime(seconds) {
        const d = Math.floor(seconds / 86400)
        const h = Math.floor(seconds % 86400 / 3600)
        const m = Math.floor(seconds % 3600 / 60)
        return d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`
    }

    function parseKb(s) {
        const m = s.match(/^([\d.]+)([kmgtp]?)$/i)
        if (!m) return 0
        return parseFloat(m[1]) * Math.pow(1024, "kmgtp".indexOf(m[2].toLowerCase() || "k"))
    }

    // First CPU sensor found, by driver: AMD, AMD (zenpower), Intel, ARM.
    // hwmonN numbers depend on driver load order so it matches by name
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
                    root.cpuHistory = root.pushHistory(root.cpuHistory, root.cpuUsage)
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]

        stdout: StdioCollector {
            onStreamFinished: {
                const info = {}
                for (const line of text.split("\n")) {
                    const m = line.match(/^(\w+):\s+(\d+)/)
                    if (m) info[m[1]] = parseInt(m[2])
                }

                root.memTotal = info.MemTotal ?? 0
                root.memAvailable = info.MemAvailable ?? 0
                root.memUsage = root.memTotal > 0 ? Math.round(100 * ((root.memTotal - root.memAvailable) / root.memTotal)) : 0
                root.memHistory = root.pushHistory(root.memHistory, root.memUsage)
                root.swapTotal = info.SwapTotal ?? 0
                root.swapUsed = root.swapTotal - (info.SwapFree ?? 0)
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

    Process {
        command: ["grep", "-c", "^cpu[0-9]", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuThreads = parseInt(text) || 0
        }
        Component.onCompleted: running = true
    }

    Process {
        id: loadProc
        command: ["cat", "/proc/loadavg", "/proc/uptime"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const load = lines[0].split(/\s+/)
                root.load1 = parseFloat(load[0])
                root.load5 = parseFloat(load[1])
                root.load15 = parseFloat(load[2])
                root.tasks = parseInt(load[3].split("/")[1]) || 0
                root.uptime = parseFloat(lines[1]) || 0
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: diskProc
        command: ["df", "-B1", "--output=used,size", "/"]

        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("\n").pop().trim().split(/\s+/)
                root.diskUsed = parseFloat(p[0]) || 0
                root.diskTotal = parseFloat(p[1]) || 0
            }
        }
    }

    Process {
        id: topProc
        command: ["top", "-b", "-n", "2", "-d", "1", "-o", "%CPU", "-e", "k", "-w", "512"]

        stdout: StdioCollector {
            onStreamFinished: {
                const frame = text.split(/^top - /m).pop().split("\n")
                const header = frame.findIndex(l => /^\s*PID\s/.test(l))
                if (header < 0) return

                const rows = []
                for (const line of frame.slice(header + 1)) {
                    // PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
                    const p = line.trim().split(/\s+/)
                    if (p.length < 12) continue
                    const name = p.slice(11).join(" ")
                    if (name === "top") continue
                    rows.push({ name: name, cpu: parseFloat(p[8]) || 0, mem: root.parseKb(p[5]) })
                    if (rows.length === 5) break
                }
                root.topProcesses = rows
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            loadProc.running = true
            if (root.tempSensor) tempProc.running = true
        }
    }

    Timer {
        interval: 30000
        running: root.panelOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProc.running = true
    }

    Timer {
        interval: 3000
        running: root.panelOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: topProc.running = true
    }
}
